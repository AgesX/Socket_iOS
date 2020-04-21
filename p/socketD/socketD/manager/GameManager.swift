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
        
        
        //    memcpy(&headerLength, data.bytes, sizeof(uint64_t));
        
        return headerLength
    }



    
     
        
    


    
}




