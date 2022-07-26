
Pod::Spec.new do |s|
  
  # 1 - Specs
  s.name = 'RCSceneCommunity'
  s.summary = 'rongcloud scene community.'
  s.description = 'scene community implementation based on IMLib >= 5.2.0'
  
  s.platform = :ios
  s.requires_arc = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  
  # 2 - Version
  s.version = '0.1.2'
  
  # 3 - License
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  # 4 - Author
  s.authors          = { 'xuefeng' => 'suixuefeng@rongcloud.cn', 'ashine' => 'gongjiahao@rongcloud.cn' }
  
  # 5 - Homepage
  s.homepage         = 'https://github.com/rongcloud-community'
  
  # 6 - Source
  s.source           = { :git => 'https://github.com/rongcloud-community/rongcloud-scene-community-ios.git', :tag => s.version.to_s }
  
  # 7 - Dependencies
  s.dependency 'SnapKit'
  s.dependency 'Kingfisher'
  s.dependency 'TableViewDragger'
  s.dependency 'SVProgressHUD'
  
  s.dependency 'ISEmojiView'
  s.dependency 'GrowingTextView', '0.7.2'
  s.dependency 'Alamofire', '~> 5.5'
  s.dependency 'MJRefresh'

  s.dependency 'SDWebImage'

  s.dependency 'KNPhotoBrowser'
  s.dependency 'RongCloudOpenSource/IMKit'
  
  s.dependency 'JXSegmentedView'
  s.dependency 'HXPHPicker/Lite'
  # IMLib
  s.dependency 'RongCloudIM/IMLib', '~> 5.2.0'

  # 8 - Sources
  s.source_files = 'RCSceneCommunity/Classes/**/*'
  
  s.static_framework = true
  
  s.resource_bundles = {
    'RCSceneCommunity' => ['RCSceneCommunity/Assets/*']
  }
  
  
  s.pod_target_xcconfig = {
    'VALID_ARCHS' => 'arm64 x86_64',
    'ENABLE_BITCODE' => 'NO'
  }
end
