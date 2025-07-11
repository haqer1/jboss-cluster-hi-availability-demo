# Get application gateway id from AKS addon profile
appGatewayId=$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP_NAME -o tsv \
	--query "addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId")

# Get Application Gateway subnet id
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv \
	--query "gatewayIPConfigurations[0].subnet.id")

# Get AGIC addon identity
agicAddonIdentity=$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP_NAME -o tsv \
	--query "addonProfiles.ingressApplicationGateway.identity.clientId")

# Assign network contributor role to AGIC addon ID to subnet that contains the Application Gateway
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId \
	--role "Network Contributor"

# Optional
az role assignment list --assignee $agicAddonIdentity --scope $appGatewaySubnetId