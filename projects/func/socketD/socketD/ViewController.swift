//
//  ViewController.swift
//  socketD
//
//  Created by Jz D on 2020/4/15.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


enum GameState: Int{
    case unknown = -1, myTurn, yourOpponentTurn, IWin, yourOpponentWin
}




enum PlayerType: Int{
    case me = 0, you
}



struct Matrix{
    static let w = 7
    static let h = 6
}


class ViewController: UIViewController {

    
    @IBOutlet weak var hostBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    
    @IBOutlet weak var disconnectBtn: UIButton!
    
    
    @IBOutlet weak var sendButton: UIButton!
   
    var gameManager: GameManager?
    
  


    override func viewDidLoad() {
        super.viewDidLoad()

      
    }



    

// MARK: 5
    
    // MARK: game relevant

    func startGame(with socket: GCDAsyncSocket){
        // Initialize Game Controller
        gameManager = GameManager(socket: socket)
        gameManager?.delegate = self
  
    }


    
    // MARK: target action

    @IBAction func hostGame(_ sender: UIButton) {
        
        // Initialize Host Game View Controller
        let vc = HostViewCtrl()
       
              // Configure Host Game View Controller
        vc.delegate = self
      
              // Initialize Navigation Controller
        let nc = UINavigationController(rootViewController: vc)

              // Present Navigation Controller
        present(nc, animated: true) {
        }
    }
    
    
    @IBAction func joinGame(_ sender: UIButton) {
        
        // Initialize Join Game View Controller
        let vc = JoinListCtrl(style: .plain)
        
           // Configure Join Game View Controller
        vc.delegate = self
        
           // Initialize Navigation Controller
        let nc = UINavigationController(rootViewController: vc)

           // Present Navigation Controller
        present(nc, animated: true) {
        }
    }
    
    

    
    @IBAction func disconnectIt(_ sender: UIButton) {
      
    }
    
    
    
    @IBAction func sendData(_ sender: UIButton) {
        
      

    }
    
    
  
}



extension ViewController: HostViewCtrlDelegate{
    func didHostGame(c controller: HostViewCtrl, On socket: GCDAsyncSocket) {
        
        startGame(with: socket)
    }
    
    // MARK: 15
    
    func didCancelHosting(c controller: HostViewCtrl) {
        print("\(#file), \(#function)")
    }
    
}




extension ViewController: JoinListCtrlDelegate{
    func didJoinGame(c controller: JoinListCtrl, on socket: GCDAsyncSocket) {
    
        startGame(with: socket)
    }
    
    
    func didCancelJoining(c controller: JoinListCtrl) {
        print("\(#file), \(#function)")
    }
}




extension ViewController: GameManagerProxy{
    func didAddDisc(manager: GameManager, to column: UInt) {
       
    }
    
    func didDisconnect(manager: GameManager) {
       
    }
    // MARK: 20
    
    func didStartNewGame(manager: GameManager) {
    
    }
    
}
