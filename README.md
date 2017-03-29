# JBoss ActiveMQ Nagios Plugin
This Nagios / Icinga Plugin checks if Queues are in paused state. The information is obtained via the Jolokia REST interface.

## Requirements
- JBoss AMQ (Tested with 6.x)
- bash
- curl

## How to use
Sample:
  ./check_amq_paused_queues.sh [user] [password] [queuename]

Inside the Script is a configuration section. Currently i see no need to pass those variables as parameters. This configuration variables are about:

- ActiveMQ Host (default: localhost)
- HTTP Port (default: 8181)
- Broker Name
 
 ## Integrating
 ### For using with NRPE (ensure nrpe.conf is not world-readable)
   command[check_queuename]=/path/to/check_amq_paused_queues.sh [user] [password] [queuename]
 
 ### For using with check_by_ssh
   check_by_ssh -H [AMQ-Server] -C "/path/to/check_amq_paused_queues.sh [user] [password] [queuename]"
 
### Remote call to Jolokia REST Interface

By editing the AMQHOST Variable inside the Script, you are able to perform the query from a remote host.

