
#
# Author:: Shawn Neal (<sneal@sneal.net>)
# Cookbook Name:: visualstudio
# Attribute:: vs2019
#
# Copyright 2015, Shawn Neal
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

# Currently you cannot change this, doing so will break the cookbook
default['visualstudio']['2019']['install_dir'] = (ENV['ProgramFiles(x86)'] || 'C:\Program Files (x86)') + '\Microsoft Visual Studio 16.0.3'
default['visualstudio']['2019']['all'] = false
default['visualstudio']['2019']['allWorkloads'] = false
default['visualstudio']['2019']['includeRecommended'] = true
default['visualstudio']['2019']['includeOptional'] = false

# Team Explorer 
default['visualstudio']['2019']['teamexplorer']['installer_file'] = 'vs_teamexplorer.exe'
default['visualstudio']['2019']['teamexplorer']['filename'] = 'vs_teamexplorer.exe'
default['visualstudio']['2019']['teamexplorer']['package_name'] = 'Microsoft Visual Studio Team Explorer 2019'
default['visualstudio']['2019']['teamexplorer']['checksum'] = '835b63028e75e9ab363a450435c45cec8cd0e01f6661210250c4d2936e849c96'
default['visualstudio']['2019']['teamexplorer']['default_source'] = 'https://download.visualstudio.microsoft.com/download/pr/cb5d9d9a-4b0b-4e93-b7d9-8da5b3cfe995/6b50169436bf0b8de07426ab9a8cacf9'

# Professional
default['visualstudio']['2019']['professional']['installer_file'] = 'vs_professional.exe'
default['visualstudio']['2019']['professional']['filename'] = 'vs_professional.exe'
default['visualstudio']['2019']['professional']['package_name'] = 'Microsoft Visual Studio Professional 2019'
default['visualstudio']['2019']['professional']['checksum'] = '061ecadc7066f8a83f0be160fc86728ba0cfe1ab20968bf08bdeda8bb2f7470d'
default['visualstudio']['2019']['professional']['default_source'] = 'https://download.visualstudio.microsoft.com/download/pr/d214d78f-676b-4e2b-9da5-8ef1f2662f56/f4bf0333c918ba3f3fbf7afd784cd80e'

# Defaults for https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-professional?vs-2019&view=vs-2019
default['visualstudio']['2019']['professional']['default_install_items'].tap do |h|
    h['Microsoft.VisualStudio.Workload.CoreEditor']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Azure']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Data']['selected'] = true
    h['Microsoft.VisualStudio.Workload.DataScience']['selected'] = true
    h['Microsoft.VisualStudio.Workload.ManagedDesktop']['selected'] = true
    h['Microsoft.VisualStudio.Workload.ManagedGame']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeCrossPlat']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeDesktop']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeGame']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeMobile']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetCoreTools']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetCrossPlat']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetWeb']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Node']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Office']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Python']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Universal']['selected'] = true
    h['Microsoft.VisualStudio.Workload.VisualStudioExtension']['selected'] = true
    h['Component.Android.Emulator']['selected'] = true
    h['Component.GitHub.VisualStudio']['selected'] = true
    h['Microsoft.Component.Blend.SDK.WPF']['selected'] = true
    h['Microsoft.Component.HelpViewer']['selected'] = true
    h['Microsoft.Net.Component.3.5.DeveloperTools']['selected'] = true
    h['Microsoft.VisualStudio.Component.DependencyValidation.Community']['selected'] = true
    h['Microsoft.VisualStudio.Component.LinqToSql']['selected'] = true
    h['Microsoft.VisualStudio.Component.Phone.Emulator']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.Core']['selected'] = true
    h['Microsoft.VisualStudio.Component.TypeScript.2.0']['selected'] = true
end

# Community
default['visualstudio']['2019']['community']['installer_file'] = 'vs_community.exe'
default['visualstudio']['2019']['community']['filename'] = 'vs_community.exe'
default['visualstudio']['2019']['community']['package_name'] = 'Microsoft Visual Studio Community 2019'
default['visualstudio']['2019']['community']['checksum'] = 'fef922943695ca511d4f7696ff218a70bd68782879ed941c2466475c794f005d'
default['visualstudio']['2019']['community']['default_source'] = 'https://download.visualstudio.microsoft.com/download/pr/556cbf10-dfb5-4da6-8fd6-fca1d04b5c33/eab773f31d4dee1184e94f460e734f2a'

