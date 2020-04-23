//
//  Extern.swift
//  socketD
//
//  Created by Jz D on 2020/4/23.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit




extension Array {
    public subscript(index: UInt) -> Element {
        return self[Int(index)]
    }
}



public func / (left: CGFloat, right: Int) -> CGFloat {
    return left/CGFloat(right)
}


public func * (left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}


public func * (left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) * right
}



