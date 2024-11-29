#!/bin/sh

###########################################
#                                         #
#    ROUTING TRAFFIC BETWEEN SERVICES     #
#                                         #
###########################################

# === VARIABLE === #
namespace=""
route=""
host=""
port=""
svc_main=""
weight_main=100
svc_alter=""
weight_alter=0

# === FUNCTION === #
split_arguments() {
  tmp=$(echo "$1" | tr ':' ' ')
  echo "$tmp"
}


# === MAIN FUNCTION === #

while [[ ${#} -gt 0 ]]; do 
  case "$1" in
    --svc-main) shift 
      var=($(split_arguments "$1"))
      svc_main="${var[0]}"
      weight_main="${var[1]}"
      ;;
    --svc-alter) shift 
      var=($(split_arguments "$1"))
      svc_alter="${var[0]}"
      weight_alter="${var[1]}"
      ;;
    --route) shift 
      route="$1"
      ;;
    --host) shift 
      host="$1"
      ;;
    --port) shift 
      port="$1"
      ;;
    --namespace) shift 
      namespace="$1"
      ;;
    *)
      echo "Invalid parameter: $1"
      exit 1
      ;;
  esac
  shift
done

if [[ $weight_alter -gt 0 ]]; then 
  echo "\
  alternateBackends:
    - kind: Service
      name: ${svc_alter}
      weight: ${weight_alter}" > AlterBackend.yaml
else 
  echo "" > AlterBackend.yaml
fi

echo "$alter_backend"

sed -e "s/{{ .Namespace }}/$namespace/" \
    -e "s/{{ .Route }}/$route/" \
    -e "s/{{ .Host }}/$host/" \
    -e "s/{{ .Port }}/$port/" \
    -e "s/{{ .Service }}/$svc_main/" \
    -e "s/{{ .Weight }}/$weight_main/" \
    -e "/{{ .AlterBackend }}/{
        s/{{ .AlterBackend }}//
        r AlterBackend.yaml
        }" route.tmpl > route.yaml

echo "Route config:"
cat route.yaml

oc apply -f route.yaml
