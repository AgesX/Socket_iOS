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



enum AudioTags: String{
    
    
    case currentIndex = "currentAudioIndex"
    
    case playerProgress = "playerProgressSliderValue"
    
}




extension UserDefaults{
    
    
    func intVal(forKey defaultName: String)->Int{
        if let val = UserDefaults.standard.object(forKey: AudioTags.currentIndex.rawValue) as? Int{
            return val
        }else{
            return 0
        }
    }
    
    
}





extension TimeInterval{
    //This returns song length
    
    var formattedTime: String{
        // let hour   = abs(Int(duration)/3600)
         let minute = abs(Int((self/60).truncatingRemainder(dividingBy: 60)))
         let second = abs(Int(self.truncatingRemainder(dividingBy: 60)))
         
        // var hour = hour > 9 ? "\(hour_)" : "0\(hour_)"
         let min = minute > 9 ? "\(minute)" : "0\(minute)"
         let sec = second > 9 ? "\(second)" : "0\(second)"
         return "\(min) : \(sec)"
        
    }
    
    
}


