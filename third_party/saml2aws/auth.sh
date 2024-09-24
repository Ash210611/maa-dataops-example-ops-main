#!/bin/bash
set -e -o pipefail

export ENV="${1:-local}"
export REGION="${2:-us-east-1}"

cd "$(dirname "${0}")/third_party/saml2aws"
source commands/pre.sh