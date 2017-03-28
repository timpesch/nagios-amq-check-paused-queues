#!/bin/bash

##############################################################
#
# Configuration
#
##############################################################

AMQHOST="localhost"
HTTPPORT="8181"
BROKERNAME="amq"

# Getting lines short, setting Broker-Name
JOLOKIA="/hawtio/jolokia/read/org.apache.activemq:type=Broker,brokerName=$BROKERNAME"



# QA check if all parameters are passed to the script

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
	then
		echo "Unknown - manual located inside the script"
		exit 3
fi


# QA Check for valid creds and if queue exists

if ! curl -s -u $1:$2 "http://$AMQHOST:$HTTPPORT$JOLOKIA,destinationType=Queue,destinationName=$3/Name" | grep \"value\"\:\"$3\" >/dev/null;
	then
		echo "Unknown - Check Queuename or Credentials"
		exit 3
fi


# Check if queue is paused

if curl -s -u $1:$2 "http://$AMQHOST:$HTTPPORT$JOLOKIA,destinationType=Queue,destinationName=$3/Paused" | grep "\"value\"\:false\," >/dev/null;
	then
		echo "OK - Queue is running"
		exit 0
        else
                echo "Crit - Queue is paused"
		exit 2
fi



