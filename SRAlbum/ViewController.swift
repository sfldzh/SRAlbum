//
//  ViewController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2020/1/17.
//  Copyright © 2020 施峰磊. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didClick(_ sender: UIButton) {
//        self.openAlbum(assetType: .Photo, maxCount: 5, isEidt: true) { (assets) in
//            print("assets")
//        }
        self.openAlbum( maxCount: 5, isEidt: true, isSort: true) { [weak self](assets) in
            let vc:ResultViewController = ResultViewController.init(nibName: "ResultViewController", bundle: bundle)
            vc.images = assets as? Array<UIImage>;
            self?.navigationController?.pushViewController(vc, animated: true);
            print("assets")
        }
    }
    
}

