export RANDOM_ID="$(openssl rand -hex 2)"
export DEMO=jbossReplicationDemo
export RESOURCE_GROUP_NAME="${DEMO}RG$RANDOM_ID"
export REGION="francecentral"
export AKS_CLUSTER_NAME="${DEMO}Cluster$RANDOM_ID"
export APP_GATEWAY_NAME=${DEMO}Gateway
export DNS_LABEL="${DEMO}DnsLabel$RANDOM_ID"