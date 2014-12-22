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
  app.icons = ['Icon.png', 'Icon@2x.png']
  app.version = '0.1.3'
  app.identifier = 'uk.pixlwave.ForkingPasta'  
  app.entitlements['com.apple.security.application-groups'] = ['group.uk.pixlwave.ForkingPasta']

  app.target('KingPastaKit', :framework)

  # development only
  app.provisioning_profile = '/Users/Douglas/Documents/RubyMotion/Certificates/Forking_Pasta_development.mobileprovision'

  app.manifest_assets << { :kind => 'software-package', :url => 'https://dl.dropboxusercontent.com/u/6437015/forking_pasta.ipa' }
end

task :"build:simulator" => :"schema:build"