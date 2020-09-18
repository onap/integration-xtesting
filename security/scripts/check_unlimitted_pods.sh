#!/bin/bash
usage() {
  cat <<EOF
Usage: $(basename $0) <k8s-namespace> [-l <white list file>]
    -l: unlimitted pod xfail file
EOF
  exit ${1:-0}
}

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

K8S_NAMESPACE=$1
FILTERED_PODS_LIST=$(mktemp unlimitted_pods_XXXXXX)
WL_RAW_FILE_PATH=$(mktemp raw_filtered_unlimitted_XXXXXX)

manage_list() {
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
       -l) WL_FILE_PATH=$3;manage_list;shift;;
        -*) usage 1 ;;
         *) break ;;
    esac
done

echo "------------------------------------------------------------------------"
echo "--------------------  ONAP Security tests   ----------------------------"
echo "--------------------  Test pods without limit   ------------------------"
echo "------------------------------------------------------------------------"

code=0

# get the pod list
for pod in `kubectl get pod -n $K8S_NAMESPACE |grep -v "NAME"|grep "Running\|Completed" |grep -v functest |grep -v integration | awk '{print $1}'`;do
  kubectl describe pod $pod -n onap|grep "Limits";
  if [ $? == 1 ] ; then
    echo $pod ;
  fi;
done | grep -v Limits  > $FILTERED_PODS_LIST

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
   echo "Test FAIL: $nb_errors pod(s) launched without limit"
   cat $FILTERED_PODS_LIST
else
  echo "Test PASS: No pod launched without limit"
fi

exit $code
