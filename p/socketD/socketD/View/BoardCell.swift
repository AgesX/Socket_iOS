//
//  BoardCell.swift
//  socketD
//
//  Created by Jz D on 2020/4/21.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


enum BoardCellType: Int{
    case empty = -1, mine = 0, yours = 1
}




class BoardCell: UIView {

    var _cellType = BoardCellType.empty
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    var cellType: BoardCellType{
        get{
            return _cellType
        }
        set{
            if _cellType != newValue{
                _cellType = newValue
                updateView()
            }
        }
    }
    
    
        
    func updateView(){
        // Background Color
        switch cellType {
        case .empty:
            backgroundColor = UIColor.yellow
        case .mine:
            backgroundColor = UIColor.red
        default :
            //  .yours
            backgroundColor = UIColor.white
        }
    }
     

    

}
