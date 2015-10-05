//
//  MainViewController.swift
//  SlideMenuDemo
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit
import SlideMenu

class MainViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    
    @IBAction func showLeftMenu(sender: AnyObject) {
        slideMenuController?.presentLeftViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showRightMenu(sender: AnyObject) {
        slideMenuController?.presentRightViewControllerAnimated(true, completion: nil)
    }
    
}
