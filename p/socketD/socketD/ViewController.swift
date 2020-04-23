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

        // Setup View
        [self setupView];
        
        self.boardView.layer.borderColor = UIColor.blueColor.CGColor;
        self.boardView.layer.borderWidth = 1;
    }





    func setupView(){
        // Reset Game
        [self resetGame];
     
        // Configure Subviews
        [self.boardView setHidden:YES];
        [self.replayButton setHidden:YES];
        [self.disconnectBtn setHidden:YES];
        [self.gameStateLabel setHidden:YES];
        
        
        // Add Tap Gesture Recognizer
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addDiscToColumn:)];
        [self.boardView addGestureRecognizer:tgr];
    }



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
                alert.dismiss(animated: true) {
                }
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
        
                  
        
     
        if (!_hasWon) {
            // Check Diagonal Matches - Second Pass
            for (int i = 0; i < kMTMatrixWidth; i++) {
                _counter = 0;
     
                // Forward
                for (int j = i, row = (kMTMatrixHeight - 1); j < kMTMatrixWidth && row >= 0; j++, row--) {
                    BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:row];
                    _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                    _hasWon = (_counter > 3) ? YES : _hasWon;
     
                    if (_hasWon) break;
                }
     
                if (_hasWon) break;
     
                _counter = 0;
     
                // Backward
                for (int j = i, row = (kMTMatrixHeight - 1); j >= 0 && row >= 0; j--, row--) {
                    BoardCell *cell = [(NSArray *)[self.board objectAtIndex:j] objectAtIndex:row];
                    _counter = (cell.cellType == targetType) ? _counter + 1 : 0;
                    _hasWon = (_counter > 3) ? YES : _hasWon;
     
                    if (_hasWon) break;
                }
     
                if (_hasWon) break;
            }
        }
     
        // Update Game State
        if (_hasWon) {
            self.gameState = GameStateYourOpponentWin;
            if (playerType == PlayerTypeMe){
                self.gameState = GameStateIWin;
            }
        }
     
        return _hasWon;
    }

    
    
    


    func showWinner(){
        if (self.gameState < GameStateIWin){
            return;
        }
     
        // Show Replay Button
        [self.replayButton setHidden:NO];
     
        NSString *message = nil;
     
        if (self.gameState == GameStateIWin) {
            message = @"赢啦 ✌️ - You have won the game.";
        } else if (self.gameState == GameStateYourOpponentWin) {
            message = @"你 gg 了，Your opponent has won the game.";
        }
     
        // Show Alert
        UIAlertController * alert = [UIAlertController alertControllerWithTitle: @"We Have a Winner" message: message preferredStyle: UIAlertControllerStyleAlert];
                                  
        UIAlertAction * ok = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
                                  
        [alert addAction: ok];
        [self presentViewController: alert animated: YES completion:^{
        }];
        
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
