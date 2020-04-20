#!/bin/bash

echo "------------------------------------------------------------------------"
echo "--------------------  ONAP Security tests   ----------------------------"
echo "--------------------  Test pods without limit   ------------------------"
echo "------------------------------------------------------------------------"

code=0

# get the pod list
for pod in `kubectl get pod -n onap|grep -v "NAME"|grep "Running\|Completed" |grep -v functest |grep -v integration | awk '{print $1}'`;do
  kubectl describe pod $pod -n onap|grep "Limits";
  if [ $? == 1 ] ; then
    echo $pod ;
  fi;
done | grep -v Limits  > NoLimitContainer.txt

if [ -s NoLimitContainer.txt ]
then
   code=1
   nb_errors=`cat NoLimitContainer.txt | wc -l`
   echo "Test FAIL: $nb_errors pod(s) launched without limit"
   cat NoLimitContainer.txt
else
  echo "Test PASS: No pod launched without limit"
fi

exit $code
