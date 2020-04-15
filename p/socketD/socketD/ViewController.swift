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





class ViewController: UIViewController {

    
    @IBOutlet weak var hostBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBOutlet weak var boardView: UIView!
    
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var gameStateLabel: UILabel!
    
    

    var gameState = GameState.myTurn
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func hostGame(_ sender: UIButton) {
        
        
        
        
    }
    
    
    
    
    
    @IBAction func joinGame(_ sender: UIButton) {
        
        
        
        
        
    }
    
    
    
    
    
    @IBAction func disconnectIt(_ sender: UIButton) {
        
        
        
        
        
    }
    
    
    
    @IBAction func replayGame(_ sender: UIButton) {
        
        
        
        
        
        
    }
    
    

    
    func updateView(){
        // Update Game State Label
        switch gameState{
            case .myTurn:
                self.gameStateLabel.text = "It is your turn."
            case .yourOpponentTurn:
                self.gameStateLabel.text = "It is your opponent's turn."
            case .IWin:
                self.gameStateLabel.text = "You have won."
            case .yourOpponentWin:
                self.gameStateLabel.text = "Your opponent has won."
            default:
                self.gameStateLabel.text = nil
        }
    }

}

