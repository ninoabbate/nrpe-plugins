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
# USAGE:
# ./check_snorby.sh -i <minutes>
# 
# This script queries the snorby database for high severity events in a time interval.
# The time interval is defined by -i argument, the accepted arguments are integer values.
# 
# Output:
# OK - 0 High severity events in the defined interval
# CRITICAL - 1 or more High severity events in the defined interval
# UNKNOWN - something hasn't been set properly
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
# 	Initialization - Snorby database connection
#----------------------------------------------------------------------------------------------------------
#
# Change these values according to your Snorby installation
#

SNORBY_DB="snorby"
SNORBY_DB_HOST="localhost"
SNORBY_DB_PORT="3306"
SNORBY_DB_USER="snorby"
SNORBY_DB_PASS="snorbypassword"

#----------------------------------------------------------------------------------------------------------
# Time interval
#----------------------------------------------------------------------------------------------------------

INTERVAL=$2

#----------------------------------------------------------------------------------------------------------
# Function to manipulate the date, in order to be acceptable by MySQL 
#----------------------------------------------------------------------------------------------------------

function timemachine {
	FIXEDMINUTES="$INTERVAL minutes ago"
	FIXEDDATE=$(date --date="$FIXEDMINUTES" +%Y-%m-%d' %H:%M:%S')
}

#----------------------------------------------------------------------------------------------------------
# Function to get the number of High severity events in the defined time interval 
#----------------------------------------------------------------------------------------------------------

function getevents {
	mysql_exec="SELECT COUNT(*) FROM snorby.events_with_join WHERE sig_priority=1 AND timestamp >= '$FIXEDDATE';"
	COUNT_LAST=`mysql --skip-column-names -h $SNORBY_DB_HOST -P $SNORBY_DB_PORT -u $SNORBY_DB_USER --password=$SNORBY_DB_PASS -e "$mysql_exec" $SNORBY_DB`

	if [  "$COUNT_LAST" == 0 ]; then
	    echo "OK - 0 High severity events in the defined interval"
	else
	    echo "CRITICAL - "$COUNT_LAST" High severity events in the defined interval"
	fi
}

#----------------------------------------------------------------------------------------------------------
# Check the time interval and get the events number 
#----------------------------------------------------------------------------------------------------------

integer='^[0-9]+$'

    if ! [[ $2 =~ $integer ]] ; then
       echo "UNKNOWN - set the time interval to a integer value" >&2; exit 1
    else
       timemachine
       getevents
    fi