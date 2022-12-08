#!/bin/bash
#
# This will create the nats context for SYS and the SavUp Account

echo "==> Creating the SYS context"
CMD='nats context save styh_sys --nsc nsc://styh/SYS/sys'
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file
echo >>NATS_log_file 2>>NATS_log_file

echo "==> Creating the savuo context"
CMD='nats context save styh_savup --nsc nsc://styh/SAVUP/savup'
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file
echo >>NATS_log_file 2>>NATS_log_file
