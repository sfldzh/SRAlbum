//
//  SRRollFaceTaskData.swift
//  SRAlbum
//
//  Created by 施峰磊 on 2022/6/11.
//  Copyright © 2022 施峰磊. All rights reserved.
//

import UIKit

class SRRollFaceTaskData: SRFaceTaskData {
    var r_yaw_value:Float = 0
    var r_yaw_date:Date?
    var r_yaw_finish:Bool = false
    
    var l_yaw_value:Float = 0
    var l_yaw_date:Date?
    var l_yaw_finish:Bool = false
    
    func setRYaw(value:Float) -> Void {
        if !self.r_yaw_finish && value <= 240{
            self.r_yaw_value = value
            self.r_yaw_finish = true
            self.r_yaw_date = Date()
            self.isFinish = self.checkFinish()
        }
    }
    
    func setLYaw(value:Float) -> Void {
        if !self.l_yaw_finish && value >= 300{
            self.l_yaw_value = value
            self.l_yaw_finish = true
            self.l_yaw_date = Date()
            self.isFinish = self.checkFinish()
        }
    }
    
    private func resetData() -> Void {
        self.r_yaw_value = 0
        self.r_yaw_finish = false
        self.r_yaw_date = nil
        self.l_yaw_value = 0
        self.l_yaw_finish = false
        self.l_yaw_date = nil
    }
    
    func checkFinish()->Bool{
        if self.r_yaw_finish && self.l_yaw_finish{
            if self.r_yaw_date != nil && self.l_yaw_date != nil{
                let v:Double = fabs(self.r_yaw_date!.timeIntervalSince1970 - self.l_yaw_date!.timeIntervalSince1970)
                if v <= 2 {
                    return true
                }else{
                    self.resetData()
                    return false
                }
            }else{
                self.resetData()
                return false
            }
        }else{
            return false
        }
    }
}
