#!/usr/bin/env bash

usage() {
  cat <<EOF
Usage: $(basename $0) <k8s-namespace> [-r <recommended versions file>]
    -r: recommended versions file
EOF
  exit ${1:-0}
}

if [ "$#" -lt 1 ]; then
  usage 1
fi

K8S_NAMESPACE=$1
VERSIONS=$(mktemp versions_XXXXXX)

### getopts
while :
do
  case $2 in
    -h|--help|help) usage ;;
    -r) RECOMMENDED_VERSIONS_FILE_PATH=$3;shift ;;
    -*) usage 1 ;;
     *) break ;;
  esac
done

get_recommendation() {
  local component="$1"
  local recommendations="${RECOMMENDED_VERSIONS_FILE_PATH:-recommended_versions.yaml}"

  yq read "$recommendations" "${component}.recommended_versions" | sed 's/^- //' # removes YAML list prefix
}

check_python3_version() {
  local recommended_versions="${1:-$(get_recommendation python3)}"
  local versions="${2:-$VERSIONS}"

  local unrecommended="$(cat $versions)" # to be filtered out according to recommendations
  for rver in $recommended_versions; do
    unrecommended="$(jq --arg rver "$rver" \
      '.[] | select(.versions.python[]!=$rver) | "\(.pod) \(.container) \(.versions.python[])"' \
      <(echo "$unrecommended") \
      | tr -d '"' \
      | sort -u)"
  done

  echo "$unrecommended"
}

check_java11_version() {
  local recommended_versions="${1:-$(get_recommendation java11)}"
  local versions="${2:-$VERSIONS}"

  local unrecommended="$(cat $versions)" # to be filtered out according to recommendations
  for rver in $recommended_versions; do
    unrecommended="$(jq --arg rver "$rver" \
      '.[] | select(.versions.java[]!=$rver) | "\(.pod) \(.container) \(.versions.java[])"' \
      <(echo "$unrecommended") \
      | tr -d '"' \
      | sort -u)"
  done

  echo "$unrecommended"
}

echo "------------------------------------------------------------------------"
echo "--------------------  ONAP Security tests   ----------------------------"
echo "--------------------  Test components versions in pods   ---------------"
echo "------------------------------------------------------------------------"

code=0

# get the components versions list
python3 /check_versions/k8s_bin_versions_inspector.py \
  -i -c /root/.kube/config -f json \
  -s "metadata.namespace==$K8S_NAMESPACE" > "$VERSIONS"

unrecommended_python="$(check_python3_version)"
unrecommended_java="$(check_java11_version)"

if [ -z "$unrecommended_python" -a -z "$unrecommended_java" ]; then
  echo "Test PASS: All components available in recommended versions only"
else
  code=1
  echo "Test FAIL: Components other than recommended versions found"
  cat <(echo POD CONTAINER PYTHON) <(echo "$unrecommended_python") | column -t -s' '
  cat <(echo POD CONTAINER JAVA) <(echo "$unrecommended_java") | column -t -s' '
fi

exit "$code"
