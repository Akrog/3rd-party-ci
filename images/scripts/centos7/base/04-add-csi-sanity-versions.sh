#!/bin/bash
echo "Downloading csi-sanity versions"

function do_links {
    for link_name in $2; do
      ln -s $1 $link_name
    done
}

mkdir /home/vagrant/csi-sanity
cd /home/vagrant/csi-sanity

curl -O https://github.com/embercsi/ember-csi/raw/master/tools/csi-sanity-v0.2.0
do_links csi-sanity-v0.2.0 "csi-sanity-v2 csi-sanity-v2.0"

curl -O https://github.com/embercsi/ember-csi/raw/master/tools/csi-sanity-v0.3.5
do_links csi-sanity-v0.3.5 "csi-sanity-v3 csi-sanity-v3.0 csi-sanity-v3.0.0"

curl -O https://github.com/embercsi/ember-csi/blob/master/tools/csi-sanity-v2.2.0
do_links csi-sanity-v2.2.0 "csi-sanity-v1 csi-sanity-v1.0 csi-sanity-v1.0.0 csi-sanity-v1.1 csi-sanity-v1.1.0"