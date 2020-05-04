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
   
    var taskAdmin: TaskManager?
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var verifyLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // test data
        UserSetting.std.age = 80
        verifyLabel.text = "验: 年 \(UserSetting.std.age)"
        // Configure Subviews
        sendButton.isHidden = true
        
        disconnectBtn.isHidden = true
        stateLabel.text = ""
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
        endTask()
    }
    
    
    
    @IBAction func sendData(_ sender: UIButton) {
        if let fileName = Bundle.main.bundleIdentifier, let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first{
            let preferences = library.appendingPathComponent("Preferences")
            let userDefaultsPlistURL = preferences.appendingPathComponent(fileName).appendingPathExtension("plist")
            if FileManager.default.fileExists(atPath: userDefaultsPlistURL.path),let data = NSData(contentsOf: userDefaultsPlistURL){
                taskAdmin?.send(packet: Package(info: Data(referencing: data), type: PacketType.sendData))
            }
        }
    }
    
    
    // MARK: game relevant

    func startTask(with socket: GCDAsyncSocket){
        // Initialize Task Controller
        taskAdmin = TaskManager(socket: socket)
        taskAdmin?.delegate = self
    
        // Hide/Show Buttons
        
        sendButton.isHidden = false
        hostBtn.isHidden = true
        
        joinBtn.isHidden = true
        disconnectBtn.isHidden = false
    }
    
    
    func endTask(){
        
        // Clean Up
        taskAdmin?.delegate = nil
        taskAdmin = nil
               
        // Hide/Show Buttons
        sendButton.isHidden = true
        hostBtn.isHidden = false
        
        joinBtn.isHidden = false
        disconnectBtn.isHidden = true
        stateLabel.text = ""
        
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
  
    func didJoinTask(c controller: JoinListCtrl, on socket: GCDAsyncSocket, host name: String) {
        stateLabel.text = "主机: \(name)"
        startTask(with: socket)
    }
    
    
    func didCancelJoining(c controller: JoinListCtrl) {
        print("\(#file), \(#function)")
    }
}




extension ViewController: TaskManagerProxy{
    func didReceive(packet data: Data, by manager: TaskManager){
       
    }
    
    func didDisconnect(manager: TaskManager) {
        endTask()
    }
    // MARK: 20
    
    func didStartNewTask(manager: TaskManager) {
    
    }
    
}
