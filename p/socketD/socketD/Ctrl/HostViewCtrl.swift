//
//  HostViewCtrl.swift
//  socketD
//
//  Created by Jz D on 2020/4/22.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


protocol HostViewCtrlDelegate: class{
    func didHostGame(c controller: HostViewCtrl, On socket: GCDAsyncSocket)
    func didCancelHosting(c controller: HostViewCtrl)
}


class HostViewCtrl: UIViewController {

    
    weak var delegate: HostViewCtrlDelegate?
    
    var service: NSNetService
    var socket: GCDAsyncSocket

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension HostViewCtrl: NetServiceDelegate{
    
    
    func netServiceWillPublish(_ sender: NetService) {
        print("∑  ø  Bonjour Service Published: domain(\(service.domain)) type(\(service.type)) name(\(service.name)) port(\(service.port)")
    }
    
    
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("Failed to Publish Service: domain(\(service.domain)) type(\(service.type)) name(\(service.name)) port(\(service.port)")
    }
}


extension HostViewCtrl: GCDAsyncSocketDelegate{
    
    
    
}
