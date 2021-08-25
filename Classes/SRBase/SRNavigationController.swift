//
//  SRNavigationController.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2021/8/25.
//  Copyright © 2021 施峰磊. All rights reserved.
//

import UIKit

class SRNavigationController: UINavigationController {

    override var shouldAutorotate : Bool {
        return self.viewControllers.last!.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return self.viewControllers.last!.supportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return self.viewControllers.last!.preferredInterfaceOrientationForPresentation
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.viewControllers.last!.prefersStatusBarHidden
    }

}
