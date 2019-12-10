#!/bin/bash

echo "------------------------------------------------------------------------"
echo "-------------------  ONAP Check helm charts ----------------------------"
echo "------------------------------------------------------------------------"
code=0
nb_charts=$(helm ls |awk {'print $1'}|grep -v NAME |wc -l)
nb_failed_charts=0
list_failed_charts="[$(helm ls |grep -v DEPLOYED |grep -v NAME |awk '{print $1}')]"
nice_list=$(echo $list_failed_charts |sed  -e "s/ /,/g")

# List Helm chart and get their status
for i in $(helm ls |awk {'print $1'}|grep -v NAME);do
    echo "Chart $i"
    status=$(helm status $i |grep STATUS:)
    echo ${status}
    if [ "${status}" != "STATUS: DEPLOYED" ]; then
        echo "Chart problem"
        helm status $i -o yaml
        code=1
        let "nb_failed_charts++"
    fi
    echo "--------------------------------------------------------------------"
done

echo "------------------------------------------------"
echo "------- ONAP Helm tests ------------------------"
echo "------------------------------------------------"
echo ">>> Nb Helm Charts: ${nb_charts}"
echo ">>> Nb Failed Helm Charts: ${nb_failed_charts}"
echo ">>> List of Failed Helm Charts: ${nice_list}"
echo "------------------------------------------------"
echo "------------------------------------------------"
echo "------------------------------------------------"

exit $code
