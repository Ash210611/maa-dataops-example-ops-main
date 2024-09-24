#!/bin/bash

ENV=$1

cd "$(dirname "${0}")/third_party/aws_fed" || exit
unset AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
echo Federating as: $AWS_FED_USERNAME
echo Environment: ${ENV}
aws-fed login "${ENV}-deploy" -f aws-fed.toml
