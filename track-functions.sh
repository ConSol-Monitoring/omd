#!/bin/bash
# Build tracking functions - handles timing, logging, and OpenTelemetry spans

LOGFILE=/tmp/maketargets.log

track_root_start() {
    local service_name="$1"
    local span_name="$2"

    # Cleanup old tracking files
    rm -rf /tmp/otel
    mkdir -p /tmp/otel/otel-times

    # Always record start time and log
    date +%s%6N > /tmp/otel/otel-times/${span_name}.start 2>/dev/null || \
        date +%s000000 > /tmp/otel/otel-times/${span_name}.start
    echo "[$(date)] build: ${span_name} start" >> $LOGFILE

    # Only start OTEL span if enabled
    [ -z "$OTEL_EXPORTER_OTLP_ENDPOINT" ] && return 0

    mkdir -p /tmp/otel/omdbuild.sockdir
    nohup otel-cli span background --name "$span_name" \
        --verbose --fail \
        --sockdir /tmp/otel/omdbuild.sockdir \
        --service "$service_name" \
        --timeout 3600s \
        --tp-carrier /tmp/otel/otel-cli-omdbuild-traceparent \
        --tp-print >/tmp/otel/init-span.out 2>/tmp/otel/init-span.err &
}

track_root_end() {
    local service_name="$1"
    local span_name="$2"
    local status="$3"
    local distro="$4"
    local omd_version="$5"
    local make_jobs="${6:-0}"
    local num_cpus="$7"
    local buildhost="$8"

    # Always calculate elapsed and log
    local start_time=$(cat /tmp/otel/otel-times/${span_name}.start 2>/dev/null || echo 0)
    local end_time=$(date +%s%6N 2>/dev/null || date +%s000000)
    local elapsed=$(( ($end_time - $start_time) / 1000000 ))
    echo "[$(date)] build: ${span_name} (took ${elapsed}s, status=${status})" >> $LOGFILE

    # Only end OTEL span if enabled
    if [ -n "$OTEL_EXPORTER_OTLP_ENDPOINT" ]; then
        otel-cli span end \
            --attrs "distro=$distro,omd_version=$omd_version,make_jobs=$make_jobs,num_cpus=$num_cpus,buildhost=$buildhost,elapsed_time=$elapsed,exit_status=$status" \
            --sockdir /tmp/otel/omdbuild.sockdir
        rm -f /tmp/otel/otel-cli-omdbuild-traceparent
        rm -rf /tmp/otel/omdbuild.sockdir
    fi

    rm -rf /tmp/otel/otel-times
    return $status
}

track_start() {
    local service_name="$1"
    local target_name="$2"

    # Always record start time and log
    mkdir -p /tmp/otel/otel-times
    date +%s%6N > /tmp/otel/otel-times/${target_name}.start 2>/dev/null || \
        date +%s000000 > /tmp/otel/otel-times/${target_name}.start
    echo "[$(date)] build: ${target_name} start" >> $LOGFILE
}

track_end() {
    local service_name="$1"
    local target_name="$2"
    local status="${3:-$?}"

    # Always calculate elapsed and log
    local start_time=$(cat /tmp/otel/otel-times/${target_name}.start 2>/dev/null || echo 0)
    local end_time=$(date +%s%6N 2>/dev/null || date +%s000000)
    local elapsed=$(( ($end_time - $start_time) / 1000000 ))
    echo "[$(date)] build: ${target_name} (took ${elapsed}s, status=${status})" >> $LOGFILE

    # Only create OTEL span if enabled
    if [ -n "$OTEL_EXPORTER_OTLP_ENDPOINT" ] && [ -r "/tmp/otel/otel-cli-omdbuild-traceparent" ]; then
        local start_time_seconds=$(awk "BEGIN {printf \"%.6f\", $start_time / 1000000}")
        local end_time_seconds=$(awk "BEGIN {printf \"%.6f\", $end_time / 1000000}")

        local xtraceparent=$(grep '^TRACEPARENT=' /tmp/otel/otel-cli-omdbuild-traceparent | cut -d= -f2)
        local trace_id=$(echo "$xtraceparent" | cut -d- -f2)
        local parent_span_id=$(echo "$xtraceparent" | cut -d- -f3)

        otel-cli span --name "$target_name" --service "$service_name" \
            --force-trace-id $trace_id \
            --force-parent-span-id $parent_span_id \
            --verbose --fail \
            --start $start_time_seconds \
            --end $end_time_seconds \
            --attrs "elapsed_time=$elapsed,exit_status=$status" \
            >/tmp/otel/trace.span.${target_name} 2>/tmp/otel/trace.span.err.${target_name} || true
    fi

    return $status
}
