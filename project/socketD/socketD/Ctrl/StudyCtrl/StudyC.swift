//
//  StudyC.swift
//  socketD
//
//  Created by Jz D on 2020/7/14.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


protocol BackPlayDelegate: class {
    func learn(byRepeat material: MusicItem?)
}



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
    
    
    
    
    var desp: [MusicItem]{
        let const = 5 * 60
        let count = Int(duration) / const
        var array = [MusicItem(start: 0, end: duration)]
        guard count > 0 else {
            return array
        }
        array.removeAll()
        for i in 1...count{
            array.append(MusicItem(start: const * (i-1), end: const * i))
        }
        if (duration - TimeInterval(count*const)) > 0.1 * 60{
            array.append(MusicItem(start: const * count, end: duration))
        }
        else{
            array[count-1] = MusicItem(start: const * (count-1), end: duration)
        }
        return array
    }
   
    
    var ipSelected: IndexPath?
    weak var delegate: BackPlayDelegate?
    
    init(delegate proxy: BackPlayDelegate, duration total: TimeInterval) {
        delegate = proxy
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
        var word = desp[indexPath.item].desp
        if indexPath.item == desp.count - 1{
            word = word + " 结束"
        }
        let wid = word.count * 13
        return CGSize(width: wid + 13, height: 80)
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
            cel.config(selected: ipSelected != indexPath)
            if ipSelected == indexPath{
                delegate?.learn(byRepeat: nil)
                ipSelected = nil
            }
            else{
                delegate?.learn(byRepeat: desp[indexPath.item])
                ipSelected = indexPath
            }
        }
        
        
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
        var word = desp[indexPath.item].desp
        if indexPath.item == desp.count - 1{
            word = word + " 结束"
        }
        cel.config(segments: word)
        return cel
    }
    
    
    
  
}
