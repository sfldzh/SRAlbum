source 'https://github.com/CocoaPods/Specs.git'

platform:ios,'10.0'
inhibit_all_warnings!
use_frameworks!

xcodeproj 'SRAlbum'
workspace 'SRAlbum'

target 'SRAlbum' do
#  pod 'JPImageresizerView', '~> 1.9.4'
  pod 'XibFrame', '~> 0.0.9' # xib属性
  pod 'MBProgressHUD', '~> 1.2.0'
  
  target 'SRAlbumTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SRAlbumUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
#      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
