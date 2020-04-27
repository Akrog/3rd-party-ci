#!/bin/bash
set -e

short_description="Ember-CSI CI job box"
version_description=`git rev-parse HEAD`

vagrant cloud auth login --username "$VAGRANT_USERNAME" --token "$VAGRANT_TOKEN"
for box in `\ls -v boxes/*.box`; do
    echo -e "\nUploading $box"
    filename=`basename "$box"`
    boxname="${filename%.*}"
    vagrant cloud publish ember-csi/$boxname 1.0.0 libvirt $box --short-description="$short_description" --version-description="$version_description" --force --release
done
