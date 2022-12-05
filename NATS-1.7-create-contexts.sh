#!/bin/bash
#
# This will create the nats context for SYS and the SavUp Account

echo "==> Creating the SYS context"
CMD='nats context save styh_sys --nsc nsc://styh/SYS/sys'
${CMD}

echo "==> Creating the savuo context"
CMD='nats context save styh_savup --nsc nsc://styh/SAVUP/savup'
${CMD}

