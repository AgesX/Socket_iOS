//
//  UserSetting.swift
//  socketD
//
//  Created by Jz D on 2020/5/4.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


struct InfoKeys {

    static let age = "_age_"
    
}



struct UserSetting {

    
    static var std = UserSetting()

    var age: Int{
        get {
            if let year = UserDefaults.standard.value(forKey: InfoKeys.age) as? Int{
                return year
            }
            return 0
        }
        set(newVal){
            UserDefaults.standard.set(newVal, forKey: InfoKeys.age)
        }
    }



}
