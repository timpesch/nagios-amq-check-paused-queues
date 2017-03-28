# JBoss ActiveMQ Nagios Plugin
This Nagios / Icinga Plugin checks if Queues are in paused state. The information is obtained via the Jolokia REST interface.

## Requirements
- JBoss AMQ (Tested with 6.x)
- bash
- curl

## How to use
Sample:
  ./check_amq_paused_queues.sh [user] [password] [queuename]
 
 ## Integrating
 For using with NRPE (ensure nrpe.conf is not world-readable)
   command[check_queuename]=/path/to/check_amq_paused_queues.sh [user] [password] [queuename]
 
 For using with check_by_ssh
   check_by_ssh -H [AMQ-Server] -C "/path/to/check_amq_paused_queues.sh [user] [password] [queuename]"
 
Remote call to Jolokia REST Interface


How to use instructions are located inside the script. This plugin will not perform output of perfomance data.
