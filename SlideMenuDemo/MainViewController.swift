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
        
        setTransitionStyle(.Overlay)
    }
    
    func setTransitionStyle(transitionStyle: SlideMenuTransitionStyle) {
        guard let slideMenuController = self.slideMenuController else {
            return
        }
        
        slideMenuController.transitionStyle = transitionStyle
        
        switch transitionStyle {
        case .Overlay:
            slideMenuController.animatedTransition.prelayout = { (transition, transitionContext) in
                guard transition.presenting, let presentedView = transition.presentedView else {
                    return
                }
                
                presentedView.layer.shadowColor = UIColor.blackColor().CGColor
                presentedView.layer.shadowOpacity = 0.4
                presentedView.layer.shadowRadius = 4
            }
            
        case .Shift:
            slideMenuController.animatedTransition.prelayout = { (transition, transitionContext) in
                guard transition.presenting, let snapshotView = transition.snapshotView else {
                    return
                }
                
                snapshotView.layer.shadowColor = UIColor.blackColor().CGColor
                snapshotView.layer.shadowOpacity = 0.4
                snapshotView.layer.shadowRadius = 4
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func valueDidChange(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            setTransitionStyle(.Overlay)
        } else {
            setTransitionStyle(.Shift)
        }
    }
    
    @IBAction func showLeftMenu(sender: AnyObject) {
        slideMenuController?.presentLeftViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showRightMenu(sender: AnyObject) {
        slideMenuController?.presentRightViewControllerAnimated(true, completion: nil)
    }
    
}
