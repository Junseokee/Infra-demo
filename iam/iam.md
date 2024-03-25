```bash
# Environment variables
export REGION=ap-northeast-2
export CLUSTER=es-app
BUCKET=es-monitoring-bucket # S3 bucket name
# Acoount ID
echo ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

# OIDC ID
OIDC_ID=$(aws eks describe-cluster --name $CLUSTER --region $REGION \
--query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
aws iam list-open-id-connect-providers | grep $OIDC_ID | cut -d "/" -f4


aws iam create-policy \
--policy-name ${BUCKET} \
--policy-document file://${policy}.json


aws iam create-role \
--role-name ${s3-bucket} \
--assume-role-policy-document file://${trust}.json

aws iam attach-role-policy --role-name es-monitoring-policy \
--policy-arn arn:aws:iam::123456789010:policy/es-monitoring-policy

```