# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Forking Pasta'
  app.icons = ['Icon.png', 'Icon@2x.png', 'Icon@3x.png']
  app.version = '0.5'
  app.identifier = 'uk.pixlwave.ForkingPasta'  
  app.entitlements['com.apple.security.application-groups'] = ['group.uk.pixlwave.ForkingPasta']
  # /private/var/mobile/Containers/Shared/AppGroup/697E2EAA-A35A-4BFA-939B-B1CF6C84C5D2/Forking Pasta.sqlite

  app.target('KingPastaKit', :framework)
  app.target('Widget', :extension)

  app.target('Watch', :extension)
  app.xcode_dir = '/Applications/Xcode-Beta.app/Contents/Developer'
  app.sdk_version = '8.2'
  app.deployment_target = '8.2'

  # development only
  app.provisioning_profile = '/Users/Douglas/Documents/RubyMotion/Certificates/Forking_Pasta_development.mobileprovision'

  app.manifest_assets << { :kind => 'software-package', :url => 'https://dl.dropboxusercontent.com/u/6437015/forking_pasta/Forking%20Pasta.ipa' }
end

task :"build:simulator" => :"schema:build"

namespace :schema do
  desc "Copy xcdatamodeld file to Widget"
  task :build do
    App.info "Copying", "resources/Forking Pasta.xcdatamodeld"
    FileUtils.copy_entry "resources/Forking Pasta.xcdatamodeld", "Widget/resources/Forking Pasta.xcdatamodeld"
    FileUtils.copy_entry "resources/Forking Pasta.xcdatamodeld", "Watch/resources/Forking Pasta.xcdatamodeld"
  end
end