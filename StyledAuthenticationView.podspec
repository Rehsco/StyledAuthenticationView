Pod::Spec.new do |s|
  s.name             = 'StyledAuthenticationView'
  s.version          = '5.0.1'
  s.license          = 'MIT'
  s.summary          = 'StyledAuthenticationView is a UIView with styling options to authenticate with TouchID, FaceID, PIN and Passwords'
  s.homepage         = 'https://github.com/Rehsco/StyledAuthenticationView.git'
  s.authors          = { 'Martin Jacob Rehder' => 'gitrepocon01@rehsco.com' }
  s.source           = { :git => 'https://github.com/Rehsco/StyledAuthenticationView.git', :tag => s.version }
  s.swift_version    = '5.0'
  s.ios.deployment_target = '12.0'

  s.dependency 'FlexCollections'
  
  s.framework    = 'UIKit'
  s.source_files = 'StyledAuthenticationView/**/*.swift'
  s.resources    = 'StyledAuthenticationView/**/*.xcassets'
  s.requires_arc = true
end
