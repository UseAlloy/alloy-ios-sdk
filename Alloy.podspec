#
# Be sure to run `pod lib lint Alloy.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'Alloy'
  s.version          = '0.0.1'
  s.summary          = 'Alloy helps top banks and fintechs make better decisions using a single API and dashboard to manage KYC/AML, fraud, and more.'
  s.homepage         = 'https://alloy.co'
  s.license          = { :type => 'Copyright', :text => 'Copyright 2020 Alloy' }
  s.author           = 'Alloy'
  s.source           = { :git => 'https://github.com/z1digitalstudio/alloy-ios-sdk.git', :tag => s.version.to_s }

  s.dependency 'lottie-ios', '~> 3.1.8'

  s.swift_version = '4.2'
  s.ios.deployment_target = '11.0'

  s.frameworks = 'UIKit'

  s.vendored_framework = 'Alloy.framework'
  s.module_map = 'Alloy.framework/Modules/module.modulemap'
  s.resource_bundles = {
    'AlloyAssets' => [
      'Alloy.framework/*.json',
      'Alloy.framework/AlloyAssets.xcassets',
    ]
  }
end
