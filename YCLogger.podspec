
Pod::Spec.new do |s|
  s.name             = 'YCLogger'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YCLogger.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/沈伟航/YCLogger'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '沈伟航' => '809827782@qq.com' }
  s.source           = { :git => 'https://github.com/沈伟航/YCLogger.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'YCLogger/Classes/**/*'
  
  s.dependency 'CocoaLumberjack'
  s.dependency 'SSZipArchive'
  s.dependency 'AFNetworking'
end
