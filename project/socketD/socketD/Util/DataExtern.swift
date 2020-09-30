//
//  Extern.swift
//  socketD
//
//  Created by Jz D on 2020/4/23.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit



extension Data{
    
    static let start: Data = {() -> Data in
        if let d = "start".data(using: String.Encoding.ascii){
            return d
        }
        fatalError("Data start")
    }()
    
    static let dummy: Data = {() -> Data in
        if let d = "dummy".data(using: String.Encoding.ascii){
            return d
        }
        fatalError("Data dummy")
    }()
    
}





extension URL{
    static var prefer: URL?{
        var preferURL: URL? = nil
        if let fileName = Bundle.main.bundleIdentifier, let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first{
            let preferences = library.appendingPathComponent("Preferences")
            preferURL = preferences.appendingPathComponent(fileName).appendingPathExtension("plist")
        }
        return preferURL
    }
    
    
    static var dir: String{
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
        
    
}





extension String{
    static let dummy = "嗯嗯"
}




extension String {
    var fileName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    var fileExtension: String{
        URL(fileURLWithPath: self).pathExtension
    }
    
    
    
    var write: String{
        let path = "\(URL.dir)/\(self)"
        if FileManager.default.fileExists(atPath: path) == false{
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        return path
    }
    
    
    
    func taskWrite(folder p: String, suffix name: String) -> String{
        let path = "\(URL.dir)/\(p)/\(name)"
        
        if FileManager.default.fileExists(atPath: path) == false{
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        return path
    }
}



