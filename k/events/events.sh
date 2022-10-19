#!/usr/bin/env bash

# pod create cm feh$(date +%s) --from-file=script=events.sh
# pod logs -f -l events.argoproj.io/trigger=run-this

set -exfu

~/bin/e kubectl get pods
exec sleep 60