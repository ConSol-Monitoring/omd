<?php
/**
This template is used for snclients check_drive_io.
**/

$rule = new \histou\template\Rule(
    $host = '.*',
    $service = '.*',
    $command = '.*',
    $perfLabel = array('swap_in', 'swap_out')
);

$genTemplate = function ($perfData) {
    $dashboard = \histou\grafana\dashboard\DashboardFactory::generateDashboard($perfData['host'].'-'.$perfData['service']);

    $row = new \histou\grafana\Row($perfData['host'].' '.$perfData['service']);
    $panel = \histou\grafana\graphpanel\GraphPanelFactory::generatePanel($perfData['host'].' '.$perfData['service']);
    foreach ($perfData['perfLabel'] as $key => $values) {
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
    $panel->negateY('/swap_out.*/');
    $panel->addRegexColor('/swap_in.*/', '#085DFF', 3);
    $panel->addRegexColor('/swap_out.*/', '#4707ff', 3);

    $row->addPanel($panel);
    $dashboard->addRow($row);

    $dashboard->addDefaultAnnotations($perfData['host'], $perfData['service']);
    return $dashboard;
};
