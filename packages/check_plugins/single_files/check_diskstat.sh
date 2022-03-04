#!/bin/bash

DISK=
WARNING=
CRITICAL=

E_OK=0
E_WARNING=1
E_CRITICAL=2
E_UNKNOWN=3

BRIEF=0
SILENT=0

show_help() {
    echo
    echo "$0 -d DEVICE [ -w tps,read,write -c tps,read,write ] "
    echo "    | [ -W qlen -C qlen ] | -h"
    echo
    echo "This plug-in is used to be alerted when maximum hard drive io/s, sectors"
    echo "read|write/s or average queue length is reached."
    echo
    echo "  -d DEVICE            DEVICE must be without /dev (ex: -d sda)."
    echo "                       To specify a LVM logical volume use:"
    echo "                       volgroup/logvol."
    echo "                       To specify symlink from /dev/disk/ use full path, ex:"
    echo "                       /dev/disk/by-id/scsi-35000c50035006fb3"
    echo "  -m MOUNT             The plugin tries to resolve MOUNT to a device"
    echo "  -w/c TPS,READ,WRITE  TPS means transfer per seconds (aka IO/s)"
    echo "                       READ and WRITE are in sectors per seconds"
    echo "  -W/C NUM             Use average queue length thresholds instead.."
    echo "  -b                   Brief output."
    echo "  -s                   silent output: no warnings or critials are issued"
    echo
    echo "Performance data for graphing is supplied for tps, read, write, avgrq-sz,"
    echo "avgqu-sz and await (see iostat man page for details)."
    echo
    echo "Example: Tps, read and write thresholds:"
    echo "    $0 -d sda -w 200,100000,100000 -c 300,200000,200000"
    echo
    echo "Example: Average queue length threshold:"
    echo "    $0 -d sda -W 50 -C 100"
    echo
}

# process args
while [ ! -z "$1" ]; do
    case $1 in
        -b) BRIEF=1 ;;
        -s) SILENT=1 ;;
        -d) shift; ORIGDISK=$1; DISK=${1////!} ;;
        -m) shift; MOUNT=$1; ;;
        -w) shift; WARNING=$1 ;;
        -c) shift; CRITICAL=$1 ;;
        -W) shift; WARN_QSZ=$1 ;;
        -C) shift; CRIT_QSZ=$1 ;;
        -h) show_help; exit 1 ;;
    esac
    shift
done

# generate HISTFILE filename
SITE=$(echo "$0" | cut -d "/" -f1)
HISTFILE=/var/tmp/check_diskstat_`id -nu`_$SITE.$DISK

# check input parameters so we can continu !
sanitize() {
    # check device name
    if [ -z "$DISK" ]; then
        echo "Need device name, ex: sda"
        exit $E_UNKNOWN
    fi

    if [ -z $WARN_QSZ ]; then
        # check thresholds
        if [ -z "$WARNING" ]; then
            echo "Need warning threshold"
            exit $E_UNKNOWN
        fi
        if [ -z "$CRITICAL" ]; then
            echo "Need critical threshold"
            exit $E_UNKNOWN
        fi

        if [ -z "$WARN_TPS" -o -z "$WARN_READ" -o -z "$WARN_WRITE" ]; then
            echo "Need 3 values for warning threshold (tps,read,write)"
            exit $E_UNKNOWN
        fi
        if [ -z "$CRIT_TPS" -o -z "$CRIT_READ" -o -z "$CRIT_WRITE" ]; then
            echo "Need 3 values for critical threshold (tps,read,write)"
            exit $E_UNKNOWN
        fi
    else
        if [ -z "$CRIT_QSZ" ]; then
            echo "Need '-C' option."
            exit $E_UNKNOWN
        fi
    fi

}

resolvemount() {
   ORIGDISK=`grep " $MOUNT " /etc/mtab | awk '{ print $1 }'`
   SNAME=`readlink $ORIGDISK`
   DISK=`basename $SNAME`
}

readdiskstat() {
    if [ ! -f "/sys/block/$1/stat" ]; then
        return $E_UNKNOWN
    fi

    cat /sys/block/$1/stat
}

