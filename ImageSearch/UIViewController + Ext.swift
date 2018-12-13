//
//  UIViewController + Ext.swift
//  ImageSearch
//
//  Created by User on 13/04/2018.
//  Copyright © 2018 MPTechnologies. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController {
    
    func showHUD(progressLabel:String){
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = progressLabel
        progressHUD.label.textColor = UIColor(red: 178, green: 34, blue: 34, alpha: 1.0)
        progressHUD.animationType = .zoomOut
        progressHUD.mode = .text
        progressHUD.hide(animated: true, afterDelay: 2.0)
        
    }
    
    func showActivityHUD() {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.animationType = .zoomOut
        progressHUD.mode = .determinate
    }
    
    
    
    func dismissHUD(isAnimated:Bool) {
        MBProgressHUD.hide(for: self.view, animated: isAnimated)
    }
}
