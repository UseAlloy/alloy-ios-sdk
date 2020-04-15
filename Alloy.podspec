#
# Be sure to run `pod lib lint Alloy.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'Alloy'
  s.version          = '0.0.1'
  s.summary          = 'Alloy helps top banks and fintechs make better decisions using a single API and dashboard to manage KYC/AML, fraud, and more.'
  s.homepage         = 'https://github.com/z1digitalstudio/alloy-ios-sdk'
  s.license          = 'MIT'
  s.author           = 'Alloy'
  s.source           = { :git => 'https://github.com/z1digitalstudio/alloy-ios-sdk.git', :tag => s.version.to_s }

  s.swift_version = '4.2'
  s.ios.deployment_target = '11.0'

  s.frameworks = 'UIKit'
  s.source_files = 'Alloy/**/*'
end
