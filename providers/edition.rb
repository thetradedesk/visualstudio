
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
  check_for_dotnet
  unless installed?
    setup_installer_files

    run_vs_installer(:install)

    cleanup_iso_dir if iso_source?
    new_resource.updated_by_last_action(true)
  end
end

action :update do
  check_for_dotnet
  if should_update?
    setup_installer_files

    update_vs_installer

    run_vs_installer(:update)

    cleanup_iso_dir if iso_source?
    new_resource.updated_by_last_action(true)
  end
end

action :modify do
  check_for_dotnet
  if should_modify?
    setup_installer_files

    run_vs_installer(:modify)

    cleanup_iso_dir if iso_source?
    new_resource.updated_by_last_action(true)
  end
end

def update_vs_installer
  windows_package "Update Visual Studio Installer - #{new_resource.package_name}" do
    source installer_exe
    installer_type :custom
    options '--update --quiet --wait'
    timeout 3600 # 1hour
    returns [0, 127, 3010]
  end
end

def run_vs_installer(mode)
  vs_opts = visual_studio_options(mode)

  converge_by("Running Visual Studio installer in mode #{mode} with the following arguments...\n #{vs_opts}") do
    windows_package "Visual Studio - #{new_resource.package_name}" do
      source installer_exe
      installer_type :custom
      options vs_opts
      timeout 3600 # 1hour
      returns [0, 127, 3010]
    end
  end
end

def setup_installer_files
  download_iso_source if iso_source?
  download_exe_source if exe_source?

  # Ensure the target directory exists so logging doesn't fail on VS 2010
  directory "create_#{new_resource.install_dir}" do
    path new_resource.install_dir
    recursive true
  end
end

def cleanup_installer_files
  cleanup_iso_dir if iso_source?
end

def iso_source?
  !new_resource.source.nil? && extractable_download
end

def exe_source?
  !new_resource.source.nil? && !extractable_download
end

def download_iso_source
  # Not an ISO but the web install
  local_path = ::File.join(cache_path, ::File.basename(new_resource.source))
  remote_file "download__#{new_resource.version}_#{new_resource.edition}_iso" do
    path local_path
    source new_resource.source
    checksum new_resource.checksum if new_resource.checksum.nil?
  end

  # Extract the ISO image to the temporary Chef cache dir
  seven_zip_archive "extract_#{new_resource.version}_#{new_resource.edition}_iso" do
    path extracted_iso_dir
    source local_path
    overwrite true
  end
end

def cleanup_iso_dir
  # Cleanup extracted ISO files from tmp dir
  directory "remove_#{new_resource.version}_#{new_resource.edition}_dir" do
    path extracted_iso_dir
    action :delete
    recursive true
    only_if { !new_resource.preserve_extracted_files }
  end
end

def download_exe_source
  # Not an ISO but the web install
  remote_file "download__#{new_resource.version}_#{new_resource.edition}" do
    path installer_exe
    source lazy { new_resource.source }
    checksum new_resource.checksum if new_resource.checksum.nil?
  end
end

def installer_exe
  @installer ||= begin
    installer = new_resource.installer_file || "vs_#{new_resource.edition}.exe"
    installer = ::File.join(extracted_iso_dir, installer) if iso_source?
    installer = ::File.join(cache_path, installer) if exe_source?
    installer
  end
end

def cache_path
  @package_cache_dir ||= Chef::FileCache.create_cache_path(::File.join('package/',
                                                                       'visualstudio',
                                                                       new_resource.version,
                                                                       new_resource.edition)
                                                          )
end

def extracted_iso_dir
  @extract_dir ||= begin
    default_path = ::File.join(
        Chef::Config[:file_cache_path],
        'visualstudio',
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
end

def should_update?
  raise 'Visual Studio must be installed before it can be updated' unless installed?
  missing_components.any? ||
      force_update?
end

def should_modify?
  raise 'Visual Studio must be installed before it can be updated' unless installed?
  missing_components.any? ||
      force_modify?
end

def force_update?
  node['visualstudio'][new_resource.version.to_s]['force_update']
end

def force_modify?
  node['visualstudio'][new_resource.version.to_s]['force_modify']
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
      components << key if attributes.has_key?('selected') && attributes['selected']
    end
    components
  end
end

def visual_studio_options(mode)
  option_all = node['visualstudio'][new_resource.version.to_s]['all']
  option_allWorkloads = node['visualstudio'][new_resource.version.to_s]['allWorkloads']
  option_includeRecommended = node['visualstudio'][new_resource.version.to_s]['includeRecommended']
  option_include_optional = node['visualstudio'][new_resource.version.to_s]['includeOptional']
  options_components_to_install = ''

  components = missing_components
  components = requested_components unless components.any?
  components.each do |key|
    options_components_to_install << " --add #{key}"
  end

  setup_options = ''
  setup_options = 'update ' if mode == :update
  setup_options = 'modify ' if mode == :modify

  setup_options << '--norestart --passive --wait'
  setup_options << " --installPath \"#{new_resource.install_dir}\"" unless new_resource.install_dir.empty?
  unless mode == :update
    setup_options << ' --all' if option_all
    setup_options << ' --allWorkloads' if option_allWorkloads
    setup_options << ' --includeRecommended' if option_includeRecommended
    setup_options << ' --includeOptional' if option_include_optional
    setup_options << options_components_to_install unless options_components_to_install.empty?
  end

  setup_options
end


def check_for_dotnet
  dotnet4dir = ::File.join(ENV['WINDIR'], 'Microsoft.Net\\Framework64\\v4.0.30319')
  dotnet_45_file = ::File.join(dotnet4dir, 'Microsoft.Activities.Build.dll')
  dotnet_is_not_installed_msg = '.NET 4.5 must be installed before installing VisualStudio. ' \
  'This is required otherwise the Visual Studio installer will silently fail. ' \
  'Please install .NET 4.5, reboot, then run this recipe again.'
  Chef::Log.warn dotnet_is_not_installed_msg unless ::File.exist?(dotnet_45_file)
end
