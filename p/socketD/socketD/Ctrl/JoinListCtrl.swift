//
//  JoinListCtrl.swift
//  socketD
//
//  Created by Jz D on 2020/4/23.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


protocol JoinListCtrlDelegate: class{

    
    func didJoinGame(c controller: JoinListCtrl, on socket: GCDAsyncSocket)
    
    func didCancelJoining(c controller: JoinListCtrl)

}



class JoinListCtrl: UITableViewController{

    var services = [NetService]()
    var socket: GCDAsyncSocket?
    var serviceBrowser: NetServiceBrowser?
    
    weak var delegate: JoinListCtrlDelegate?

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
        serviceBrowser.delegate = self
        serviceBrowser?.searchForServices(ofType: "_deng._tcp.", inDomain: "local.")
    }

    
    

    func stopBrowsing(){
        serviceBrowser?.stop()
        serviceBrowser?.delegate = nil
        serviceBrowser = nil
    }


    func connectWith(service s: NetService) -> Bool{
        BOOL _isConnected = NO;
     
        // Copy Service Addresses
        NSArray *addresses = [[service addresses] mutableCopy];
     
        if (!self.socket || ![self.socket isConnected]) {
            // Initialize Socket
            NSLog(@"Initialize Socket, 新建了 Socket");
            self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
     
            // Connect
            while (!_isConnected && [addresses count]) {
                NSData *address = [addresses objectAtIndex:0];
     
                NSError *error = nil;
                if ([self.socket connectToAddress:address error:&error]) {
                    _isConnected = YES;
     
                } else if (error) {
                    NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
                }
            }
     
        } else {
            _isConnected = [self.socket isConnected];
        }
     
        return _isConnected;
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
     
        
        
        if ([self connectWithService:service]) {
            NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
        } else {
            NSLog(@"XXX: Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
        }
    }


  
}


extension JoinListCtrl: GCDAsyncSocketDelegate{
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {

           print("Socket Did Connect to Host: \(host) Port: \(port)")
        
           // Notify Delegate
           delegate?.didJoinGame(c: self, on: sock)

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
        
        // Resolve Service
        service.delegate = self
        // 点击，服务就 gg
        service.resolve(withTimeout: 30.0)
    }



}

