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
        
        
    var file: String{
        absoluteString.replacingOccurrences(of: "file://", with: "")
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
        if FileManager.default.fileExists(atPath: self) == false{
            FileManager.default.createFile(atPath: self, contents: nil, attributes: nil)
        }
        return self
    }
    
    
}




struct MyStreamer{
    lazy var fileHandle = FileHandle(forWritingAtPath: logPath)
    

    lazy var logPath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0]
        let filePath = path + "/log.txt"
        if FileManager.default.fileExists(atPath: filePath) == false{
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        print(filePath)
        return filePath

    }()

    mutating func write(_ string: String) {
        print(fileHandle?.description ?? "呵呵")
        fileHandle?.seekToEndOfFile()
        if let data = string.data(using: String.Encoding.utf8){
            fileHandle?.write(data)
        }
    }
}
