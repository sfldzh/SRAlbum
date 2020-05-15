//
//  AssetCollection.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/20.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import Photos
private var SRAssetCollectionAssetsKey :Void?

extension PHAssetCollection{
    
    var assets:PHFetchResult<PHAsset> {
        set{
            objc_setAssociatedObject(self, &SRAssetCollectionAssetsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            if let result:PHFetchResult<PHAsset> = objc_getAssociatedObject(self, &SRAssetCollectionAssetsKey) as? PHFetchResult<PHAsset> {
                return result;
            }else{
                let options:PHFetchOptions = PHFetchOptions.init()
                options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
                if (asset_type == .Photo) {
                    options.predicate = NSPredicate.init(format: "mediaType == \(PHAssetMediaType.image.rawValue)")
                }else if (asset_type == .Video){
                    options.predicate = NSPredicate.init(format: "mediaType == \(PHAssetMediaType.video.rawValue)")
                }
                let result = PHAsset.fetchAssets(in: self, options: options);
                self.assets = result;
                return result;
            }
        }
    }
    
    
}
