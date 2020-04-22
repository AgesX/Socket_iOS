//
//  GameManager.swift
//  socketD
//
//  Created by Jz D on 2020/4/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation


protocol GameManagerProxy: class{
    
    
    func didAddDisc(manager: GameManager, to column: GameManager)
    func didDisconnect(manager: GameManager)
    func didStartNewGame(manager: GameManager)

}


struct Tag {
    static let head = 0
    static let body = 1
}


class GameManager : NSObject, GCDAsyncSocketDelegate {
    

    weak var delegate: GameManagerProxy?

    let socket: GCDAsyncSocket
    
    
    init(socket s: GCDAsyncSocket){
        socket = s
        super.init()
    }



    func startNewGame(){
        let packet = PacketH(info: [:], type: .startNewGame, action: .go)
        send(packet: packet)
    }


    func addDiscToColumn(column: Int){
        
    }

    
    func send(packet p: PacketH){
        
        
    }

    
    func parse(header data: NSData) -> UInt64{
        print("header 来了")
        var headerLength: UInt64 = 0
        data.getBytes(&headerLength, length: MemoryLayout<UInt64>.size)
        return headerLength
        
        
    }


    
    
    
    func sendPacket(p packet: PacketH){
        
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
                    buffer.append(address, length: MemoryLayout<UInt64>.size)
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



    
     
        
    


    
}




