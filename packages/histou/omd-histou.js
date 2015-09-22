/* global _ */

// accessible variables in this scope
var window, document, ARGS, $, jQuery, moment, kbn;

//parse arguments
parseArgs()


return function(callback) {

    //Remove Lines over Gap where are no points
    (function ($) {
        function init(plot) {
            function fixGaps(plot, series, datapoints) {
                    var points = datapoints.points, stepSize = datapoints.pointsize;
                    var timerangeInMillisec = points[points.length-stepSize]-points[0];
                    var datapoints = series.data.length;
                    var avgTimeBetweenPoints = timerangeInMillisec / datapoints;
                    var indices = [];
                    for (var i = stepSize; i < points.length; i += stepSize){
                            if ((points[i]-points[i-stepSize]) > avgTimeBetweenPoints*2){
                                    indices.push(i)
                            }
                    }
                    for (var i = 0; i < indices.length; i++){
                            var pointIndex = indices[i];
                            var oldTimestamp = points[pointIndex];
                            points.splice(indices[i],0,null);
                            points.splice(indices[i],0,null);
                            points.splice(indices[i],0,null);
                    }
            }
            plot.hooks.processDatapoints.push(fixGaps);
        }

        $.plot.plugins.push({
            init: init,
            options: {},
            name: "fixMeasurementGaps",
            version: "0.1"
        });
    })(jQuery);


    site = window.location.href.match(/(https?:\/\/.*?\/.*?)\/grafana\/.*/);
    if(site.length > 1){
        url = site[1]+'/histou/index.php';
    }

    configUrl = url+'?host='+host+'&service='+service+'&height='+height+'&legend='+legend+debug;

    $.ajax({
        method: 'GET',
        url: configUrl,
        dataType: "jsonp",
    }).done(function(result) {
        console.log(result);
        callback(result);
    }).fail(function(result) {
        console.log(result);
        console.log(configUrl);
        if(result.status == 200){
            callback(createErrorDashboard('# HTTP code: '+result.status+'\n# Message: '+result.statusText+'\n# Url: '+configUrl+'\n# Probably the output is not valid json, because the returncode is 200!'));
        }else{
            callback(createErrorDashboard('# HTTP code: '+result.status+'\n# Message: '+result.statusText+'\n# Url: '+configUrl));
        }
    });
}

function createErrorDashboard(message) {
    return {
            rows : [{
                title: 'Chart',
                height: '300px',
                panels : [{
                    title: 'Error Message below',
                    type: 'text',
                    span: 12,
                    fill: 1,
                    content: message,
                  }]
            }],
            services : {},
            title : 'JS Error / HTTP Error'
        };
}

function parseArgs() {
    if(!_.isUndefined(ARGS.reduce)) {
        $('head').append('<style>.panel-fullscreen {top:0}</style>');

        //change ui to our needs
        clearUi()
    }
    if(!_.isUndefined(ARGS.host)) {
        host = ARGS.host;
    }else{
        host = "Host0"
    }

    if(!_.isUndefined(ARGS.service)) {
        service = ARGS.service;
    }else{
        service = ""
    }

    if(!_.isUndefined(ARGS.command)) {
        command = ARGS.command;
    }else{
        command = ""
    }

    if(!_.isUndefined(ARGS.perf)) {
        perf = ARGS.perf;
    }else{
        perf = ""
    }

    if(!_.isUndefined(ARGS.height)) {
        height = ARGS.height;
    }else{
        height = ""
    }

    if(_.isUndefined(ARGS.debug)) {
        debug = '';
    }else{
        debug = "&debug"
    }

    if(!_.isUndefined(ARGS.legend)) {
        legend = ARGS.legend;
    }else{
        legend = true
    }
}

function clearUi() {
    //removes white space
    var checkExist = setInterval(function() {
         if ($('.panel-content').length) {
            clearInterval(checkExist);
            document.getElementsByClassName("panel-content")[0].style.paddingBottom = '0px';
         }
    }, 100);
    /*
        .panel-header removes the headline of the graphs
        .navbar-static-top removes the menubar on the top
        .row-control-inner removes the row controll button on the left
        .span12 removes the add new row button on the bottom
    */
    divs = ['.panel-header','.navbar-static-top','.row-control-inner','.span12']
    for (index = 0; index < divs.length; index++) {
        waitForDivAndDeleteIt(divs[index]);
    }
    function waitForDivAndDeleteIt(div){
        var checkExist = setInterval(function() {
            if ($(div).length) {
                clearInterval(checkExist);
                $(div).remove();
            }
        }, 100);
    }
}

