#!/bin/bash
#
# This will push all NSC accounts and user to NATS

echo "==> Push NSC accounts and user to NATS"
CMD='nsc push -A'
echo $CMD >>NATS_log_file 2>>NATS_log_file
${CMD} >>NATS_log_file 2>>NATS_log_file
echo >>NATS_log_file 2>>NATS_log_file