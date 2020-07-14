//
//  CollectionViewMore.swift
//  socketD
//
//  Created by Jz D on 2020/7/14.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit



protocol CellReuse {
    static var id: String {get}
}




extension UICollectionReusableView: CellReuse{
    static var id :String {
        return String(describing: self)
    }
}
    



extension UICollectionReusableView{
    static let header = "UICollectionElementKindSectionHeader"
    
    static let footer = "UICollectionElementKindSectionFooter"
    
    static let placeHolder = UICollectionReusableView()
}





extension UICollectionView{
    
    func register<T: CellReuse>(cell forNib: T.Type){
        register(UINib(nibName: forNib.id, bundle: nil), forCellWithReuseIdentifier: forNib.id)
    }
    
    
    func dequeue<T: CellReuse>(cell forNib: T.Type, ip indexPath: IndexPath) -> T{
        
        return dequeueReusableCell(withReuseIdentifier: forNib.id, for: indexPath) as! T
    }
    
    
    
    func register<T: CellReuse>(header forNib: T.Type){
        register(UINib(nibName: forNib.id, bundle: nil), forSupplementaryViewOfKind: UICollectionReusableView.header, withReuseIdentifier: forNib.id)
           
    }
       
       
    func dequeue<T: CellReuse>(header forNib: T.Type, ip indexPath: IndexPath) -> T{
       
        return dequeueReusableSupplementaryView(ofKind: UICollectionReusableView.header, withReuseIdentifier: forNib.id, for: indexPath) as! T
    }

    func register<T: CellReuse>(footer forNib: T.Type){
        register(UINib(nibName: forNib.id, bundle: nil), forSupplementaryViewOfKind: UICollectionReusableView.footer, withReuseIdentifier: forNib.id)
           
    }
       
       
    func dequeue<T: CellReuse>(footer forNib: T.Type, ip indexPath: IndexPath) -> T{
       
        return dequeueReusableSupplementaryView(ofKind: UICollectionReusableView.footer, withReuseIdentifier: forNib.id, for: indexPath) as! T
    }
    
}




