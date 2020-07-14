//
//  MusicItem.swift
//  socketD
//
//  Created by Jz D on 2020/7/14.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


struct MusicItem{
    var desp: String{
        var result = "\(start.formatted) -> \(end.formatted)"
        if start == 0{
            result = "开始 -> \(end.formatted)"
        }
        return result
    }
    
    let start: TimeInterval
    let end: TimeInterval
    
    init(start begin: Int, end final: Int) {
        start = TimeInterval(begin)
        end = TimeInterval(final)
    }
    
    init(start begin: Int, end final: TimeInterval) {
        start = TimeInterval(begin)
        end = final
    }
}
