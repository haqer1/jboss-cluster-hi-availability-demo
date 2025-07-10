az group create --name $RESOURCE_GROUP_NAME --location $REGION
sleep 8
#az aks create --resource-group $RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME --node-count 1 --generate-ssh-keys
az aks create -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP_NAME --network-plugin azure \
	--enable-managed-identity -a ingress-appgw --appgw-name $APP_GATEWAY_NAME \
	--generate-ssh-keys
status=$?
echo Status: $status
if [ $status -eq 0 ]; then
	sleep 3
	az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_CLUSTER_NAME
	kubectl describe nodes -n containerized-apps | grep arch
else
	echo "Deleting resource group $RESOURCE_GROUP_NAME (in $REGION) due to error while making"\
		"$AKS_CLUSTER_NAMES:"
	az group delete --name $RESOURCE_GROUP_NAME
fi