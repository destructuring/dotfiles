#!/usr/bin/env bash

set -exfu

export AWS_REGION=us-west-1

~/bin/e aws ec2 describe-regions