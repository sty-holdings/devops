#!/bin/bash
#
# This will create the nats context for SYS and the SavUp Account

echo "==> Creating the SYS context"
CMD='nats context save styh_sys --nsc nsc://styh/SYS/sys'
echo $CMD >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file

echo "==> Creating the savuo context"
CMD='nats context save styh_savup --nsc nsc://styh/SAVUP/savup'
echo $CMD >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
