#!/bin/bash
# Parameters come via env variables:
#     EMBER_IMAGE
#     BACKEND_NAME
#     CENTOS_VERSION
#     JOB_ID
set -e
echo "Running Ember-CSI functional tests on CentOS ${CENTOS_VERSION} on backend ${BACKEND_NAME} for job ${JOB_ID} with container ${EMBER_IMAGE}"

config_path=`backend-config-path.sh`
echo "Backend configuration is located at $config_path"

SCRIPT_DIR=$(dirname `realpath $0`)
# This is the script we want vagrant to run
ln -s $SCRIPT_DIR/run.sh $SCRIPT_DIR/run-functional.sh

BASE_DIR=`realpath $SCRIPT_DIR/../`

mkdir $BASE_DIR/artifacts

export VAGRANT_DEFAULT_PROVIDER=libvirt
export VAGRANT_FORCE_COLOR=true
export VAGRANT_CWD=`BASE_DIR`
export VAGRANT_VAGRANTFILE=Vagrantfile.template
export VAGRANT_HOME=$config_path/.vagrant.d
export MEMORY=4096
export CPUS=2
export IMAGE="ember-csi/ci-centos${CENTOS_VERSION}-base"
export CONFIG_DIR=$config_path
export WORKER="functional${CENTOS_VERSION}-${BACKEND_NAME}-${JOB_ID}"

echo "Running $WORKER VM"
# The vagrant template uses the same env variables this script does
vagrant up

echo "Generated artifacts: `ls $BASEDIR/artifacts`"
