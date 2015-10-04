#!/bin/bash

set -euf -o pipefail 

deploy_dir="./content"

# Source material
puppetfile_repo_url="git@github.com:rmacduff/puppetfiles.git"
puppet_manifests_repo_url="git@bitbucket.org:rmacduff/puppet-manifests.git"
hiera_repo_url="git@bitbucket.org:rmacduff/hiera-private.git"

update_content() {
    if [[ ! -d $1 ]]; then
        git clone $2 $1
    else
        ( cd $1 && git pull )
    fi
}

mkdir -p $deploy_dir 
pushd $deploy_dir

# Pull in upstream content
update_content puppetfiles $puppetfile_repo_url
update_content manifests $puppet_manifests_repo_url
update_content hiera $hiera_repo_url

# Fetch modules
host_class=$( echo $HOSTNAME | awk -F- '{ print $1"-"$2}' | tr -d '[:digit:]' )
cp puppetfiles/Puppetfile.${host_class} Puppetfile
# should do a `r10k puppetfile check` first
r10k puppetfile install
