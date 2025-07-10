runtime="5 minutes"
endtime=$(date -ud "$runtime" +%s)
print_status=1
while [[ $(date -u +%s) -le $endtime ]]
do
   STATUS=$(kubectl get pods -n containerized-apps -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}')
   if [ $print_status -eq 1 ]; then
      echo $STATUS
      print_status=0
   fi
   if [[ "$STATUS" =~ ^'True' ]]
   then
      sleep .3
      export IP_ADDRESS=$(kubectl get service jboss-cluster-hi-availability-service-demo -n containerized-apps --output 'jsonpath={..status.loadBalancer.ingress[0].ip}')
      echo -e "\nService IP Address: $IP_ADDRESS"
      break
   else
      echo -n .
      sleep 1
   fi
done
