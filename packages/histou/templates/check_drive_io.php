<?php
/**
This template is used for snclients check_drive_io.
**/

$rule = new \histou\template\Rule(
    $host = '.*',
    $service = '.*',
    $command = '.*',
    $perfLabel = array('^.*?_(read_count|read_bytes|read_time|write_count|write_bytes|write_time|utilization|io_time|weighted_io|iops_in_progress)$')
);

$genTemplate = function ($perfData) {
    $dashboard = \histou\grafana\dashboard\DashboardFactory::generateDashboard($perfData['host'].'-'.$perfData['service']);

    $addPanelRates = function ($dashboard, $perfData) {
        $row = new \histou\grafana\Row($perfData['host'].' '.$perfData['service']);
        $panel = \histou\grafana\graphpanel\GraphPanelFactory::generatePanel($perfData['host'].' '.$perfData['service']." rates");
        foreach ($perfData['perfLabel'] as $key => $values) {
            if(!preg_match('/^(.*?)_(read|write)_bytes$/', $key, $hit)) {
                continue;
            }
            $customSelect = null;
            if (DATABASE_TYPE == INFLUXDB) {
                $customSelect = "\histou\grafana\graphpanel\GraphPanelInfluxdb::createCounterSelect";
            }

            $panel->setLeftUnit("Bps");
            $target = $panel->genTarget($perfData['host'], $perfData['service'], null, $key, null, '', false, $customSelect);
            $target = $panel->addWarnToTarget($target, $key);
            $target = $panel->addCritToTarget($target, $key);
            $panel->addTarget($target);

            $downtime = $panel->genDowntimeTarget($perfData['host'], $perfData['service'], null, $key, '', false, $customSelect);
            $panel->addTarget($downtime);
        }
        $panel->negateY('/_write_bytes.*/');
        $panel->addRegexColor('/^.*?_read_bytes-value$/', '#085DFF', 3);
        $panel->addRegexColor('/^.*?_write_bytes-value$/', '#4707ff', 3);

        $row->addPanel($panel);
        $dashboard->addRow($row);
    };

    $addPanelUtilization = function ($dashboard, $perfData) {
        $row = new \histou\grafana\Row($perfData['host'].' '.$perfData['service']);
        $panel = \histou\grafana\graphpanel\GraphPanelFactory::generatePanel($perfData['host'].' '.$perfData['service']." utilization");
        foreach ($perfData['perfLabel'] as $key => $values) {
            if(!preg_match('/^(.*?)_utilization$/', $key, $hit)) {
                continue;
            }

            #$panel->setLeftUnit("%");
            $target = $panel->genTarget($perfData['host'], $perfData['service'], null, $key, null, '', false, null);
            $target = $panel->addWarnToTarget($target, $key);
            $target = $panel->addCritToTarget($target, $key);
            $panel->addTarget($target);

            $downtime = $panel->genDowntimeTarget($perfData['host'], $perfData['service'], null, $key, '', false, null);
            $panel->addTarget($downtime);
        }

        $row->addPanel($panel);
        $dashboard->addRow($row);
    };

    $addPanelRates($dashboard, $perfData);
    $addPanelUtilization($dashboard, $perfData);

    $dashboard->addDefaultAnnotations($perfData['host'], $perfData['service']);
    return $dashboard;
};
