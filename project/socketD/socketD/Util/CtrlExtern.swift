//
//  CtrlExtern.swift
//  socketD
//
//  Created by Jz D on 2020/5/6.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit




extension UIViewController {
    func tp(viewController ctrl: UIViewController){
        let alert = UIAlertController(title: "打招呼", message: "呵呵", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "嗯嗯", style: UIAlertAction.Style.default, handler: { (alert) in
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.default, handler: { (alert) in
        }))
        ctrl.top.present(alert, animated: true, completion: {
            
        })
    }
    
    
    var top: UIViewController{
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.top ?? navigationController
        }
        if let tabController = self as? UITabBarController {
            return tabController.selectedViewController?.top ?? tabController
        }
        if let presented = presentedViewController {
            return presented.top
        }
        return self
    }
}
