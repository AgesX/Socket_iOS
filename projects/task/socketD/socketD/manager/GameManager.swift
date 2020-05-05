//
//  TaskManager.swift
//  socketD
//
//  Created by Jz D on 2020/4/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


protocol TaskManagerProxy: class{
    func didReceive(packet data: Data)
    func didDisconnect()
    func didStartNewTask()
    
    func didCome(a message: String)
    func didReceive(_ name: String, buffer data: Data, to theEnd: Bool)
}


enum Tag: Int{
    case head = 0
    case body = 1
    case headStream = 2
    
    case bodyStream = 3
    case hTalk = 4
    case bTalk = 5
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
        let packet = Package(info: Data.start, type: .start)
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
            let packet = Buffer((fileAdmin?.name ?? String.dummy), buffer: body, to: toTheEnd)
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
                    socket.write(d, withTimeout: -1.0, tag: Tag.headStream.rawValue)
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
        let packet = Package(info: Data(referencing: data), type: PacketType.sendData)
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
                   
                   let size = MemoryLayout<UInt>.size
                   var headerLength = encoded.count
                   buffer.append(&headerLength, length: size)
                   encoded.withUnsafeBytes { (p) in
                       let bufferPointer = p.bindMemory(to: UInt64.self)
                       if let address = bufferPointer.baseAddress{
                           buffer.append(address, length: size)
                       }
                   }
                   var val = Tag.bTalk.rawValue
                   buffer.append(&val, length: size)
                   withUnsafeBytes(of: val, { (p) in
                       let bufferPointer = p.bindMemory(to: UInt64.self)
                       if let address = bufferPointer.baseAddress{
                          buffer.append(address, length: size)
                       }
                   })

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
             let packet = Talk(word: txt)
             do {
            
                     let encoded = try NSKeyedArchiver.archivedData(withRootObject: packet, requiringSecureCoding: false)
                     let head = Header(length: encoded.count, tag: Tag.bTalk.rawValue)
                     let encodedH = try NSKeyedArchiver.archivedData(withRootObject: head, requiringSecureCoding: false)
                 
                     // Initialize Buffer
                     let buffer = NSMutableData()
                 
                    // buffer = header + packet
                     
                    // Fill Buffer
                      encodedH.withUnsafeBytes { (p) in
                          let bufferPointer = p.bindMemory(to: UInt64.self)
                          if let address = bufferPointer.baseAddress{
                            buffer.append(address, length: encodedH.count)
                          }
                      }
                      encoded.withUnsafeBytes { (p) in
                          let bufferPointer = p.bindMemory(to: UInt64.self)
                          if let address = bufferPointer.baseAddress{
                              buffer.append(address, length: encoded.count)
                          }
                      }

                // Write Buffer
                 if let d = buffer.copy() as? Data{
                    socket.write(d, withTimeout: -1.0, tag: Tag.hTalk.rawValue)
                 }
                 
                 
             } catch {
                 print(error)
             }
             
             
    }
    
    
    func parse(header data: Data) -> Header{
        do {
            var d = Data()
            NSData(data: data).getBytes(&d, length: MemoryLayout<UInt>.size)
            
            NSKeyedUnarchiver.setClass(Header.self, forClassName: "socketG.Header")
            NSKeyedUnarchiver.setClass(Header.self, forClassName: "Header")
            let head = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [Header.self], from: d) as! Header
            return head
        } catch {
            print(error)
            fatalError()
        }
    }


    
    func parse(body data: Data){
        do {
            NSKeyedUnarchiver.setClass(Package.self, forClassName: "socketG.Package")
            NSKeyedUnarchiver.setClass(Package.self, forClassName: "Package")
            let packet = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, Package.self], from: data) as! Package
             
               print("Packet Data > \(packet.data)")
               print("Packet Type > \(packet.type)")
         
               switch packet.type {
                    case .start:
                        delegate?.didStartNewTask()
                    case .sendData:
                        delegate?.didReceive(packet: packet.data)
                    default:
                        ()
               }
            
        } catch {
            print(error)
        }
        
    }



    func parse(buffer data: Data){
        do {
            NSKeyedUnarchiver.setClass(Buffer.self, forClassName: "socketD.Buffer")
            NSKeyedUnarchiver.setClass(Buffer.self, forClassName: "Buffer")
            let buffer = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [Buffer.self], from: data) as! Buffer
            delegate?.didReceive(buffer.name, buffer: buffer.data, to: buffer.toTheEnd)
            
        } catch {
            print(error)
        }
        
    }
    
    
    func parse(talk data: Data){
        do {
            NSKeyedUnarchiver.setClass(Talk.self, forClassName: "socketD.Talk")
            NSKeyedUnarchiver.setClass(Talk.self, forClassName: "Talk")
            let message = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [Talk.self], from: data) as! Talk
            delegate?.didCome(a: message.word)
            
        } catch {
            print(error)
        }
        
    }
 
    

    


    
}



extension TaskManager: GCDAsyncSocketDelegate{


    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        switch Tag(rawValue: tag) {
        case .head:
            let meta = parse(header: data)
            socket.readData(toLength: UInt(meta.length), withTimeout: -1.0, tag: Int(meta.tag))
        case .body:
            parse(body: data)
            socket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: Tag.head.rawValue)
        case .bodyStream:
            parse(buffer: data)
            socket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: Tag.head.rawValue)
        case .bTalk:
            parse(talk: data)
            socket.readData(toLength: UInt(MemoryLayout<UInt64>.size), withTimeout: -1.0, tag: Tag.head.rawValue)
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
        if tag == Tag.headStream.rawValue{
            sendFile()
        }
    }
    
}
