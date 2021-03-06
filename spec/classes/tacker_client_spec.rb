require 'spec_helper'

describe 'tacker::client' do

  shared_examples 'tacker::client' do

    context 'with default parameters' do
      it 'contains tacker::params' do
          is_expected.to contain_class('tacker::params')
      end
      it 'contains tackerclient' do
          is_expected.to contain_package('python-tackerclient').with(
              :ensure => 'present',
              :name   => platform_params[:tackerclient_package]
          )
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

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :tackerclient_package => 'python-tackerclient' }
        when 'RedHat'
          { :tackerclient_package => 'python-tackerclient' }
        end
      end
      it_behaves_like 'tacker::client'

    end
  end


end
