#!/bin/bash

echo "------------------------------------------------------------------------"
echo "--------------------  ONAP Check kubernetes ----------------------------"
echo "------------------------------------------------------------------------"

code=0

# get the pod list
echo "List of ONAP pods"
echo "*****************"
kubectl get pods -n onap

# show deployments
echo "Show ONAP kubernetes deployments"
echo "********************************"
kubectl get deployments -n onap
echo "------------------------------------------------------------------------"

# show SVC
echo "Show ONAP kubernetes SVC"
echo "************************"
kubectl get svc -n onap
echo "------------------------------------------------------------------------"

# show ONAP events
echo "Show ONAP kubernetes events"
echo "***************************"
kubectl get events -n onap
echo "------------------------------------------------------------------------"

# show ONAP config maps
echo "Show ONAP kubernetes config maps"
echo "***************************"
kubectl get cm -n onap
echo "------------------------------------------------------------------------"

# show ONAP jobs
echo "Show ONAP kubernetes jobs"
echo "***************************"
kubectl get jobs -n onap
echo "------------------------------------------------------------------------"

# show ONAP statefulsets
echo "Show ONAP kubernetes statefulset"
echo "***************************"
kubectl get sts -n onap
echo "------------------------------------------------------------------------"

# if all pods in RUNNING state exit 0, else exit 1
nb_pods=$((`kubectl get pods -n onap | grep Running | grep -v functest | wc -l` -1))
list_failed_pods=$(kubectl get pods -n onap |grep -v Running |grep -v functest |grep -v NAME | grep -v Completed | awk '{print $1}')
list_filtered_failed_pods=()

for i in $list_failed_pods;do
    status=$(kubectl get pods -n onap $i | grep -v NAME | awk '{print $3'})
	  # in case of Error or Init:Error
    # we check that another instance is not already Completed or Running
    if [ $status = "Error" ]  || [ $status = "Init:Error" ];then
        echo "$i in Status Error or Init Error found for the pods, is is really true...."
        # By default pod naming is similar, keep only the root to check
        root_name=${i::-6}
        kubectl get pods -n onap | grep $root_name | grep Completed
        if [ $? ];then
            echo "Instance Completed found."
        else
            echo "No Completed instance found."
            list_filtered_failed_pods+=$i,
        fi
    else
        # Other status are not running/not completed pods
        list_filtered_failed_pods+=$i,
    fi
done

nice_list=${list_filtered_failed_pods::-1}

IFS=,
nb_pods_not_running=$(echo "$list_filtered_failed_pods" | tr -cd , | wc -c)

if [ $nb_pods_not_running -ne 0 ]; then
echo "$nb_pods_not_running pods (on $nb_pods) are not in Running state"
echo "---------------------------------------------------------------------"
    kubectl get pods -n onap | grep -v Running | grep -v functest | grep -v Completed
    echo "--------------------------------------------------------------------"
    echo "Describe non running pods"
    echo "*************************"
    for i in $nice_list;do
        echo "****************************************************************"
        kubectl describe pod $i -n onap
        kubectl logs --all-containers=true -n onap $i
    done
    code=1
else
    echo "all pods ($nb_pods) are running well"
fi

echo "------------------------------------------------"
echo "------- ONAP kubernetes tests ------------------"
echo "------------------------------------------------"
echo ">>> Nb Pods: $nb_pods"
echo ">>> Nb Failed Pods: $nb_pods_not_running"
echo ">>> List of Failed Pods: [$nice_list]"
echo "------------------------------------------------"
echo "------------------------------------------------"
echo "------------------------------------------------"

exit $code
