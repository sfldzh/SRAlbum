source 'https://github.com/CocoaPods/Specs.git'
#source 'https://gitee.com/sr_lele/Specs'

platform:ios,'12.0'
inhibit_all_warnings!
use_frameworks!

project 'SRAlbum'
workspace 'SRAlbum'

target 'SRAlbum' do
  pod 'XibFrame'
  pod 'SRToast'
#  pod 'Verge/Store', "8.9.1"
#  pod 'TransitionPatch'
#  pod 'Brightroom/Engine'
#  pod 'Brightroom/UI-Classic'
#  pod 'Brightroom/UI-Crop'
  
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
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
