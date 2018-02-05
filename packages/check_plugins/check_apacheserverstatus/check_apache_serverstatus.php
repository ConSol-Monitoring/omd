<?php

#
# The MIT License (MIT)
#
# Copyright (c) 2016 Steffen Schoch - dsb it services GmbH & Co. KG
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

#
# Feel free to contact me via email: schoch@dsb-its.net
#

# 2016-01-## schoch - 1.0 - Init...


// Process-Informationen
$opt[1] = " --vertical-label \"#\" --title \"Apache Server-Status for $hostname\" --lower-limit 0 ";
$ds_name[1] = 'Server-Status';

// Scoreboard to var1 - var11
$def[1] = "DEF:var1=$RRDFILE[1]:$DS[1]:AVERAGE " ;
$def[1] .= "DEF:var2=$RRDFILE[2]:$DS[2]:AVERAGE " ;
$def[1] .= "DEF:var3=$RRDFILE[3]:$DS[3]:AVERAGE " ;
$def[1] .= "DEF:var4=$RRDFILE[4]:$DS[4]:AVERAGE " ;
$def[1] .= "DEF:var5=$RRDFILE[5]:$DS[5]:AVERAGE " ;
$def[1] .= "DEF:var6=$RRDFILE[6]:$DS[6]:AVERAGE " ;
$def[1] .= "DEF:var7=$RRDFILE[7]:$DS[7]:AVERAGE " ;
$def[1] .= "DEF:var8=$RRDFILE[8]:$DS[8]:AVERAGE " ;
$def[1] .= "DEF:var9=$RRDFILE[9]:$DS[9]:AVERAGE " ;
$def[1] .= "DEF:var10=$RRDFILE[10]:$DS[10]:AVERAGE " ;
$def[1] .= "DEF:var11=$RRDFILE[11]:$DS[11]:AVERAGE " ;

// WAIT
$def[1] .= "AREA:var1#ff0000:\"Waiting for connection             \":STACK ";
$def[1] .= "GPRINT:var1:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var1:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var1:MAX:\"%4.0lf max\\n\" " ;

// START
$def[1] .= "AREA:var2#FF8000:\"Starting up                        \":STACK ";
$def[1] .= "GPRINT:var2:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var2:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var2:MAX:\"%4.0lf max\\n\" " ;

// READ
$def[1] .= "AREA:var3#ffff00:\"Reading Request                    \":STACK ";
$def[1] .= "GPRINT:var3:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var3:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var3:MAX:\"%4.0lf max\\n\" " ;

// SEND
$def[1] .= "AREA:var4#00FF80:\"Sending Reply                      \":STACK ";
$def[1] .= "GPRINT:var4:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var4:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var4:MAX:\"%4.0lf max\\n\" " ;

// KEEPALIVE
$def[1] .= "AREA:var5#00FFFF:\"Keepalive (read)                   \":STACK ";
$def[1] .= "GPRINT:var5:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var5:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var5:MAX:\"%4.0lf max\\n\" " ;

// DNS
$def[1] .= "AREA:var6#0080FF:\"DNS Lookup                         \":STACK ";
$def[1] .= "GPRINT:var6:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var6:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var6:MAX:\"%4.0lf max\\n\" " ;

// CLOSE
$def[1] .= "AREA:var7#0000FF:\"Closing connection                 \":STACK ";
$def[1] .= "GPRINT:var7:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var7:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var7:MAX:\"%4.0lf max\\n\" " ;

// LOGGING
$def[1] .= "AREA:var8#8000FF:\"Logging                            \":STACK ";
$def[1] .= "GPRINT:var8:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var8:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var8:MAX:\"%4.0lf max\\n\" " ;

// GRACEFUL
$def[1] .= "AREA:var9#FF00FF:\"Gracefully finishing               \":STACK ";
$def[1] .= "GPRINT:var9:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var9:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var9:MAX:\"%4.0lf max\\n\" " ;

// IDLE
$def[1] .= "AREA:var10#FF80FF:\"Idle cleanup of worker             \":STACK ";
$def[1] .= "GPRINT:var10:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var10:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var10:MAX:\"%4.0lf max\\n\" " ;

// FREE
$def[1] .= "AREA:var11#D0D0D0:\"Open slot with no current process  \":STACK ";
$def[1] .= "GPRINT:var11:LAST:\"%4.0lf last\" " ;
$def[1] .= "GPRINT:var11:AVERAGE:\"%4.0lf avg\" " ;
$def[1] .= "GPRINT:var11:MAX:\"%4.0lf max\\n\" " ;


// Draw last line
if($this->MACRO['TIMET'] != ""){
    $def[1] .= "VRULE:".$this->MACRO['TIMET']."#000000:\"Last Service Check \\n\" ";
}


// apache >= 2.4? Build chart for rates (if data exists)
if(isset($DS[12])) {
    // Request per Second
    $opt[2] = " --vertical-label \"#\" --title \"Apache Requests per Second for $hostname\" --lower-limit 0 ";
    $ds_name[2] = 'Server-Status';
    $def[2] = "DEF:var12=$RRDFILE[12]:$DS[12]:AVERAGE " ;
    $def[2] .= "LINE1:var12#ffae2d:\"Requests per Second        \" ";
    $def[2] .= "GPRINT:var12:LAST:\"%4.0lf last\" " ;
    $def[2] .= "GPRINT:var12:AVERAGE:\"%4.0lf avg\" " ;
    $def[2] .= "GPRINT:var12:MAX:\"%4.0lf max\\n\" " ;

    // Bytes per Second and Bytes per Request
    $opt[3] = " --vertical-label \"#\" --title \"Apache Bytes per ... for $hostname\" --lower-limit 0 ";
    $ds_name[3] = 'Server-Status';
    $def[3] = "DEF:var13=$RRDFILE[13]:$DS[13]:AVERAGE " ;
    $def[3] .= "DEF:var14=$RRDFILE[14]:$DS[14]:AVERAGE " ;
    $def[3] .= "LINE1:var13#db60f7:\"Bytes per Second           \" ";
    $def[3] .= "GPRINT:var13:LAST:\"%4.0lf last\" " ;
    $def[3] .= "GPRINT:var13:AVERAGE:\"%4.0lf avg\" " ;
    $def[3] .= "GPRINT:var13:MAX:\"%4.0lf max\\n\" " ;
    $def[3] .= "LINE1:var14#5fe27b:\"Bytes per Request          \" ";
    $def[3] .= "GPRINT:var14:LAST:\"%4.0lf last\" " ;
    $def[3] .= "GPRINT:var14:AVERAGE:\"%4.0lf avg\" " ;
    $def[3] .= "GPRINT:var14:MAX:\"%4.0lf max\\n\" " ;
}

?>
