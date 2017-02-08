#!/bin/bash
#
# Author: Antonino Abbate
# Version: 1.0
# License: GNU GENERAL PUBLIC LICENSE Version 3
# 
# -----------------------------------------------------------------------------------------------------
#  Plugin Description
# -----------------------------------------------------------------------------------------------------
# 
# This script checks the diskspace available to docker daemon
#
# Usage:
# ./check_docker_dataspace.sh -w <warning threshold> -c <critical threshold>
#
#
# Output:
# OK       - if the available disk space is under the warning and critical thresholds
# WARNING  - if the available disk space is equal or over the warning threshold and it is under the critical threshold
# CRITICAL - if the available disk space is equal or over the critical threshold
# UNKNOWN  - if the docker daemon isn't running
#
# ---------------------------------------- License -----------------------------------------------------
# 
# This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>. 
#
#----------------------------------------------------------------------------------------------------------
#   Check if docker is running
#----------------------------------------------------------------------------------------------------------

if [ -z "$(docker ps)" ]; then
  echo "UNKNOWN - Is the docker daemon running on this host?"
  exit 3
fi

#----------------------------------------------------------------------------------------------------------
#   Get docker Data Space stats
#----------------------------------------------------------------------------------------------------------

ALLSTATS="$(docker info | grep Data | grep Space | tr -s [:space:] ' ' | tr -d '\n')" 

SPACETOTAL="$(echo $ALLSTATS | awk '{print $9}')"
SPACEUSED="$(echo $ALLSTATS | awk '{print $4}')"
SPACEAVAIL="$(echo $ALLSTATS | awk '{print $14}')"

#----------------------------------------------------------------------------------------------------------
#   Check the Data Space
#----------------------------------------------------------------------------------------------------------

if [ "$1" = "-w" ] && [ "$2" -lt "101" ] && [ "$3" = "-c" ] && [ "$4" -lt "101" ] ; then
  warn=$2
  crit=$4

  # Calculates rounded percentage of available data space
  AVAILSPACEPERC=$(awk "BEGIN { perc=100*${SPACEAVAIL}/${SPACETOTAL}; i=int(perc); print (perc-i<0.5)?i:i+1 }")

  if [ ${AVAILSPACEPERC} -gt $warn ] && [ ${AVAILSPACEPERC} -gt $crit ];then
    echo "OK - Available Data Space = $AVAILSPACEPERC% | Available space=$AVAILSPACEPERC%;$warn;$crit;0;100"
    exit 0
  elif [ ${AVAILSPACEPERC} -lt $warn ] && [ ${AVAILSPACEPERC} -gt $crit ]; then
    echo "WARNING - Available Data Space = $AVAILSPACEPERC% | Available space=$AVAILSPACEPERC%;$warn;$crit;0;100"
    exit 1
  else
    echo "CRITICAL - Available Data Space = $AVAILSPACEPERC% | Available space=$AVAILSPACEPERC%;$warn;$crit;0;100"
    exit 2
  fi
else
  echo "$0 - Nagios Plugin for checking the diskspace available to docker daemon"
  echo ""
  echo "Usage:    $0 -w <warnlevel> -c <critlevel>"
  echo "  = warnlevel and critlevel is warning and critical value for alerts."
  echo ""
  echo "EXAMPLE:  $0 -w 10 -c 5 "
  echo "  = This will send warning alert when available data space is less than 10%, and send critical when it is less than 5%"
  echo ""
  exit 3
fi
