//
//  StudySegmentCel.swift
//  socketD
//
//  Created by Jz D on 2020/7/14.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

class StudySegmentCel: UICollectionViewCell {

    
    @IBOutlet weak var txt: UILabel!
    
    
    func config(segments t: String){
        txt.text = t
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
