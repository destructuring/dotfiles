#!/usr/bin/env bash

# control create cm feh$(date +%s) --from-file=script=events.sh
# control logs -f -l events.argoproj.io/trigger=run-this

set -exfu

export AWS_REGION=us-west-1

env | grep AWS_

echo ~/bin/e aws ec2 describe-regions

true