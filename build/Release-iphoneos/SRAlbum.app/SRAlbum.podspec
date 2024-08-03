Pod::Spec.new do |spec|
  spec.name         = "SRAlbum"
  spec.version      = "0.3.2"
  spec.summary      = "相册和相机模块"
  spec.swift_version      = "5.0"
  spec.homepage     = "https://www.baidu.com/"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "施峰磊" => "shifenglei1216@163.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/sfldzh/SRAlbum.git", :tag => "#{spec.version}" }
  spec.source_files  = "Classes", "Classes/**/*.{h,m,swift}"
  spec.exclude_files = "Classes/Exclude"
  spec.resource     = 'Classes/SRAlbum.bundle'
  spec.dependency "XibFrame"
  spec.dependency "SRToast"
  # spec.dependency "Verge/Store", ">= 8.9.1"
  # spec.dependency "TransitionPatch"
end
