#!/bin/bash
#
# Copyright 2015, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Exit immediately if anything goes wrong!
set -e

# Check for required environment variables and exit if not all are set.
FAILED_ENVVAR_CHECK=0
REQUIRED_VARS=( BOOTSTRAP_CACHE_DIR BOOTSTRAP_OS )
for ENVVAR in ${REQUIRED_VARS[@]}; do
  if [[ -z ${!ENVVAR} ]]; then
    echo "Environment variable $ENVVAR must be set!" >&2
    FAILED_ENVVAR_CHECK=1
  fi
done
if [[ $FAILED_ENVVAR_CHECK != 0 ]]; then exit 1; fi

# Create directory for download cache.
mkdir -p $BOOTSTRAP_CACHE_DIR/cobbler/{isos,loaders}

# download_file wraps the usual behavior of curling a remote URL to a local file
download_file() {
  FILE=$1
  URL=$2

  if [[ ! -f $BOOTSTRAP_CACHE_DIR/$FILE && ! -f $BOOTSTRAP_CACHE_DIR/${FILE}_downloaded ]]; then
    echo $FILE
    rm -f $BOOTSTRAP_CACHE_DIR/$FILE
    curl -L --progress-bar -o $BOOTSTRAP_CACHE_DIR/$FILE $URL
    touch $BOOTSTRAP_CACHE_DIR/${FILE}_downloaded
  fi
}

# Obtain an RHEL 7.2 image to be used for PXE booting in production.
if [[ ! -z $COBBLER_BOOTSTRAP_ISO ]]; then
  # This cmd only works for non-rhel distros. Redhat has timed urls for downloads you could login to the rhn access portal
  # and get the url and then update $COBBLER_REMOTE_URL_ISO or copy the ISO to cobber/isos.
  substring=http
  if [ "${COBBLER_REMOTE_URL_ISO/$substring}" = "$COBBLER_REMOTE_URL_ISO" ] ; then
    cp $COBBLER_REMOTE_URL_ISO $BOOTSTRAP_CACHE_DIR/cobbler/isos/$COBBLER_BOOTSTRAP_ISO
    echo "$COBBLER_REMOTE_URL_ISO"
  else
    download_file cobbler/isos/$COBBLER_BOOTSTRAP_ISO $COBBLER_REMOTE_URL_ISO
  fi
fi

if [[ ! -z $COBBLER_BOOTSTRAP_ISO ]]; then
  download_file cobbler/loaders/pxelinux.0 http://cobbler.github.io/loaders/pxelinux.0-3.86
  download_file cobbler/loaders/menu.c32 http://cobbler.github.io/loaders/menu.c32-3.86
  download_file cobbler/loaders/grub-x86.efi http://cobbler.github.io/loaders/grub-0.97-x86.efi
  download_file cobbler/loaders/grub-x86_64.efi http://cobbler.github.io/loaders/grub-0.97-x86_64.efi
fi

# TODO: Add different OS support
# Obtain Chef client and server RPMs.
# knife actor map issue with latest version so reverting back to previous
CHEF_CLIENT_RPM=chef-12.6.0-1.el7.x86_64.rpm
CHEF_SERVER_RPM=chef-server-core-12.4.1-1.el7.x86_64.rpm
download_file $CHEF_CLIENT_RPM https://opscode-omnibus-packages.s3.amazonaws.com/el/7/x86_64/$CHEF_CLIENT_RPM
download_file $CHEF_SERVER_RPM https://web-dl.packagecloud.io/chef/stable/packages/el/7/$CHEF_SERVER_RPM

# Pull needed *cookbooks* from the Chef Supermarket.
mkdir -p $BOOTSTRAP_CACHE_DIR/{cookbooks,gems}

# Most important cookbook
download_file cookbooks/ceph-chef-0.9.8.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/ceph-chef/versions/0.9.8/download

download_file cookbooks/poise-2.6.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/poise/versions/2.6.0/download
download_file cookbooks/chef-client-4.3.3.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/chef-client/versions/4.3.3/download
download_file cookbooks/windows-1.39.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/windows/versions/1.39.1/download
download_file cookbooks/cron-1.7.4.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/cron/versions/1.7.4/download
download_file cookbooks/logrotate-1.9.2.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/logrotate/versions/1.9.2/download
download_file cookbooks/ntp-1.10.1.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/ntp/versions/1.10.1/download
download_file cookbooks/yum-3.10.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/yum/versions/3.10.0/download
download_file cookbooks/yum-epel.0.6.5.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/yum-epel/versions/0.6.5/download
download_file cookbooks/apt-1.10.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/apt/versions/1.10.0/download
download_file cookbooks/apache2-3.1.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/apache2/versions/3.1.0/download
download_file cookbooks/chef_handler-1.3.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/chef_handler/versions/1.3.0/download
download_file cookbooks/firewall-2.4.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/firewall/versions/2.4.0/download
download_file cookbooks/chef-sugar-3.3.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/chef-sugar/versions/3.3.0/download
download_file cookbooks/sudo-2.9.0.tar.gz http://cookbooks.opscode.com/api/v1/cookbooks/sudo/versions/2.9.0/download

# Gems
# REQUIRED for ceph-chef cookbook - must be installed before doing 'sudo chef-client' on any node
download_file gems/netaddr-1.5.0.gem https://rubygems.org/downloads/netaddr-1.5.0.gem

# Pull knife-acl gem.
# 0.0.12
download_file gems/knife-acl-0.0.12.gem https://rubygems.global.ssl.fastly.net/gems/knife-acl-0.0.12.gem

# Pull needed gems for fpm
GEMS=( arr-pm-0.0.10 backports-3.6.4 cabin-0.7.1 childprocess-0.5.6 clamp-0.6.5 ffi-1.9.8 fpm-1.3.3 json-1.8.2 )
mkdir -p $BOOTSTRAP_CACHE_DIR/gems
for GEM in ${GEMS[@]}; do
  download_file gems/$GEM.gem https://rubygems.global.ssl.fastly.net/gems/$GEM.gem
done