readhistdiskstat() {
    [ -f $HISTFILE ] && cat $HISTFILE
}

# process thresholds
if [ -z $WARN_QSZ ]; then
    WARN_TPS=$(echo $WARNING | cut -d , -f 1)
    WARN_READ=$(echo $WARNING | cut -d , -f 2)
    WARN_WRITE=$(echo $WARNING | cut -d , -f 3)
    CRIT_TPS=$(echo $CRITICAL | cut -d , -f 1)
    CRIT_READ=$(echo $CRITICAL | cut -d , -f 2)
    CRIT_WRITE=$(echo $CRITICAL | cut -d , -f 3)
    # check args
fi

if [ ! -z "$MOUNT" ]; then
    resolvemount
fi
sanitize

if [ ! -e /sys/block/$DISK/stat ]; then
    # The device does not exist.
    if [[ $ORIGDISK =~ "/" && -b /dev/$ORIGDISK ]]; then
        # The minor device no. maps to /dev/dm-N
        MINOR_HEX=`stat -L /dev/$ORIGDISK --printf="%T\n"`
        MINOR=`echo $((16#$MINOR_HEX))` # translate hex output to decimal
        [[ $? -ne 0 ]] && {
            echo "Could not stat '/dev/$ORIGDISK', check your /sys filesystem for $DISK"
            exit $E_UNKNOWN
        }
        DISK="dm-$MINOR"
    elif [[ -L $ORIGDISK ]]; then
        # Symlink to device name 
        SNAME=`readlink $ORIGDISK`
        DISK=`basename $SNAME`
    else
        echo "Could not find disk stats, check your /sys filesystem for $DISK"
        exit $E_UNKNOWN
    fi
fi

NEWDISKSTAT=$(readdiskstat $DISK)
if [ $? -eq $E_UNKNOWN ]; then
    echo "Cannot read disk stats, check your /sys filesystem for $DISK"
    exit $E_UNKNOWN
fi

if [ ! -f $HISTFILE ]; then
    echo $NEWDISKSTAT >$HISTFILE
    echo "UNKNOWN - Initial buffer creation..." 
    exit $E_UNKNOWN
fi

OLDDISKSTAT=$(readhistdiskstat)
if [ $? -ne 0 ]; then
    echo "Cannot read histfile $HISTFILE..."
    exit $E_UNKNOWN
fi
OLDDISKSTAT_TIME=$(stat $HISTFILE | grep Modify | sed 's/^.*: \(.*\)$/\1/')
OLDDISKSTAT_EPOCH=$(date -d "$OLDDISKSTAT_TIME" +%s)
NEWDISKSTAT_EPOCH=$(date +%s)

echo $NEWDISKSTAT >$HISTFILE
# now we have old and current stat; 
# let compare it
OLD_SECTORS_READ=$(echo $OLDDISKSTAT | awk '{print $3}')
NEW_SECTORS_READ=$(echo $NEWDISKSTAT | awk '{print $3}')
OLD_READ=$(echo $OLDDISKSTAT | awk '{print $1}')
NEW_READ=$(echo $NEWDISKSTAT | awk '{print $1}')
OLD_WRITE=$(echo $OLDDISKSTAT | awk '{print $5}')
NEW_WRITE=$(echo $NEWDISKSTAT | awk '{print $5}')

OLD_SECTORS_WRITTEN=$(echo $OLDDISKSTAT | awk '{print $7}')
NEW_SECTORS_WRITTEN=$(echo $NEWDISKSTAT | awk '{print $7}')

# kernel handles sectors by 512bytes
# http://www.mjmwired.net/kernel/Documentation/block/stat.txt
SECTORBYTESIZE=512

# fix overflowing 32bit counter (4294967296 = 2^32)
if [ $NEW_SECTORS_READ -lt $OLD_SECTORS_READ ] ; then
        let "OLD_SECTORS_READ = $OLD_SECTORS_READ - 4294967296"
