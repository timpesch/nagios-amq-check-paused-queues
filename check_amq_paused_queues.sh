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
        echo "   Pause Check:"
        echo "              -p       Check if Queue is in paused state"
        echo ""
        echo "   Queuesize Check:"
        echo "              -s       Checks the Queuesize"
        echo "              -w       Warn Value"
        echo "              -c       Crit Value"


        echo ""
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

function check_queuesize()
{
        OUT=$(curl -s -u $username "http://$AMQHOST:$HTTPPORT$JOLOKIA,destinationType=Queue,destinationName=$queue/QueueSize")

        # Check Status Code
        if echo $OUT | grep '"status":200' >/dev/null
                then
                        QUEUESIZE=$(echo $OUT | cut -d'}' -f2 | cut -d':' -f2 | cut -d',' -f1)

                        if [ $QUEUESIZE -lt $crit_val ] && [ $QUEUESIZE -lt $warn_val ]
                                then
                                        echo "OK - Queuesize $QUEUESIZE"
                                        exit $STATE_OK
                        fi

                        if [ $QUEUESIZE -gt $crit_val ]
                                then
                                        echo "Crit - Queuesize $QUEUESIZE"
                                        exit $STATE_CRIT
                        fi

                        if [ $QUEUESIZE -gt $warn_val ]
                                then
                                        echo "Warn - Queuesize $QUEUESIZE"
                                        exit $STATE_WARN
                        fi

        fi



}


#########################################################
##                      MAIN CODE                      ##
#########################################################

while getopts ":u:q:psw:c:" opt; do
  case $opt in

        u)
        username=$OPTARG
        ;;

        q)
        queue=$OPTARG
        ;;

        p)
        paused_status=true
        check=true
        ;;

        s)
        size_status=true
        check=true
        ;;

        w)
        warn_val=$OPTARG
        ;;

        c)
        crit_val=$OPTARG
        ;;

        \?)
        echo "Invalid option: -$OPTARG" >&2
        ;;

        :)
        print_help
        echo -e "Option -$OPTARG requires an argument.\n" >&2

        exit $STATE_UNKN
        ;;
  esac
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

if [ $size_status ]
        then
                if ! [ -n "$warn_val" ] || ! [ -n "$crit_val" ]
                        then
                                print_help
                                echo "Check Warn and Crit Values"
                                exit $STATE_UNKN
                fi

                check_access
                check_queuesize
fi
