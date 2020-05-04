//
//  JoinListCtrl.swift
//  socketD
//
//  Created by Jz D on 2020/4/23.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


protocol JoinListCtrlDelegate: class{

    
    func didJoinTask(c controller: JoinListCtrl, on socket: GCDAsyncSocket, host name: String)
    
    func didCancelJoining(c controller: JoinListCtrl)

}



class JoinListCtrl: UITableViewController{

    var services = [NetService]()
    var socket: GCDAsyncSocket?
    var serviceBrowser: NetServiceBrowser?
    
    weak var delegate: JoinListCtrlDelegate?
    var hostName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        startBrowsing()
        
    }
    


    

    func setupView(){
        // Create Cancel Button
        view.backgroundColor = UIColor.yellow
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }


    
    @objc
    func cancel(){
        delegate?.didCancelJoining(c: self)
        stopBrowsing()
        dismiss(animated: true) {
        }
    }
    
    

    func startBrowsing(){
        services = []
     
        // Initialize Service Browser
        serviceBrowser = NetServiceBrowser()
     
        // Configure Service Browser
        serviceBrowser?.delegate = self
        serviceBrowser?.searchForServices(ofType: "_deng._tcp.", inDomain: "local.")
    }

    
    

    func stopBrowsing(){
        serviceBrowser?.stop()
        serviceBrowser?.delegate = nil
        serviceBrowser = nil
    }


    func connectWith(service s: NetService) -> Bool{
        var isConnected = false
     
        // Copy Service Addresses
        guard let addresses = s.addresses else{
            return false
        }
        
        var condition = false
        
        if let ss = socket{
            if ss.isConnected == false{
                condition = true
            }
            else{
                isConnected = ss.isConnected
            }
        }
        if socket == nil || condition{
            
            // Initialize Socket
            
            socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            // Connect
            while isConnected == false, addresses.count > 0 {
                let address = addresses[0]
                
                do {
                    if let sss = socket{
                        try sss.connect(toAddress: address)
                        // 结果 bool ,
                        //  就是 ok,
                        //  不 ok, 顺带 error 信息
                        isConnected = true
                    }
                } catch {
                    print("Unable to connect to address. Error \(error) with user info ")
                }
            }
        }
     
        return isConnected;
    }




}




extension JoinListCtrl: NetServiceDelegate, NetServiceBrowserDelegate{
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        
        
        // Update Services
        services.append(service)
     
        if !moreComing{
            // Sort Services
            services.sort { (lhs, rhs) -> Bool in
                lhs.name > rhs.name
            }
            // Update Table View
            tableView.reloadData()
        }
    }


    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        // Update Services
        if let index = services.firstIndex(where: {  (s) -> Bool in
            s == service
        }){
             services.remove(at: index)
        }
      
        if !moreComing{
            // Update Table View
            tableView.reloadData()
        }
    }


    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        stopBrowsing()
        
    }



    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        stopBrowsing()
        
    }

    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        sender.delegate = nil
    }


    func netServiceDidResolveAddress(_ sender: NetService) {

        // Connect With Service
     
        if connectWith(service: sender){
            print("Did Connect with Service:  domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port)")
        }
        else{
            print("Unable to Connect with Service:  domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port)")
        }
    }


  
}


extension JoinListCtrl: GCDAsyncSocketDelegate{
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {

           print("Socket Did Connect to Host: \(host) Port: \(port)")
        
           // Notify Delegate
           if let n = hostName{
                delegate?.didJoinTask(c: self, on: sock, host: n)
           }

           // Stop Browsing
           stopBrowsing()
        
           // Dismiss View Controller
            dismiss(animated: true) {
            }
    }



}





extension JoinListCtrl{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kServiceCell = "ServiceCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: kServiceCell)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: kServiceCell)
        }
        let service = services[indexPath.row]
        cell?.textLabel?.text = service.name
        return cell ?? UITableViewCell()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
         // Fetch Service
        let service = services[indexPath.row]
        hostName = service.name
        // Resolve Service
        service.delegate = self
        // 点击服务
        service.resolve(withTimeout: 30.0)
    }



}

