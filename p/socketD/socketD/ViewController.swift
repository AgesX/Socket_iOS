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



struct Matrix{
    static let w = 7
    static let h = 6
}


class ViewController: UIViewController {

    
    @IBOutlet weak var hostBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    
    @IBOutlet weak var disconnectBtn: UIButton!
    @IBOutlet weak var boardView: UIView!
    
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var gameStateLabel: UILabel!
    
    var gameManager: GameManager?
    var gameState = GameState.myTurn
    
    
    
    // 数据，未更改
    var board = [[BoardCell]]()


    // 数据，已经更改
    var matrix = [[BoardCellType]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Setup View
        
        self.boardView.layer.borderColor = UIColor.blue.cgColor;
        self.boardView.layer.borderWidth = 1;
    }





    func setupView(){
        // Reset Game
        resetGame()

        // Configure Subviews
        boardView.isHidden = true
        replayButton.isHidden = true
        
        disconnectBtn.isHidden = true
        gameStateLabel.isHidden = true
  
        // Add Tap Gesture Recognizer
        let tgr = UITapGestureRecognizer(target: self, action: #selector(ViewController.addDiscToColumn(tap:)))
        boardView.addGestureRecognizer(tgr)
    }



    @objc
    func addDiscToColumn(tap tgr: UITapGestureRecognizer){
        
        switch gameState {
        case .myTurn:
    
            let colume = column(for: tgr.location(in: tgr.view))
            addDiscTo(column: colume, with: .mine)
            gameState = .yourOpponentTurn
            
            // Send Packet
            gameManager?.addDiscTo(column: colume)
                  
                   
            // Notify Players if Someone Has Won the Game
            if hasPlayerWon(of: .me){
                showWinner()
            }
        case .yourOpponentWin:
            showWinner()
        default:
            //  .unknown, .yourOpponentTurn, .IWin
            let alert = UIAlertController(title: "It's not your turn.", message: "Warning 不啊", preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (act) in
            }
            alert.addAction(ok)
            present(alert, animated: true) {
            }
        }
        
  
    }


    
    


    func hasPlayerWon(of type: PlayerType) -> Bool{
        var hasWon = false
        var counter = 0;
        var targetType = BoardCellType.yours
        if type == .me{
            targetType = .mine
        }
        // Check Vertical Matches
        // 竖着来
        for line in board{
            counter = 0
            for cell in line{
                if cell.cellType == targetType{
                    counter += 1
                }
                else{
                    counter = 0
                }
                hasWon = (counter > 3)
                if hasWon{
                    break
                }
            }
            if hasWon{
                break
            }
        }
        if hasWon == false{
            for i in 0..<(Matrix.h){
                counter = 0
                for j in 0..<Matrix.w{
                    let cell = board[j][i]
                    if cell.cellType == targetType{
                        counter += 1
                    }
                    else{
                        counter = 0
                    }
                    hasWon = (counter > 3)
                    if hasWon{
                        break
                    }
                }
                if hasWon{
                    break
                }
            }
        }
        if hasWon == false{
            for i in 0..<Matrix.w{
                // 算法有问题，所以需要正着来一遍，倒着来一遍
                counter = 0
                var j = i
                var row = 0
                while j < Matrix.w, row < Matrix.h {
                    let cell = board[j][row]
                    if cell.cellType == targetType{
                        counter += 1
                    }
                    else{
                        counter = 0
                    }
                    hasWon = (counter > 3)
                    if hasWon{
                        break
                    }
                    j += 1
                    row += 1
                }
                
                if hasWon{
                    break
                }
                
                // Backward
                
                counter = 0
                j = i
                row = 0
                while j > 0, row < Matrix.h{
                    let cell = board[j][row]
                    if cell.cellType == targetType{
                        counter += 1
                    }
                    else{
                        counter = 0
                    }
                    hasWon = (counter > 3)
                    if hasWon{
                        break
                    }
                    j -= 1
                    row += 1
                }
                if hasWon{
                    break
                }
                
            }
            
            
        }
        
        if hasWon == false{
           
            // Check Diagonal Matches - Second Pass
            for i in 0..<Matrix.w{
                
                counter = 0;
     
                // Forward
                var j = i
                var row = Matrix.h - 1
                while j < Matrix.w, row >= 0 {
                    let cell = board[j][row]
                    if cell.cellType == targetType{
                        counter += 1
                    }
                    else{
                        counter = 0
                    }
                    hasWon = (counter > 3)
                    
                    if hasWon{
                        break
                    }
                    
                    j += 1
                    row -= 1
                }
                if hasWon{
                    break
                }
                
                 counter = 0;
                
     
                // Backward
                j = i
                row = Matrix.h - 1
                while j >= 0, row >= 0{
                    let cell = board[j][row]
                    if cell.cellType == targetType{
                        counter += 1
                    }
                    else{
                        counter = 0
                    }
                    hasWon = (counter > 3)
                    
                    if hasWon{
                        break
                    }
                    j -= 1
                    row -= 1
                }
                
                if hasWon{
                    break
                }
                
       

     
            }
        }
     
        // Update Game State
        if hasWon{
            gameState = .yourOpponentWin
            if type == .me{
                gameState = .IWin
            }
     
        }
        return hasWon
    }

    
    
    


    func showWinner(){
        
        switch gameState {
        case .IWin, .yourOpponentWin:
            replayButton.isHidden = false
            var message = "你 gg 了，Your opponent has won the game."
            if case GameState.IWin = gameState{
                message = "赢啦 ✌️ - You have won the game."
            }
            let alert = UIAlertController(title: "We Have a Winner", message: message, preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { (act) in
            }
            alert.addAction(ok)
            present(alert, animated: true) {
            }
        default:
            ()
        }
        
    }


    
    
    func addDiscTo(column c: UInt, with type: BoardCellType){
        // Update Matrix
        var columnArray = matrix[c]
        columnArray.append(type)
     
        // Update Cells
        if let cell = board[c].last{
            cell.cellType = type
        }
        
    }
    
    
    


    func resetGame(){
        for eles in board{
            eles.forEach { $0.removeFromSuperview() }
        }
        board = []
        matrix = []
        
        // Hide Replay Button
        replayButton.isHidden = true
     
        // Helpers
        let size = boardView.frame.size
        let cellWidth = size.width / Matrix.w
        let cellHeight = size.height / Matrix.h
        var buffer = [[BoardCell]]()
        for i in 0..<Matrix.w{
            var column = [BoardCell]()
            for j in 0..<Matrix.h{
                let frame = CGRect(x: i * cellWidth, y: size.height - (j + 1) * cellHeight, width: cellWidth, height: cellHeight)
                let cell = BoardCell(frame: frame)
                cell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                boardView.addSubview(cell)
                column.append(cell)
            }
            buffer.append(column)
        }
        board = buffer
        matrix = [[]]
    }




    
    @IBAction func hostGame(_ sender: UIButton) {
        
        
        
        
    }
    
    
    
    
    
    @IBAction func joinGame(_ sender: UIButton) {
        
        
        
        
        
    }
    
    
    
    
    
    @IBAction func disconnectIt(_ sender: UIButton) {
        
        
        
        
        
    }
    
    
    
    @IBAction func replayGame(_ sender: UIButton) {
        
        
        
        
        
        
    }
    
    
    

    
    func column(for point: CGPoint) -> UInt{
        return UInt(point.x)/UInt(boardView.frame.size.width / Matrix.w);
    }




    
    func updateView(){
        // Update Game State Label
        switch gameState{
            case .myTurn:
               gameStateLabel.text = "It is your turn."
            case .yourOpponentTurn:
               gameStateLabel.text = "It is your opponent's turn."
            case .IWin:
               gameStateLabel.text = "You have won."
            case .yourOpponentWin:
               gameStateLabel.text = "Your opponent has won."
            default:
               gameStateLabel.text = nil
        }
    }

}






extension Array {
    public subscript(index: UInt) -> Element {
        return self[Int(index)]
    }
}



public func / (left: CGFloat, right: Int) -> CGFloat {
    return left/CGFloat(right)
}


public func * (left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}


public func * (left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) * right
}
