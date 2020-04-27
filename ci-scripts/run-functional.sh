#!/bin/bash
# This script is run inside the VM when we run vagrant up and receives the
# following parameters:
#      container_image
#      job_name
#      job_id
#      backend_name
set -e

SCRIPT_DIR=$(dirname `realpath $0`)

# Set env vars for user backend scripts
export HOST_IP=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
export JOB_NAME=${2}
export JOB_ID=${3}
export BACKEND_NAME=${4}

echo "Functional tests for ${1}"

cd /ember-config

if [[ -f ./pre-run ]]; do
   echo "Pre run steps"
  ./pre-run
done

echo "Sourcing backend configuration "
source ./config

X_CSI_SPEC_VERSION={X_CSI_SPEC_VERSION:-"v1.1"}
X_CSI_PERSISTENCE_CONFIG='{"storage":"memory"}'
X_CSI_EMBER_CONFIG='{"project_id":"io.ember-csi","user_id":"io.ember-csi","root_helper":"sudo","disable_logs":false,"debug":true,"request_multipath":false,"state_path":"/tmp"}'

echo "Starting Ember-CSI container"
# Run the container in the background writing the output to file.
docker run --rm --name ember -t --privileged --net=host --ipc=host \
  -e DM_DISABLE_UDEV=1 \
  -e PYTHONUNBUFFERED=0 \
  -e X_CSI_SPEC_VERSION=$X_CSI_SPEC_VERSION \
  -e CSI_MODE=all \
  -e X_CSI_BACKEND_CONFIG=$DRIVER_CONFIG \
  -e X_CSI_EMBER_CONFIG=$X_CSI_EMBER_CONFIG \
  -e X_CSI_PERSISTENCE_CONFIG=$X_CSI_PERSISTENCE_CONFIG \
  ## -v /tmp/:/tmp/ \
  -v /etc/iscsi:/etc/iscsi \
  -v /dev:/dev \
  -v /etc/lvm:/etc/lvm \
  -v /var/lock/lvm:/var/lock/lvm \
  -v /etc/multipath:/etc/multipath \
  -v /etc/multipath.conf:/etc/multipath.conf \
  # -v /lib/modules:/lib/modules \
  -v /etc/localtime:/etc/localtime:ro \
  -v /run/udev:/run/udev:ro \
  -v /run/lvm:/run/lvm:ro \
  -v /var/lib/iscsi:/var/lib/iscsi \
  ## -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -p 50051:50051 \
  ${1} &>/ci-scripts/artifacts/ember-csi.logs &

echo "Running csi-sanity test suite"
# --ginkgo.failFast --test.parallel 1
set +e
~vagrant/csi-sanity/csi-sanity-${X_CSI_SPEC_VERSION} --test.v --csi.endpoint=127.0.0.1:50051 --test.timeout 0 --ginkgo.v --ginkgo.progress
test_result=$?
set -e

echo "Post run steps"
if [[ -f ./post-run ]]; do
  ./post-run $test_result
done

exit $test_result
