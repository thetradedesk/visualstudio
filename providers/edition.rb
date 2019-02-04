
#
# Author:: Ian Kendrick (<iankendrick@gmail.com>), Shawn Neal (<sneal@sneal.net>)
# Cookbook Name:: visualstudio
# Provider:: edition
#
# Copyright 2015, Ian Kendrick, Shawn Neal
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'fileutils'
require 'chef/mixin/deep_merge'

include Windows::Helper
include Visualstudio::Helper
include Chef::Mixin::DeepMerge

def whyrun_supported?
  true
end

use_inline_resources

action :install do

  if should_install?
    converge_by(converge_message) do
      # Extract the ISO image to the temporary Chef cache dir
      seven_zip_archive "extract_#{new_resource.version}_#{new_resource.edition}_iso" do
        path extracted_iso_dir
        source new_resource.source
        overwrite true
        checksum new_resource.checksum unless new_resource.checksum.nil?
        only_if { (!new_resource.source.nil?) and extractable_download }
      end

      # Not an ISO but the web install
      remote_file "download__#{new_resource.version}_#{new_resource.edition}" do
        path installer_exe
        source lazy { new_resource.source }
        checksum new_resource.checksum if new_resource.checksum.nil?
        only_if { (!new_resource.source.nil?) and (!extractable_download) }
      end

      # Ensure the target directory exists so logging doesn't fail on VS 2010
      directory "create_#{new_resource.install_dir}" do
        path new_resource.install_dir
        recursive true
      end

      windows_package "Visual Studio - #{new_resource.package_name}" do
        source installer_exe
        installer_type :custom
        options visual_studio_options
        timeout 3600 # 1hour
        returns [0, 127, 3010]
      end

      # Cleanup extracted ISO files from tmp dir
      directory "remove_#{new_resource.version}_#{new_resource.edition}_dir" do
        path extracted_iso_dir
        action :delete
        recursive true
        only_if { (!new_resource.source.nil?) and (!new_resource.preserve_extracted_files) }
      end
    end
    new_resource.updated_by_last_action(true)
  end
end

def converge_message
  message = if installed?
              'Updating '
            else 'Installing ' end
  message << "VisualStudio #{new_resource.edition} #{new_resource.version}."
  message << " Adding additional components (#{missing_components.join(', ')})" if missing_components.any?
end

def should_install?
  !installed? ||
    missing_components.any? ||
    force_update?
end

def force_update?
  node['visualstudio'][new_resource.version.to_s]['force_update']
end

def installed?
  package_is_installed?(new_resource.package_name)
end

def extractable_download
  %w( '.iso' '.zip' '.7z').include? ::File.extname(new_resource.source).downcase
end

def missing_components
  (requested_components - loaded_components)
end

def loaded_components
  @loaded_components ||= begin
    devenv_ini_path = ::File.join(new_resource.install_dir, 'Common7/IDE/devenv.isolation.ini')
    return [] unless ::File.exists?(devenv_ini_path)

    packages = ::File.readlines(devenv_ini_path)
                   .find_all { |x| x.start_with?('InstallationPackages', 'InstallationWorkloads') }
                   .map { |x| x.split('=').last.strip.split(',') }
                   .flatten
    packages
  end
end

def requested_components
  @requested_components ||= begin
    components = []
    node['visualstudio'][new_resource.version.to_s][new_resource.edition.to_s]['default_install_items'].each do |key, attributes|
      components << key if attributes.has_key?('selected') and attributes['selected']
    end
    components
  end
end

def visual_studio_options
  option_all = node['visualstudio'][new_resource.version.to_s]['all']
  option_allWorkloads = node['visualstudio'][new_resource.version.to_s]['allWorkloads']
  option_includeRecommended = node['visualstudio'][new_resource.version.to_s]['includeRecommended']
  option_include_optional = node['visualstudio'][new_resource.version.to_s]['includeOptional']
  options_components_to_install = ''

  # Merge the VS version and edition default AdminDeploymentFile.xml item's with customized install_items
  components = missing_components
  components = requested_components unless components.any?
  components.each do |key|
    options_components_to_install << " --add #{key}"
  end

  setup_options = ''
  setup_options << 'update' if package_is_installed?(new_resource.package_name)
  setup_options << ' --norestart --passive --wait'
  setup_options << " --installPath \"#{new_resource.install_dir}\"" unless new_resource.install_dir.empty?
  setup_options << ' --all' if option_all
  setup_options << ' --allWorkloads' if option_allWorkloads
  setup_options << ' --includeRecommended' if option_includeRecommended
  setup_options << ' --includeOptional' if option_include_optional
  setup_options << options_components_to_install unless options_components_to_install.empty?

  setup_options
end

def utf8_to_unicode(file_path)
  powershell_script "convert #{file_path} to unicode" do
    code(
      "gc -en utf8 #{file_path}.tmp | Out-File -en unicode #{file_path}"
    )
  end
end

def install_log_file
  Chef::Util::PathHelper.cleanpath(::File.join(new_resource.install_dir, 'vsinstall.log'))
end

def installer_exe
  installer = new_resource.installer_file || "vs_#{new_resource.edition}.exe"
  installer = ::File.join(extracted_iso_dir, installer) unless new_resource.source.nil?
  installer
end

def extracted_iso_dir
  default_path = ::File.join(
    Chef::Config[:file_cache_path],
    new_resource.version,
    new_resource.edition
  )
  extract_dir = node['visualstudio']['unpack_dir'].nil? ? default_path : node['visualstudio']['unpack_dir']
  directory extract_dir do
    action :create
    recursive true
  end
  Chef::Util::PathHelper.cleanpath(extract_dir)
end
