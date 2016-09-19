#!/bin/bash
#
# Author: Antonino Abbate
# Version: 1.3
# License: GNU GENERAL PUBLIC LICENSE Version 3
# 
# -----------------------------------------------------------------------------------------------------
#  Plugin Description
# -----------------------------------------------------------------------------------------------------
# 
# This script checks the docker container internal Memory usage
#
# Usage:
# ./check_container_memory.sh <container name> -w <warning threshold> -c <critical threshold>
#
#
# Output:
# OK       - if the Memory usage is under the warning and critical thresholds
# WARNING  - if the Memory usage is equal or over the warning threshold and it is under the critical threshold
# CRITICAL - if the Memory usage is equal or over the critical threshold
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

VERSION="$(docker -v | awk '{print $3}')"

CONTAINER=$1

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
#   Check the container internal memory usage
#----------------------------------------------------------------------------------------------------------

  if [ $VERSION \< '1.9.%%' ] && [ $VERSION != '1.10.2,' ]; then
   MEMORY="$(docker stats --no-stream $CONTAINER | grep -A1 CONTAINER |grep -v CONTAINER | awk '{print $6}')"
  else
   MEMORY="$(docker stats --no-stream $CONTAINER | grep -A1 CONTAINER |grep -v CONTAINER | awk '{print $8}')"
  fi
  if [ $warn -lt ${MEMORY%%.*} ]; then
     if [ $crit -lt ${MEMORY%%.*} ]; then
         echo "CRITICAL - Memory Usage = $MEMORY"
         exit 2
     else
         echo "WARNING - MEMORY Usage = $MEMORY"
         exit 1
        fi
  else
     echo "OK - MEMORY Usage = $MEMORY"
     exit 0
fi
else
  echo "$0 - Nagios Plugin for checking MEMORY usage in a running docker container "
  echo ""
  echo "Usage:    $0 -w <warnlevel> -c <critlevel>"
  echo "  = warnlevel and critlevel is warning and critical value for alerts. "
  echo ""
  echo "EXAMPLE:  $0 <container_name> -w 80 -c 90 "
  echo "  = This will send warning alert when Memory Usage percentage is higher than 80%, and send critical when higher than 90%"
  echo ""
  exit 3
fi