fi
if [ $NEW_SECTORS_WRITTEN -lt $OLD_SECTORS_WRITTEN ] ; then
        let "OLD_SECTORS_WRITTEN = $OLD_SECTORS_WRITTEN - 4294967296";
fi

let "SECTORS_READ = $NEW_SECTORS_READ - $OLD_SECTORS_READ"
let "SECTORS_WRITE = $NEW_SECTORS_WRITTEN - $OLD_SECTORS_WRITTEN"
let "TIME = $NEWDISKSTAT_EPOCH - $OLDDISKSTAT_EPOCH"

[[ -z $TIME || $TIME -eq 0 ]] && {
   echo "WARNING: Time delta is zero."
   exit $E_WARNING
}

let "BYTES_READ_PER_SEC = $SECTORS_READ * $SECTORBYTESIZE / $TIME"
let "BYTES_WRITTEN_PER_SEC = $SECTORS_WRITE * $SECTORBYTESIZE / $TIME"
let "TPS=($NEW_READ - $OLD_READ + $NEW_WRITE - $OLD_WRITE) / $TIME"

let "KBYTES_READ_PER_SEC = $BYTES_READ_PER_SEC / 1024"
let "KBYTES_WRITTEN_PER_SEC = $BYTES_WRITTEN_PER_SEC / 1024"

# From iostat source
#
#    xds->await = (sdc->nr_ios - sdp->nr_ios) ?
#        ((sdc->rd_ticks - sdp->rd_ticks) + (sdc->wr_ticks - sdp->wr_ticks)) /
#        ((double) (sdc->nr_ios - sdp->nr_ios)) : 0.0;
#    xds->arqsz = (sdc->nr_ios - sdp->nr_ios) ?
#        ((sdc->rd_sect - sdp->rd_sect) + (sdc->wr_sect - sdp->wr_sect)) /
#        ((double) (sdc->nr_ios - sdp->nr_ios)) : 0.0;
#
# iostat 'avgrq-sz' = arqsz

#OLD_INFLIGHT=$(echo $OLDDISKSTAT | awk '{print $9}')
#NEW_INFLIGHT=$(echo $NEWDISKSTAT | awk '{print $9}')
#let "INFLIGHT = $NEW_INFLIGHT - $OLD_INFLIGHT" #requests
#OLD_IOTICKS=$(echo $OLDDISKSTAT | awk '{print $10}')
#NEW_IOTICKS=$(echo $NEWDISKSTAT | awk '{print $10}')
#let "IOTICKS = $NEW_IOTICKS - $OLD_IOTICKS" #ms

OLD_WAITTIME_READ=$(echo $OLDDISKSTAT | awk '{print $4}')
NEW_WAITTIME_READ=$(echo $NEWDISKSTAT | awk '{print $4}')
let "READ_TICKS = $NEW_WAITTIME_READ - $OLD_WAITTIME_READ" #ms
OLD_WAITTIME_WRITE=$(echo $OLDDISKSTAT | awk '{print $8}')
NEW_WAITTIME_WRITE=$(echo $NEWDISKSTAT | awk '{print $8}')
let "WRITE_TICKS = $NEW_WAITTIME_WRITE - $OLD_WAITTIME_WRITE" #ms
let "NR_IOS = $NEW_READ - $OLD_READ + $NEW_WRITE - $OLD_WRITE"
OLD_TIMEINQ=$(echo $OLDDISKSTAT | awk '{print $11}')
NEW_TIMEINQ=$(echo $NEWDISKSTAT | awk '{print $11}')
let "TIMEINQ = $NEW_TIMEINQ - $OLD_TIMEINQ" #ms

: $((++$NR_IOS)) ; : $((--$NR_IOS))

let "AQUSZ = ( $TIMEINQ / $TIME ) / 1000"

if [[ $NR_IOS -ne 0 ]]; then
    let "AWAIT = ( $READ_TICKS + $WRITE_TICKS ) / $NR_IOS"
    let "ARQSZ = ( $SECTORS_READ + $SECTORS_WRITE ) / $NR_IOS"
else
    AWAIT=0
    ARQSZ=0
