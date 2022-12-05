#!/bin/bash
#
# This will push all NSC accounts and user to NATS

echo "==> Push NSC accounts and user to NATS"
CMD='nsc push -A'
${CMD}
