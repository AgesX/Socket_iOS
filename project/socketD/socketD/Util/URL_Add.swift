//
//  URL_Add.swift
//  socketD
//
//  Created by Jz D on 2020/10/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


extension URL{
    var val: Int{
        let name = lastPathComponent
        var result = 0
        for ch in name{
            if let num = Int(String(ch)){
                result = result * 10 + num
            }
            else{
                break
            }
        }
        return result
    }
}