fi

OUTPUT=""
EXITCODE=$E_OK
if [ -z $WARN_QSZ ]; then
    # check TPS
    if [ $TPS -gt $WARN_TPS ]; then
        if [ $TPS -gt $CRIT_TPS ]; then
            OUTPUT="critical IO/s (>$CRIT_TPS), "
            EXITCODE=$E_CRITICAL
        else
            OUTPUT="warning IO/s (>$WARN_TPS), "
            EXITCODE=$E_WARNING
        fi
    fi
    # check read
    if [ $BYTES_READ_PER_SEC -gt $WARN_READ ]; then
        if [ $BYTES_READ_PER_SEC -gt $CRIT_READ ]; then
            OUTPUT="${OUTPUT}critical read sectors/s (>$CRIT_READ), "
            EXITCODE=$E_CRITICAL
        else
            OUTPUT="${OUTPUT}warning read sectors/s (>$WARN_READ), "
            [ "$EXITCODE" -lt $E_CRITICAL ] && EXITCODE=$E_WARNING
        fi
    fi

    # check write
    if [ $BYTES_WRITTEN_PER_SEC -gt $WARN_WRITE ]; then
        if [ $BYTES_WRITTEN_PER_SEC -gt $CRIT_WRITE ]; then
            OUTPUT="${OUTPUT}critical write sectors/s (>$CRIT_WRITE), "
            EXITCODE=$E_CRITICAL
        else
            OUTPUT="${OUTPUT}warning write sectors/s (>$WARN_WRITE), "
            [ "$EXITCODE" -lt $E_CRITICAL ] && EXITCODE=$E_WARNING
        fi
    fi
else
    # check WARN_QSZ
    if [ $AQUSZ -gt $WARN_QSZ ]; then
        if [ $AQUSZ -gt $CRIT_QSZ ]; then
            OUTPUT="critical queue size (>$CRIT_QSZ), "
            EXITCODE=$E_CRITICAL
        else
            OUTPUT="warning queue size (>$WARN_QSZ), "
            EXITCODE=$E_WARNING
        fi
    fi
fi

for i in ${TPS} ${BYTES_READ_PER_SEC} ${BYTES_WRITTEN_PER_SEC} \
    ${ARQSZ} ${AQUSZ} ${AWAIT}
do
    [[ $i -lt 0 ]] && {
        echo "Negative values, skipping this round."
        exit $E_UNKNOWN
    }
done

if [[ $BRIEF -eq 0 ]]; then
    echo "${OUTPUT}summary: $TPS io/s, read $SECTORS_READ sectors (${KBYTES_READ_PER_SEC}kB/s), write $SECTORS_WRITE sectors (${KBYTES_WRITTEN_PER_SEC}kB/s), queue size $AQUSZ in $TIME seconds | tps=${TPS};$WARN_TPS;$CRIT_TPS; read=${BYTES_READ_PER_SEC}B;$WARN_READ;$CRIT_READ; write=${BYTES_WRITTEN_PER_SEC}B;$WARN_WRITE;$CRIT_WRITE; avgrq-sz=${ARQSZ};;; avgqu-sz=${AQUSZ};$WARN_QSZ;$CRIT_QSZ; await=${AWAIT}ms;;;"
else
    echo "$TPS io/s, read ${KBYTES_READ_PER_SEC}kB/s, write ${KBYTES_WRITTEN_PER_SEC}kB/s, ave. queue size ${AQUSZ} | tps=${TPS};$WARN_TPS;$CRIT_TPS; read=${BYTES_READ_PER_SEC}B;$WARN_READ;$CRIT_READ; write=${BYTES_WRITTEN_PER_SEC}B;$WARN_WRITE;$CRIT_WRITE; avgrq-sz=${ARQSZ};;; avgqu-sz=${AQUSZ};$WARN_QSZ;$CRIT_QSZ; await=${AWAIT}ms;;;"
fi

if [[ $SILENT -eq 1 ]]; then
  EXITCODE=$E_OK
fi
exit $EXITCODE
