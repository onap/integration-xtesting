#!/usr/bin/env bash

usage() {
  cat <<EOF
Usage: $(basename $0) <k8s-namespace> [-l <white list file>]
    -l: rooted pod xfail file
EOF
  exit ${1:-0}
}

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

K8S_NAMESPACE=$1
FILTERED_PODS_LIST=$(mktemp rooted_pods_XXXXXX)
WL_RAW_FILE_PATH=$(mktemp raw_filtered_pods_XXXXXX)

manage_white_list() {
  # init filtered port list file
  if [ ! -f $WL_FILE_PATH ];then
   echo "File not found"
   usage
  fi
  grep -o '^[^#]*' $WL_FILE_PATH > $WL_RAW_FILE_PATH
}

### getopts
while :
do
  case $2 in
      -h|--help|help) usage;;
       -l) WL_FILE_PATH=$3;manage_white_list;shift;;
        -*) usage 1 ;;
         *) break ;;
    esac
done

echo "------------------------------------------------------------------------"
echo "--------------------  ONAP Security tests   ----------------------------"
echo "--------------------  Test root user in pods   -------------------------"
echo "------------------------------------------------------------------------"

# Display the waivers
if [ -s $XL_FILE_PATH ]; then
  echo  -e "--------------------\e[0;31m WARNING \e[0;m XFail List    ----------------------------"
  cat $WL_FILE_PATH
  echo "------------------------------------------------------------------------"
fi

code=0

# get the pod list
for pod in `kubectl get pod -n $K8S_NAMESPACE| grep "Running" | grep -v functest | grep -v integration | awk '{print $1}'` ;do
  list=`kubectl top pod $pod --containers -n onap |grep -v "POD"|awk '{print $1":"$2}'`;
  for po in $list; do
    contname=`echo $po|cut -d':' -f2`;uid=`kubectl exec $pod --container $contname -n $K8S_NAMESPACE id|sed -r "s/^uid=(.*) gid.*$/\1/"`;echo "POD: $pod container: $contname uid: $uid";
  done;
done  | grep root > $FILTERED_PODS_LIST

while IFS= read -r line; do
  # for each line we test if it is in the white list with a regular expression
  while IFS= read -r wl_line; do
   wl_name=$(echo $wl_line | awk {'print $1'})
   if grep -e $K8S_NAMESPACE-$wl_name <<< "$line" > /dev/null ;then
       # Found in white list, exclude it
       sed -i "/$line/d" $FILTERED_PODS_LIST
   fi
   # tmp ugly workaround to exlude dep (temporary dcae dockers)
   if grep -e dep-$wl_name <<< "$line" > /dev/null ;then
       sed -i "/$line/d" $FILTERED_PODS_LIST
   fi
  done < $WL_RAW_FILE_PATH
done < $FILTERED_PODS_LIST

if [ -s $FILTERED_PODS_LIST ]
then
   code=1
   nb_errors=`cat $FILTERED_PODS_LIST | wc -l`
   echo "Test FAIL: $nb_errors pod(s) launched as root found"
   cat $FILTERED_PODS_LIST
else
  echo "Test PASS: No pod launched as root found"
fi

exit $code
