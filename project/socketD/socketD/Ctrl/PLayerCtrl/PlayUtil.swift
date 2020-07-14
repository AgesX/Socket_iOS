//
//  Util.swift
//  Music Player
//
//  Created by Jz D on 2019/7/23.
//  Copyright © 2019 polat. All rights reserved.
//

import UIKit




extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}




extension TimeInterval{
    //This returns song length
    
    var formatted: String{
         let hour   = abs(Int(self)/3600)
         let minute = abs(Int((self/60).truncatingRemainder(dividingBy: 60)))
         let second = abs(Int(self.truncatingRemainder(dividingBy: 60)))
         
         let h = hour > 9 ? "\(hour)" : "0\(hour)"
         let min = minute > 9 ? "\(minute)" : "0\(minute)"
         let sec = second > 9 ? "\(second)" : "0\(second)"
         var result = "\(sec)"
         if hour > 0{
            result = "\(min) :" + result
            result = "\(h) :" + result
         }
         else{
            result = "\(min) :" + result
         }
         return result
        
    }
    
    
}





extension Int{
    var formatted: String{
        TimeInterval(self).formatted
    }
}
