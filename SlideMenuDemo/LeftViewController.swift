//
//  LeftViewController.swift
//  SlideMenuDemo
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    
    @IBAction func hide(sender: AnyObject) {
        slideMenuController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
