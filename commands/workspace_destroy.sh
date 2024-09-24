#!/usr/bin/env bash

workspace_name=$1

echo "[INFO] Destroying Workspace: ${workspace_name}"
if [ "$workspace_name" != "default" ]; then
  terraform workspace select default
  tfenv terraform workspace delete "${workspace_name}" || echo "[INFO] Workspace does not exist: ${workspace_name}"
else
  echo "[WARN] Not Destroying default Workspace"
fi
