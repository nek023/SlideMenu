//
//  RightViewController.swift
//  SlideMenuDemo
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

class RightViewController: UIViewController {

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 4.0
    }
    
    
    // MARK: - Actions
    
    @IBAction func hide(sender: AnyObject) {
        slideMenuController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
