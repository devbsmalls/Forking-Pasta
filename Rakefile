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
  app.icons = ['Icon.png', 'Icon@2x.png', 'Icon@3x.png', 'Icon-Settings@2x', 'Icon-Settings@3x', 'Icon-Spotlight@2x', 'Icon-Spotlight@3x']
  app.version = '1.0.6'
  app.identifier = 'uk.pixlwave.ForkingPasta'
  app.frameworks << 'AudioToolbox'
  app.entitlements['com.apple.security.application-groups'] = ['group.uk.pixlwave.ForkingPasta']
  # /private/var/mobile/Containers/Shared/AppGroup/697E2EAA-A35A-4BFA-939B-B1CF6C84C5D2/Forking Pasta.sqlite
  app.deployment_target = '8.2'

  app.target('KingPastaKit', :framework)
  # app.target('Widget', :extension)
  # app.target('Watch', :extension)

  app.embed_dsym = false

  app.development do
    app.provisioning_profile = '/Users/Douglas/Documents/RubyMotion/Certificates/Forking_Pasta_development.mobileprovision'
  end

  app.release do
    app.provisioning_profile = '/Users/Douglas/Documents/RubyMotion/Certificates/Forking_Pasta.mobileprovision'
  end

  app.manifest_assets << { :kind => 'software-package', :url => 'https://dl.dropboxusercontent.com/u/6437015/forking_pasta/Forking%20Pasta.ipa' }
end

namespace :clean do
  desc 'Clean build directories, leaving .storyboardc files'
  task :build do
    dirs = ['build', 'KingPastaKit/build', 'Widget/build', 'Watch/build']
    dirs.each do |dir|
      path = File.join(App.config.project_dir, dir)
      App.info 'Delete', path
      rm_rf path
    end
  end
end