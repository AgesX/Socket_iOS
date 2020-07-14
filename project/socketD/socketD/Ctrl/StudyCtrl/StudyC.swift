//
//  StudyC.swift
//  socketD
//
//  Created by Jz D on 2020/7/14.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

class StudyC: UIViewController {
    
    lazy var contentCollcection: UICollectionView = {
         let layout = UICollectionViewFlowLayout()
         let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
         collection.register(cell: StudySegmentCel.self)
         collection.backgroundColor = UIColor(rgb: 0xF9F8F8)
         
         collection.delegate = self
         collection.dataSource = self
         
         return collection
     }()
    
    let src: URL
    let music: SongInfo
    
    init(music url: URL) {
        src = url
        music = SongInfo(song: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


}



extension StudyC: UICollectionViewDelegate{
    
    
    
    
}


extension StudyC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        return UICollectionViewCell()
    }
    
    
}