# Defaults for https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?vs-2019&view=vs-2019
default['visualstudio']['2019']['community']['default_install_items'].tap do |h|
    h['Microsoft.VisualStudio.Workload.CoreEditor']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Azure']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Data']['selected'] = true
    h['Microsoft.VisualStudio.Workload.DataScience']['selected'] = true
    h['Microsoft.VisualStudio.Workload.ManagedDesktop']['selected'] = true
    h['Microsoft.VisualStudio.Workload.ManagedGame']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeCrossPlat']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeDesktop']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeGame']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeMobile']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetCoreTools']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetCrossPlat']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetWeb']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Node']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Office']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Python']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Universal']['selected'] = true
    h['Microsoft.VisualStudio.Workload.VisualStudioExtension']['selected'] = true
    h['Component.Android.Emulator']['selected'] = true
    h['Component.GitHub.VisualStudio']['selected'] = true
    h['Microsoft.Component.Blend.SDK.WPF']['selected'] = true
    h['Microsoft.Component.HelpViewer']['selected'] = true
    h['Microsoft.Net.Component.3.5.DeveloperTools']['selected'] = true
    h['Microsoft.VisualStudio.Component.DependencyValidation.Community']['selected'] = true
    h['Microsoft.VisualStudio.Component.LinqToSql']['selected'] = true
    h['Microsoft.VisualStudio.Component.Phone.Emulator']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.Core']['selected'] = true
    h['Microsoft.VisualStudio.Component.TypeScript.2.0']['selected'] = true
end

# Enterprise
default['visualstudio']['2019']['enterprise']['installer_file'] = 'vs_enterprise.exe'
default['visualstudio']['2019']['enterprise']['filename'] = 'vs_enterprise.exe'
default['visualstudio']['2019']['enterprise']['package_name'] = 'Microsoft Visual Studio Enterprise 2019'
default['visualstudio']['2019']['enterprise']['checksum'] = '24b21307bc04aa24802233d2f20c7b72eb29318698dc3a2da3df7e06b9de7bae'
default['visualstudio']['2019']['enterprise']['default_source'] = 'https://download.visualstudio.microsoft.com/download/pr/b00a3570-379d-49b5-8af4-9bbc470ac288/b025f330753375fa4bfe8222b2497644'

# Defaults for the https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-enterprise?vs-2019&view=vs-2019
default['visualstudio']['2019']['enterprise']['default_install_items'].tap do |h|  
    h['Microsoft.VisualStudio.Workload.CoreEditor']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Azure']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Data']['selected'] = true
    h['Microsoft.VisualStudio.Workload.DataScience']['selected'] = true
    h['Microsoft.VisualStudio.Workload.ManagedDesktop']['selected'] = true
    h['Microsoft.VisualStudio.Workload.ManagedGame']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeCrossPlat']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeDesktop']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeGame']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NativeMobile']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetCoreTools']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetCrossPlat']['selected'] = true
    h['Microsoft.VisualStudio.Workload.NetWeb']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Node']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Office']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Python']['selected'] = true
    h['Microsoft.VisualStudio.Workload.Universal']['selected'] = true
    h['Microsoft.VisualStudio.Workload.VisualStudioExtension']['selected'] = true
    h['Microsoft.VisualStudio.Workload.WebCrossPlat']['selected'] = true
    h['Component.Android.Emulator']['selected'] = true
    h['Component.GitHub.VisualStudio']['selected'] = true
    h['Microsoft.Component.Blend.SDK.WPF']['selected'] = true
    h['Microsoft.Component.HelpViewer']['selected'] = true
    h['Microsoft.Net.Component.3.5.DeveloperTools']['selected'] = true
    h['Microsoft.VisualStudio.Component.LinqToSql']['selected'] = true
    h['Microsoft.VisualStudio.Component.Phone.Emulator']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.CodedUITest']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.Core']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.FeedbackClient']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.MicrosoftTestManager']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.WebLoadTest']['selected'] = true
    h['Microsoft.VisualStudio.Component.TestTools.Core']['selected'] = true
    h['Microsoft.VisualStudio.Component.TypeScript.2.0']['selected'] = true
end
