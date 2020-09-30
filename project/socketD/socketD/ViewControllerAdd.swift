//
//  ViewControllerAdd.swift
//  socketD
//
//  Created by Jz D on 2020/9/30.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


extension ViewController{
    
    
    func didReceive(folder p: String?, title name: String?, buffer data: Data?, to theEnd: Bool) {
        
        guard let title = name, let buffer = data, let dir = p else {
           return
        }
        if fileHandlers[title] == nil{
            let path = title.taskWrite(folder: dir, suffix: title)
            fileHandlers[title] = FileHandle(forWritingAtPath: path)
            print(title.write)
            print("新建  ", fileHandlers[title]?.description ?? "")
        }

        do {
            fileHandlers[title]?.seekToEndOfFile()
            fileHandlers[title]?.write(buffer)
            if theEnd{
                print("至于结尾")
                try fileHandlers[title]?.close()
                fileHandlers.removeValue(forKey: title)
            }
        } catch { print(error) }
        
        
    }
    
    
    
    
}
