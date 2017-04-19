#!/bin/bash

# State Variables
STATE_OK=0
STATE_WARN=1
STATE_CRIT=2
STATE_UNKN=3


function print_help()
{
        echo ""
        echo "check_amq_paused_queues.sh -u <user>:<password> -q <queuename> <option>"
        echo "check_amq_paused_queues.sh -u admin:test123 -q name.of.queue -p"
        echo ""
        echo "   Parameters:"
        echo "              -u       User name and password. REQUIRED OPTION"
        echo "              -q       Name of Queue you want to check. REQUIRED OPTION"
        echo ""
        echo "              -q       Check if Queue is in paused state"
        echo ""
        exit $STATE_UNKN
}

function check_access()
{
        # QA Check for valid creds and if queue exists
        if ! curl -s -u $username "http://$AMQHOST:$HTTPPORT$JOLOKIA,destinationType=Queue,destinationName=$queue/Name" | grep \"value\"\:\"$queue\" >/dev/null;
                then
                        echo "Unknown - Check Queuename or Credentials"
                        exit $STATE_UNKN
        fi
}

function check_paused()
{
        # Check if queue is paused
        if curl -s -u $username "http://$AMQHOST:$HTTPPORT$JOLOKIA,destinationType=Queue,destinationName=$queue/Paused" | grep "\"value\"\:false\," >/dev/null;
                then
                        echo "OK - Queue is running"
                        exit $STATE_OK
                else
                        echo "Crit - Queue is paused"
                        exit $STATE_CRIT
        fi
}


#########################################################
##                      MAIN CODE                      ##
#########################################################

# Make sure the correct number of command line arguments have been supplied
if [[ $# -eq 0 ]]; then
        print_help
        exit $STATE_UNKN
fi

# Make sure all necessary arguments were given; EXIT with an UNKNOWN status if not
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        -u)
            username=$2
            shift
            ;;
        -p)
            paused_status=true
            check=true
            shift
            ;;
        -q)
            queue=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit $STATE_UNKN
            ;;
    esac
    shift
done


#########################################################
##                    CONFIGURATION                    ##
#########################################################

AMQHOST="localhost"
HTTPPORT="8181"
BROKERNAME="amq"

# Getting lines short, setting Broker-Name
JOLOKIA="/hawtio/jolokia/read/org.apache.activemq:type=Broker,brokerName=$BROKERNAME"


#########################################################
##                    INTELLIGENCE                     ##
#########################################################

# QA check if all parameters are passed to the script
if [ -z "$username" ] || [ -z "$queue" ] || [ -z $check ]
        then
                print_help
fi

if [ $paused_status ]
        then
                check_access
                check_paused
fi
