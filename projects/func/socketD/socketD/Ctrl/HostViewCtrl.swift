//
//  HostViewCtrl.swift
//  socketD
//
//  Created by Jz D on 2020/4/22.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


protocol HostViewCtrlDelegate: class{
    func didHostTask(c controller: HostViewCtrl, On socket: GCDAsyncSocket)
    func didCancelHosting(c controller: HostViewCtrl)
}


class HostViewCtrl: UIViewController {

    
    weak var delegate: HostViewCtrlDelegate?
    
    var service: NetService?
    var socket: GCDAsyncSocket?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        startBroadcast()
    }
    


    

    func setupView(){
        // Create Cancel Button
        view.backgroundColor = UIColor.yellow
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    }


    
    @objc
    func cancel(){
        delegate?.didCancelHosting(c: self)
        endBroadcast()
        dismiss(animated: true) {
        }
    }



    
    
    func startBroadcast(){
        // Initialize GCDAsyncSocket
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            

        do {
            try socket?.accept(onPort: 0)
            service = NetService(domain: "local.", type: "_deng._tcp.", name: "", port: Int32(socket?.localPort ?? 0))
            service?.delegate = self
            service?.publish()
        } catch{
            print("Unable to create socket. Error \(error) with user info .")
        }

    }


    

    func endBroadcast(){
        socket?.setDelegate(nil, delegateQueue: nil)
        socket = nil
        
        service?.delegate = nil
        service = nil
    }


    
}



extension HostViewCtrl: NetServiceDelegate{
    
    
    func netServiceWillPublish(_ sender: NetService) {
        print("∑  ø  Bonjour sender Published: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port)")
    }
    
    
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("Failed to Publish sender: domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) port(\(sender.port)")
    }
}


extension HostViewCtrl: GCDAsyncSocketDelegate{
    
    
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {

        
        print("Accepted New Socket from \(sock.connectedHost): \(sock.connectedPort)")
        delegate?.didHostTask(c: self, On: newSocket)
        endBroadcast()
        dismiss(animated: true) {
        }
    }



}
