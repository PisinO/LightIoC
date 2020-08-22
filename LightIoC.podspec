#
# Be sure to run `pod lib lint LightIoC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LightIoC'
  s.version          = '0.1.0'
  s.summary          = 'Light IoC Container for Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  LightIoC is an easy-to-use Dependency Injection (DI) framework for Swift 5.1 and above implementing automatic dependency injection. It manages object creation and it's life-time, and also injects dependencies to the class. The IoC container creates an object of the specified class and also injects all the dependency objects through properties at run time and disposes it at the appropriate time. This is done so that you don't have to create and manage objects manually.
                       DESC

  s.homepage         = 'https://github.com/PisinO/LightIoC'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ondrej Pisin' => 'ondrej.pisin@gmail.com' }
  s.source           = { :git => 'https://github.com/PisinO/LightIoC.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.1'
  
  s.source_files = 'LightIoC/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LightIoC' => ['LightIoC/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
