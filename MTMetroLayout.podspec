#
# Be sure to run `pod spec lint MTMetroLayout.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "MTMetroLayout"
  s.version      = "0.0.3"
  s.summary      = "A short description of MTMetroLayout."
  s.homepage     = "https://github.com/sora0077/MTMetroLayout"
  s.license      = 'MIT'
  s.author       = { "t.hayashi" => "t.hayashi0077+github@gmail.com" }
  s.source       = { :git => "https://github.com/sora0077/MTMetroLayout.git", :tag => "0.0.3" }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  # s.osx.deployment_target = '10.7'
  
  s.source_files = 'MTMetroViewLayout', 'MTMetroViewLayout/**/*.{h,m}'
  # s.exclude_files = 'Classes/Exclude'
  # s.public_header_files = 'Classes/**/*.h'

  # Specify a list of frameworks that the application needs to link
  # against for this Pod to work.
  #
  # s.framework  = 'SomeFramework'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'

  # If this Pod uses ARC, specify it like so.
  #
  s.requires_arc = true
end
