# Public IP address of your *ingress controller*
IP="172.189.69.184"

# Name to associate with public IP address
DNSLABEL="jboss-replication-ha-demo"

# Get the resource-id of the public IP
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

# Update public IP address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSLABEL

# Display the FQDN
az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv
