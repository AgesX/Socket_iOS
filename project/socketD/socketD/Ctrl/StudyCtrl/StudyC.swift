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
    
    
    let duration: TimeInterval
    
    
    
    
    var desp: [String]{
        let const = 5 * 60
        let count = Int(duration) / const
        var array = ["开始 -> \(duration.formatted) 结束"]
        guard count > 0 else {
            return array
        }
        array.removeAll()
        for i in 1...count{
            array.append("\((const * (i-1)).formatted) -> \((const * i).formatted)")
        }
        if (duration - TimeInterval(count*const)) > 0.1 * 60{
            array.append("\((const * count).formatted) -> \(duration.formatted)")
        }
        else{
            array[count-1] = "\((const * (count-1)).formatted) ->  \(duration.formatted)"
        }
        let first = array[0]
        array[0] = "开始 " + first
        let last = array[array.count - 1]
        array[array.count - 1] = last + "结束"
        return array
    }
   
    
    var ipSelected: IndexPath?
    
    
    
    init(duration total: TimeInterval) {
        
        duration = total
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow
    
        contentCollcection.backgroundColor = .green
        contentCollcection.add(to: view).pinToEdges()
        
    }
    

    
    

}



extension StudyC: UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wid = desp[indexPath.item].count * 13
        return CGSize(width: wid + 8, height: 80)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 3)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 24
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 24
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if let last = ipSelected, let cel = collectionView.cellForItem(at: last) as? StudySegmentCel{
            cel.config(selected: false)
        }
        if let cel = collectionView.cellForItem(at: indexPath) as? StudySegmentCel{
            cel.config(selected: true)
        }
        ipSelected = indexPath
        
    }
    
}


extension StudyC: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return desp.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cel = collectionView.dequeue(cell: StudySegmentCel.self, ip: indexPath)
        if let last = ipSelected, last == indexPath{
            cel.config(selected: true)
        }
        else{
            cel.config(selected: false)
        }
        cel.config(segments: desp[indexPath.item])
        return cel
    }
    
    
    
  
}
