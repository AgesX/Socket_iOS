//
//  TaskManager.swift
//  socketD
//
//  Created by Jz D on 2020/4/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


protocol TaskManagerProxy: class{
    func didReceive(packet data: Data?)
    func didDisconnect()
    func didStartNewTask()
    
    func didCome(a message: String?)
    func didReceive(title name: String?, buffer data: Data?, to theEnd: Bool)
    
    func didReceive(folder p: String?, title name: String?, buffer data: Data?, to theEnd: Bool)
}


enum Tag: Int{
    case head = 0
    case file = 1
    case buffer = 2
    case word = 3
    
    
}


class TaskManager : NSObject{
    

    weak var delegate: TaskManagerProxy?

    var socket: GCDAsyncSocket
    
    private var fileAdmin: FileAdminister?
    
    init(socket s: GCDAsyncSocket){
        socket = s
        super.init()
        socket.delegate = self
        socket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: Tag.head.rawValue)
    }


    func startNewTask(){
        let packet = Package(package: Data.start, type: PacketType.start)
        send(with: packet)
    }



    
  
    
    func send(file url: URL){
        fileAdmin = FileAdminister(url: url)
        sendFile()
    }
    
    
    
    fileprivate
    func sendFile(){
        let toTheEnd: Bool = fileAdmin?.tillEnd ?? true
        guard toTheEnd == false else {
            stopSendingFile()
            return
        }
        do {
            try fileAdmin?.handler?.seek(toOffset: fileAdmin?.offset ?? 0)
            fileAdmin?.offsetForward()
            guard let body = fileAdmin?.handler?.readData(ofLength: Int(fileAdmin?.offset ?? 0)) else{
                return
            }
            let packet = Package(buffer: body, name: (fileAdmin?.name ?? String.dummy), to: toTheEnd)
            let encoded = try NSKeyedArchiver.archivedData(withRootObject: packet, requiringSecureCoding: false)
                
                // Initialize Buffer
                let buffer = NSMutableData()
            
               // buffer = header + packet
               
               // Fill Buffer
                var headerLength = encoded.count
               
                buffer.append(&headerLength, length: MemoryLayout<UInt64>.size)
                encoded.withUnsafeBytes { (p) in
                    let bufferPointer = p.bindMemory(to: UInt8.self)
                    if let address = bufferPointer.baseAddress{
                        buffer.append(address, length: headerLength)
                    }
                }
                
               // Write Buffer
                if let d = buffer.copy() as? Data{
                    socket.write(d, withTimeout: -1.0, tag: Tag.buffer.rawValue)
                }
            
        }catch{
            print(error)
        }
           
    }
    
    fileprivate
    func stopSendingFile(){
        do {
            try fileAdmin?.handler?.close()
        } catch {
            print(error)
        }
        fileAdmin = nil
        
    }
    
    
    func send(packet data: NSData){
        // Send Packet
        let packet = Package(package: Data(referencing: data), type: PacketType.sendData)
        send(with: packet)
    }
    
    
    fileprivate
    func send(with packet: Package){
          
          
               // packet to buffer
               // 包，到 缓冲
                 
               // Encode Packet Data

               do {
                   let encoded = try NSKeyedArchiver.archivedData(withRootObject: packet, requiringSecureCoding: false)
                       
                       // Initialize Buffer
                       let buffer = NSMutableData()
                   
                      // buffer = header + packet
                      
                      // Fill Buffer
                       var headerLength = encoded.count
                      
                       buffer.append(&headerLength, length: MemoryLayout<UInt64>.size)
                       encoded.withUnsafeBytes { (p) in
                           let bufferPointer = p.bindMemory(to: UInt8.self)
                           if let address = bufferPointer.baseAddress{
                               buffer.append(address, length: headerLength)
                           }
                       }
                  // Write Buffer
                   if let d = buffer.copy() as? Data{
                       socket.write(d, withTimeout: -1.0, tag: 0)
                   }
                   
                   
               } catch {
                   print(error)
               }
               
               
      }

    
    
    func send(message txt: String){
        
             // packet to buffer
             // 包，到 缓冲
               
             // Encode Packet Data
             let packet = Package(message: txt)
             do {
            
                 let encoded = try NSKeyedArchiver.archivedData(withRootObject: packet, requiringSecureCoding: false)
                      
                  // Initialize Buffer
                  let buffer = NSMutableData()
                  
                  // buffer = header + packet
                     
                 
                  // Fill Buffer
                  var headerLength = encoded.count
                     
                  buffer.append(&headerLength, length: MemoryLayout<UInt64>.size)
                  encoded.withUnsafeBytes { (p) in
                     let bufferPointer = p.bindMemory(to: UInt8.self)
                     if let address = bufferPointer.baseAddress{
                         buffer.append(address, length: headerLength)
                      }
                  }

                // Write Buffer
                 if let d = buffer.copy() as? Data{
                    socket.write(d, withTimeout: -1.0, tag: Tag.word.rawValue)
                 }
                 
                 
             } catch {
                 print(error)
             }
             
             
    }
    
    
    func parse(header data: Data) -> UInt{
        var headerLength: UInt = 0
        NSData(data: data).getBytes(&headerLength, length: MemoryLayout<UInt>.size)
        return headerLength
    }


    
    func parse(body data: Data){
        do {
            NSKeyedUnarchiver.setClass(Package.self, forClassName: "socketG.Package")
            NSKeyedUnarchiver.setClass(Package.self, forClassName: "Package")
            let packet = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, Package.self], from: data) as! Package
            
            switch packet.kind {
            case 1:
                switch packet.type {
                     case .start:
                         delegate?.didStartNewTask()
                     case .sendData:
                         delegate?.didReceive(packet: packet.data)
                     default:
                         ()
                }
            case 2:
                delegate?.didCome(a: packet.word)
            case 3:
                delegate?.didReceive(title: packet.name, buffer: packet.data, to: packet.toTheEnd)
            case 4:
                delegate?.didReceive(folder: packet.word, title: packet.name, buffer: packet.data, to: packet.toTheEnd)
            default:
                ()
            }
            
        } catch {
            print(error)
        }
        
    }

    
}



extension TaskManager: GCDAsyncSocketDelegate{


    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        switch tag{
        case 0:
            let bodyLength = parse(header: data)
            socket.readData(toLength: bodyLength, withTimeout: -1.0, tag: 1)
        case 1:
            parse(body: data)
            socket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: 0)
        default:
            ()
        }
    }


    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if socket == sock{
            socket.delegate = nil;
        }
        stopSendingFile()
        // Notify Delegate
        delegate?.didDisconnect()
    }



    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        if tag == Tag.buffer.rawValue{
            sendFile()
        }
    }
    
}
