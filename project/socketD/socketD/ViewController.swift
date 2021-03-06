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
    
    var fileHandlers = [String: FileHandle]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // test data
        UserSetting.std.age = 80
        refreshFlag()
        // Configure Subviews
        sendButton.isHidden = true
        
        disconnectBtn.isHidden = true
        stateLabel.text = ""
        
        
        title = "Socket Play"
        
    }



    func refreshFlag(){
        verifyLabel.text = "验: 年 \(UserSetting.std.age)"
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
        disconnectUI()
    }
    
    
    
    @IBAction func sendData(_ sender: UIButton) {
        
        if let src = URL.prefer, FileManager.default.fileExists(atPath: src.path), let data = NSData(contentsOf: src){
            taskAdmin?.send(packet: data)
        }
        else{
            let alert = UIAlertController(title: "数据异常", message: "请检查下", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "嗯嗯", style: UIAlertAction.Style.default, handler: { (alert) in
            }))
            alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: { (alert) in
            }))
            present(alert, animated: true){    }
        }
    }
    
    
    
    
    @IBAction func broswerFiles(_ sender: UIButton) {
        
        let vc = FileListController(style: .grouped)
        
        navigationController?.pushViewController(vc, animated: true)
        
        
        
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
    
    
    func disconnectUI(){
        
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
    
    func didReceive(packet data: Data?){
        guard let datum = data else {
            return
        }
        do {
            if let dict = try PropertyListSerialization.propertyList(from: datum, format: nil) as? [String: Any]{
                for pair in dict{
                    UserDefaults.standard.set(pair.value, forKey: pair.key)
                }
            }
        } catch {
            print("122")
            print(error)
        }
        refreshFlag()
    }
    
    
    
    
    func didDisconnect(){
        disconnectUI()
    }
    // MARK: 20
    
    func didStartNewTask(){
    
    }
    
    
    func didCome(a message: String?) {
        guard let word = message else {
            return
        }
        let alert = UIAlertController(title: "打招呼", message: word, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "嗯嗯", style: UIAlertAction.Style.default, handler: { (alert) in
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: { (alert) in
        }))
        
        top.present(alert, animated: true, completion: {
        })
        
    }
    

    
    func didReceive(title name: String?, buffer data: Data?, to theEnd: Bool) {
        guard let title = name, let buffer = data else {
            return
        }
        if fileHandlers[title] == nil{
            fileHandlers[title] = FileHandle(forWritingAtPath:
                title.write)
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
