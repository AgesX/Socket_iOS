//
//  FileAdd.swift
//  socketD
//
//  Created by Jz D on 2020/10/1.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


extension FileManager{
    func clearAllFile(at path: String) {
        do
        {
            let fileName = try contentsOfDirectory(atPath: path)

            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: path).appendingPathComponent(file).absoluteURL
                try removeItem(at: filePath)
            }
            let dir = URL(fileURLWithPath: path)
            try removeItem(at: dir)
        }catch let error {
            print(error.localizedDescription)
        }
    }
}
