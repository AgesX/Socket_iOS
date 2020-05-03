//
//  ViewController.swift
//  socketD
//
//  Created by Jz D on 2020/4/15.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


enum TaskState: Int{
    case unknown = -1, myTurn, yourOpponentTurn, IWin, yourOpponentWin
}




enum PlayerType: Int{
    case me = 0, you
}



class ViewController: UIViewController {

    
    @IBOutlet weak var hostBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    
    @IBOutlet weak var disconnectBtn: UIButton!
    
    
    @IBOutlet weak var sendButton: UIButton!
   
    var gameManager: TaskManager?
    
  


    override func viewDidLoad() {
        super.viewDidLoad()

        // test data
        UserSetting.std.age = 80
    }



    

// MARK: 5
    
    


    
    // MARK: target action

    @IBAction func hostTask(_ sender: UIButton) {
        
        // Initialize Host Task View Controller
        let vc = HostViewCtrl()
       
              // Configure Host Task View Controller
        vc.delegate = self
      
              // Initialize Navigation Controller
        let nc = UINavigationController(rootViewController: vc)

              // Present Navigation Controller
        present(nc, animated: true) {
        }
    }
    
    
    @IBAction func joinTask(_ sender: UIButton) {
        
        // Initialize Join Task View Controller
        let vc = JoinListCtrl(style: .plain)
        
           // Configure Join Task View Controller
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
    
    
    // MARK: game relevant

    func startTask(with socket: GCDAsyncSocket){
        // Initialize Task Controller
        gameManager = TaskManager(socket: socket)
        gameManager?.delegate = self
    
        // Hide/Show Buttons
        
        sendButton.isHidden = false
        hostBtn.isHidden = true
        
        joinBtn.isHidden = true
        disconnectBtn.isHidden = false
    }
    
    
    func endTask(){
        
        // Clean Up
        gameManager?.delegate = nil
        gameManager = nil
               
        // Hide/Show Buttons
        sendButton.isHidden = true
        hostBtn.isHidden = false
        
        joinBtn.isHidden = false
        disconnectBtn.isHidden = true
        
        
    }
  
}



extension ViewController: HostViewCtrlDelegate{
    func didHostTask(c controller: HostViewCtrl, On socket: GCDAsyncSocket) {
        
        startTask(with: socket)
    }
    
    // MARK: 15
    
    func didCancelHosting(c controller: HostViewCtrl) {
        print("\(#file), \(#function)")
    }
    
}




extension ViewController: JoinListCtrlDelegate{
    func didJoinTask(c controller: JoinListCtrl, on socket: GCDAsyncSocket) {
    
        startTask(with: socket)
    }
    
    
    func didCancelJoining(c controller: JoinListCtrl) {
        print("\(#file), \(#function)")
    }
}




extension ViewController: TaskManagerProxy{
    func didAddDisc(manager: TaskManager, to column: UInt) {
       
    }
    
    func didDisconnect(manager: TaskManager) {
       
    }
    // MARK: 20
    
    func didStartNewTask(manager: TaskManager) {
    
    }
    
}