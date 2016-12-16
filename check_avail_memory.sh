#!/bin/bash
#
# Author: Antonino Abbate
# Version: 1.1
# License: GNU GENERAL PUBLIC LICENSE Version 3
# 
# -----------------------------------------------------------------------------------------------------------
#  Plugin Description
# -----------------------------------------------------------------------------------------------------------
# 
# This script checks the available memory on a Linux system
#
# Usage:
# ./check_avail_memory.sh -w <warning threshold> -c <critical threshold>
#
#
# Output:
# OK       - if the available memory is above the warning and critical thresholds
# WARNING  - if the available memory is under the warning threshold and it is above the critical threshold
# CRITICAL - if the available memory is under the critical threshold
# 
# ---------------------------------------- License ----------------------------------------------------------
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
# -----------------------------------------------------------------------------------------------------------


# Get the total amount of memory
TOTALMEM=$(free -m | grep Mem | awk '{print $2}')

if [ "$1" = "-w" ] && [ "$2" -lt "101" ] && [ "$3" = "-c" ] && [ "$4" -lt "101" ] ; then
  warn=$2
  crit=$4
  # Get the available memory
  AVAILABLEMEM=$(free -m | grep Mem | awk '{print $7}')
  # Calculates rounded percentage of available memory
  AVAILMEMPERC=$(awk "BEGIN { perc=100*${AVAILABLEMEM}/${TOTALMEM}; i=int(perc); print (perc-i<0.5)?i:i+1 }")

  if [ ${AVAILMEMPERC} -gt $warn ] && [ ${AVAILMEMPERC} -gt $crit ];then
    echo "OK - Available Memory = $AVAILMEMPERC% | Available memory=$AVAILMEMPERC%;$warn;$crit;0;100"
    exit 0
  elif [ ${AVAILMEMPERC} -lt $warn ] && [ ${AVAILMEMPERC} -gt $crit ]; then
    echo "WARNING - Available Memory = $AVAILMEMPERC% | Available memory=$AVAILMEMPERC%;$warn;$crit;0;100"
    exit 1
  else
    echo "CRITICAL - Available Memory = $AVAILMEMPERC% | Available memory=$AVAILMEMPERC%;$warn;$crit;0;100"
    exit 2
  fi
else
  echo "$0 - Nagios Plugin for checking the available memory in a Linux system"
  echo ""
  echo "Usage:    $0 -w <warnlevel> -c <critlevel>"
  echo "  = warnlevel and critlevel is warning and critical value for alerts."
  echo ""
  echo "EXAMPLE:  $0 -w 10 -c 5 "
  echo "  = This will send warning alert when available memory is less than 10%, and send critical when it is less than 5%"
  echo ""
  exit 3
fi
