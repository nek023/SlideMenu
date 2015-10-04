//
//  UIViewController+SlideMenu.swift
//  SlideMenu
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    var slideMenuController: SlideMenuController? {
        // Find from parent view controller
        var viewController = self.parentViewController
        
        while parentViewController != nil {
            if let slideMenuController = viewController as? SlideMenuController {
                return slideMenuController
            }
            
            viewController = viewController?.parentViewController
        }
        
        // Find from presenting view controller
        if let slideMenuController = presentingViewController as? SlideMenuController {
            return slideMenuController
        }
        
        return nil
    }
    
}
