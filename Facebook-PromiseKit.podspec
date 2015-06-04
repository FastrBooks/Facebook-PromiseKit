#
# Be sure to run `pod lib lint Facebook-PromiseKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Facebook-PromiseKit"
  s.version          = "0.1.0"
  s.summary          = "PromiseKit wrapper for Facebook iOS SDK."
  s.description      = "Simple library that wraps some basic Facebook iOS SDK calls in fancy PromiseKit promises. Library also provides some convinience methods to make developer life easier."
  s.homepage         = "https://github.com/FastrBooks/Facebook-PromiseKit"
  s.license          = 'MIT'
  s.author           = { "Kirils Sivokozs" => "kirils@fastrbooks.com" }
  s.source           = { :git => "https://github.com/FastrBooks/Facebook-PromiseKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/staIkerrus'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'Facebook-PromiseKit' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'FBSDKLoginKit'
  s.dependency 'PromiseKit/Promise', '~> 1.5'
end
