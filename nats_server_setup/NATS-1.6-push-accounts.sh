#!/bin/bash
#
# This will push all NSC accounts and user to NATS

echo "==> Push NSC accounts and user to NATS"
CMD='nsc push -A'
echo $CMD >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
${CMD} >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file
echo >>$MY_NATS_HOME/NATS_log_file 2>>$MY_NATS_HOME/NATS_log_file