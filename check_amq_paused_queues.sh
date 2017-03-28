#!/bin/bash

########################################################################################################
#
# Manual / Simple Nagios Plugin For Checking Queue Status
#
# Sample execution:
# ./check_amq_paused_queues.sh user password queuename
#
# $1 == Username
# $2 == Password
# $3 == Queuename
#
# Example to integrate in NRPE:
#
# command[check_queuename]=/path/to/check_amq_paused_queues.sh user password queuename
#
#
# Questions to Tim Pesch
#
########################################################################################################


# Getting lines short, setting Broker-Name

HAWTIO="/hawtio/jolokia/read/org.apache.activemq:type=Broker,brokerName=amq"


# QA check if all parameters are passed to the script

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
	then
		echo "Unknown - manual located inside the script"
		exit 3
fi


# QA Check for valid creds and if queue exists

if ! curl -s -u $1:$2 "http://localhost:8181$HAWTIO,destinationType=Queue,destinationName=$3/Name" | grep \"value\"\:\"$3\" >/dev/null;
	then
		echo "Unknown - Check Queuename or Credentials"
		exit 3
fi


# Check if queue is paused

if curl -s -u $1:$2 "http://localhost:8181$HAWTIO,destinationType=Queue,destinationName=$3/Paused" | grep "\"value\"\:false\," >/dev/null;
	then
		echo "OK - Queue is running"
		exit 0
        else
                echo "Crit - Queue is paused"
		exit 2
fi



