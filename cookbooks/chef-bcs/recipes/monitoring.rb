#
# Author:: Chris Jones <cjones303@bloomberg.net>
# Cookbook Name:: chef-bcs
#
# Copyright 2016, Bloomberg Finance L.P.
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

# Monitoring recipe:
# Installs Diamond, collectd, zabbix-agent
# Will also need Splunk's rpm
#
# collectd and zabbix are upstream in the RHN repos - zabbix needs to be 2.4 or higher - current repo version is 2.2
# Diamond needs to be installed differently

# Splunk needs keys etc
#
#
