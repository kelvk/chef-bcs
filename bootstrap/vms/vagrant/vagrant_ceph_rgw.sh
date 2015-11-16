#!/bin/bash
#
# Author: Chris Jones <cjones303@bloomberg.net>
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

source vagrant_base.sh

do_on_node $CEPH_CHEF_BOOTSTRAP "$KNIFE node run_list add ${CEPH_CHEF_HOSTS[@]:1:1}.$BOOTSTRAP_DOMAIN 'role[ceph-radosgw]'"
# Run entire run so that ceph.conf is updated properly. Things installed and running are skipped.
do_on_node ${CEPH_CHEF_HOSTS[@]:1:1} "sudo chef-client"
