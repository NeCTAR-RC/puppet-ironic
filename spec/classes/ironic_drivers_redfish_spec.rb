# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for ironic::drivers::redfish class
#

require 'spec_helper'

describe 'ironic::drivers::redfish' do

  let :params do
    {}
  end

  shared_examples_for 'ironic redfish driver' do
    let :p do
      params
    end

    it 'configures ironic.conf' do
      is_expected.to contain_ironic_config('redfish/connection_attempts').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/connection_retry_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/connection_cache_size').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/auth_type').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/use_swift').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/swift_container').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/swift_object_expiry_timeout').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/kernel_append_params').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/file_permission').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/firmware_update_status_interval').with_value('<SERVICE DEFAULT>')
      is_expected.to contain_ironic_config('redfish/firmware_update_fail_interval').with_value('<SERVICE DEFAULT>')
    end

    it 'installs sushy package' do
      is_expected.to contain_package('python-sushy').with(
        :ensure => 'present',
        :name   => platform_params[:sushy_package_name],
        :tag    => ['openstack', 'ironic-package'],
      )
    end

    context 'when overriding parameters' do
      before do
        params.merge!(
          :connection_attempts             => 10,
          :connection_retry_interval       => 1,
          :connection_cache_size           => 100,
          :auth_type                       => 'auto',
          :use_swift                       => true,
          :swift_container                 => 'ironic_redfish_container',
          :swift_object_expiry_timeout     => 900,
          :kernel_append_params            => 'nofb nomodeset vga=normal',
          :file_permission                 => '0o644',
          :firmware_update_status_interval => 60,
          :firmware_update_fail_interval   => 60,
          )
      end

      it 'should replace default parameter with new value' do
        is_expected.to contain_ironic_config('redfish/connection_attempts').with_value(10)
        is_expected.to contain_ironic_config('redfish/connection_retry_interval').with_value(1)
        is_expected.to contain_ironic_config('redfish/connection_cache_size').with_value(100)
        is_expected.to contain_ironic_config('redfish/auth_type').with_value('auto')
        is_expected.to contain_ironic_config('redfish/use_swift').with_value(true)
        is_expected.to contain_ironic_config('redfish/swift_container').with_value('ironic_redfish_container')
        is_expected.to contain_ironic_config('redfish/swift_object_expiry_timeout').with_value(900)
        is_expected.to contain_ironic_config('redfish/kernel_append_params').with_value('nofb nomodeset vga=normal')
        is_expected.to contain_ironic_config('redfish/file_permission').with_value('0o644')
        is_expected.to contain_ironic_config('redfish/firmware_update_status_interval').with_value(60)
        is_expected.to contain_ironic_config('redfish/firmware_update_fail_interval').with_value(60)
      end
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :sushy_package_name => 'python3-sushy' }
        when 'RedHat'
          if facts[:operatingsystem] == 'Fedora'
            { :sushy_package_name => 'python3-sushy' }
          else
            if facts[:operatingsystemmajrelease] > '7'
              { :sushy_package_name => 'python3-sushy' }
            else
              { :sushy_package_name => 'python-sushy' }
            end
          end
        end
      end

      it_behaves_like 'ironic redfish driver'
    end
  end

end
