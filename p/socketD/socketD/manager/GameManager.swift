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


class GameManager : NSObject, GCDAsyncSocketDelegate {
    

    weak var delegate: GameManagerProxy?

    let socket: GCDAsyncSocket
    
    
    init(socket s: GCDAsyncSocket){
        socket = s
        super.init()
    }



    func startNewGame(){
        
        
    }


    func addDiscToColumn(column: Int){
        
    }


    
    
}




