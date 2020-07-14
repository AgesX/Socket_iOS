//
//  LayerMore.swift
//  socketD
//
//  Created by Jz D on 2020/7/14.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation

import UIKit


extension CALayer{
    func decorate(){
        cornerRadius = 4
        masksToBounds = true
        borderColor = UIColor.blue.cgColor
        borderWidth = 2
    }
    
    func unDecorate(){
        cornerRadius = 0
        masksToBounds = false
        borderColor = UIColor.white.cgColor
        borderWidth = 0
    }
}
