#!/usr/bin/env bash

workspace_name=$1

terraform workspace select ${workspace_name} || terraform workspace new ${workspace_name}
