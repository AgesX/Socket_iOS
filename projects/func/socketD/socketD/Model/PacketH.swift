//
//  PacketH.swift
//  socketD
//
//  Created by Jz D on 2020/4/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


enum PacketType: Int{
    case unknown = -1, didAddDisc, startNewTask
}



struct PacketKey {
    static let data = "data"
    static let type = "type"
}


class PacketH: NSObject{


    let data: Any
    let type: PacketType

    
    init(info d: Any, type t: PacketType){
        data = d
        type = t
     
        super.init()
    }
    
    
    required init?(coder: NSCoder) {
        data = coder.decodeObject(forKey: PacketKey.data) ?? [:]
        type = PacketType(rawValue: coder.decodeInteger(forKey: PacketKey.type)) ?? PacketType.unknown
      
    }
    
}


extension PacketH: NSCoding, NSSecureCoding{
    
    
    
    func encode(with coder: NSCoder) {
        coder.encode(data, forKey: PacketKey.data)
        coder.encode(type.rawValue, forKey: PacketKey.type)
    }
    
    
    
    
    
    
    static var supportsSecureCoding: Bool {
        true
    }
    
    
    
    
    
}
