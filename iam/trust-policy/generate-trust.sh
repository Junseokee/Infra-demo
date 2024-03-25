#!/bin/bash

# Define environment variables
ACCOUNT="123456789010"
REGION="ap-northeast-2"
OIDC="CDB14466CCA7813CFC370FBC8B73A414"
NAMESPACE="tempo"
SERVICE_ACCOUNT="tempo"
FILE_NAME="tempo"

# Read the template file
TEMPLATE=$(cat oidc-trust.json.template)

# Replace placeholders with environment variable values
POLICY=${TEMPLATE//\{account\}/$ACCOUNT}
POLICY=${POLICY//\{region\}/$REGION}
POLICY=${POLICY//\{oidc\}/$OIDC}
POLICY=${POLICY//\{namespace\}/$NAMESPACE}
POLICY=${POLICY//\{serviceAccount\}/$SERVICE_ACCOUNT}

# Output the final policy
echo "$POLICY" > ${FILE_NAME}-trust.json
