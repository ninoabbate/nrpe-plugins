#!/bin/bash
#
# Author: Antonino Abbate
# Version: 1.2
# License: GNU GENERAL PUBLIC LICENSE Version 3
# 
# -----------------------------------------------------------------------------------------------------
#  Plugin Description
# -----------------------------------------------------------------------------------------------------
#
# This script checks the docker container internal CPU usage
#
# Usage:
# ./check_container_cpu.sh <container name> -w <warning threshold> -c <critical threshold>
#
#
# Output:
# OK       - if the CPU usage is under the warning and critical thresholds
# WARNING  - if the CPU usage is equal or over the warning threshold and it is under the critical threshold
# CRITICAL - if the CPU usage is equal or over the critical threshold
# UNKNOWN  - if the container does not exist
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
#   Initialization 
#----------------------------------------------------------------------------------------------------------

CONTAINER=$1

CPUCORES=$(docker info | grep CPUs | awk '{print $2}')

RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

#----------------------------------------------------------------------------------------------------------
#   Check if container exists
#----------------------------------------------------------------------------------------------------------

if [ $? -eq 1 ]; then
  echo "UNKNOWN - $CONTAINER does not exist."
  exit 3
fi

if [ "$2" = "-w" ] && [ "$3" -gt "0" ] && [ "$4" = "-c" ] && [ "$5" -gt "0" ] ; then
  warn=$3
  crit=$5

#----------------------------------------------------------------------------------------------------------
#   Check the container internal cpu usage
#----------------------------------------------------------------------------------------------------------

  CPUUSAGE="$(docker stats --no-stream $CONTAINER | grep -A1 CONTAINER | grep -v CONTAINER | awk '{print $2}')"

  CPU=$(expr ${CPUUSAGE%%.*} / ${CPUCORES})

  if [ $warn -lt ${CPU%%.*} ];then
    if [ $crit -lt ${CPU%%.*} ]; then
      echo "CRITICAL - CPU Usage = $CPU% | CPU Usage=$CPU%;$warn;$crit;0;100"
      exit 2
    else
      echo "WARNING - CPU Usage = $CPU% | CPU Usage=$CPU%;$warn;$crit;0;100"
      exit 1
    fi
  else
    echo "OK - CPU Usage = $CPU% | CPU Usage=$CPU%;$warn;$crit;0;100"
    exit 0
fi
else
  echo "$0 - Nagios Plugin for checking CPU usage in a running docker container "
  echo ""
  echo "Usage:    $0 -w <warnlevel> -c <critlevel>"
  echo "  = warnlevel and critlevel is warning and critical value for alerts. "
  echo ""
  echo "EXAMPLE:  $0 <container_name> -w 80 -c 90 "
  echo "  = This will send warning alert when CPU Usage percentage is higher than 80%, and send critical when higher than 90%"
  echo ""
  exit 3
fi