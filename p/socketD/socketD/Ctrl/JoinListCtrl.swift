//
//  JoinListCtrl.swift
//  socketD
//
//  Created by Jz D on 2020/4/22.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


protocol JoinListCtrlDelegate: class{

    
    func didJoinGame(c controller: JoinListCtrl, on socket: GCDAsyncSocket)
    
    func didCancelJoining(c controller: JoinListCtrl)

}



class JoinListCtrl: UIViewController {

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


}




extension JoinListCtrl: NetServiceDelegate{
    
    
  
}


extension JoinListCtrl: NetServiceBrowserDelegate{
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        
        
        // Update Services
        services.append(service)
     
        if !moreComing{
            // Sort Services
            [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
     
            // Update Table View
            [self.tableView reloadData];
        }
    }


    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        
        // Update Services
        [self.services removeObject:service];
     
        if !moreComing{
            // Update Table View
            [self.tableView reloadData];
        }
    }


    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        stopBrowsing()
        
    }



    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        stopBrowsing()
        
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
