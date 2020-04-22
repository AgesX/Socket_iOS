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
    
    
    weak var delegate: JoinListCtrlDelegate?

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
