//
//  SlideMenuViewController.swift
//  SlideMenu
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public class SlideMenuController: UIViewController, UIViewControllerTransitioningDelegate, SlideMenuAnimatedTransitionDelegate {
    
    // MARK: - Properties
    
    public let animatedTransition = SlideMenuAnimatedTransition()
    public let interactiveTransition = UIPercentDrivenInteractiveTransition()
    
    public private(set) var interactivelyTransitioning: Bool = false
    
    public private(set) var leftScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    public private(set) var rightScreenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    public var leftViewControllerPresented: Bool {
        guard let leftViewController = self.leftViewController else {
            return false
        }
        
        return (!leftViewController.isBeingPresented()
            && leftViewController.presentingViewController != nil)
    }
    
    public var rightViewControllerPresented: Bool {
        guard let rightViewController = self.rightViewController else {
            return false
        }
        
        return (!rightViewController.isBeingPresented()
            && rightViewController.presentingViewController != nil)
    }
    
    public var mainViewController: UIViewController? {
        willSet {
            if let mainViewController = self.mainViewController {
                mainViewController.willMoveToParentViewController(nil)
                mainViewController.view.removeFromSuperview()
                mainViewController.removeFromParentViewController()
            }
        }
        
        didSet {
            if let mainViewController = self.mainViewController {
                addChildViewController(mainViewController)
                
                let view = mainViewController.view
                view.frame = self.view.bounds
                view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.view.addSubview(view)
                
                mainViewController.didMoveToParentViewController(self)
            }
        }
    }
    
    public var leftViewController: UIViewController?
    public var rightViewController: UIViewController?
    
    public var animationDuration: NSTimeInterval {
        set {
            animatedTransition.animationDuration = newValue
        }
        
        get {
            return animatedTransition.animationDuration
        }
    }
    
    public var completionThreshold: CGFloat = 0.15
    
    public var revealAmount: CGFloat {
        set {
            animatedTransition.revealAmount = newValue
        }
        
        get {
            return animatedTransition.revealAmount
        }
    }
    
    public var transitionStyle: SlideMenuTransitionStyle {
        set {
            animatedTransition.transitionStyle = newValue
        }
        
        get {
            return animatedTransition.transitionStyle
        }
    }
    
    
    // MARK: - Initializers
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        animatedTransition.delegate = self
        interactiveTransition.completionCurve = .EaseOut
        
        setUpScreenEdgePanGestureRecognizers()
    }
    
    public convenience init(mainViewController: UIViewController?, leftViewController: UIViewController?, rightViewController: UIViewController?) {
        self.init(nibName: nil, bundle: nil)
        
        self.mainViewController = mainViewController
        self.leftViewController = leftViewController
        self.rightViewController = rightViewController
        
        // This should be done here because `didSet` of `mainViewController` property
        // is not called when it is set in the initializer.
        if let mainViewController = self.mainViewController {
            addChildViewController(mainViewController)
            
            let view = mainViewController.view
            view.frame = self.view.bounds
            view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.view.addSubview(view)
            
            mainViewController.didMoveToParentViewController(self)
        }
    }
    
    private func setUpScreenEdgePanGestureRecognizers() {
        let leftScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleScreenEdgePanGesture:")
        leftScreenEdgePanGestureRecognizer.edges = [.Left]
        self.leftScreenEdgePanGestureRecognizer = leftScreenEdgePanGestureRecognizer
        view.addGestureRecognizer(leftScreenEdgePanGestureRecognizer)
        
        let rightScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleScreenEdgePanGesture:")
        rightScreenEdgePanGestureRecognizer.edges = [.Right]
        self.rightScreenEdgePanGestureRecognizer = rightScreenEdgePanGestureRecognizer
        view.addGestureRecognizer(rightScreenEdgePanGestureRecognizer)
    }
    
    
    // MARK: - View Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Actions
    
    func handleScreenEdgePanGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let left = (gestureRecognizer == leftScreenEdgePanGestureRecognizer)
        let location = gestureRecognizer.translationInView(gestureRecognizer.view)
        let progress: CGFloat
        if left {
            progress = max(0, min(location.x / revealAmount, 1.0))
        } else {
            progress = max(0, min(-location.x / revealAmount, 1.0))
        }
        
        switch gestureRecognizer.state {
        case .Began:
            interactivelyTransitioning = true
            
            if left {
                presentLeftViewControllerAnimated(true, completion: nil)
            } else {
                presentRightViewControllerAnimated(true, completion: nil)
            }
            
        case .Changed:
            interactiveTransition.updateInteractiveTransition(progress)
            
        case .Cancelled, .Ended, .Failed:
            interactiveTransition.completionSpeed = completionSpeedForProgress(progress)
            
            if progress > completionThreshold {
                interactiveTransition.finishInteractiveTransition()
            } else {
                interactiveTransition.cancelInteractiveTransition()
            }
            
            interactivelyTransitioning = false
            
        default:
            break
        }
    }
    
    
    // MARK: - Interactive Transition
    
    private func completionSpeedForProgress(progress: CGFloat) -> CGFloat {
        return 1.0
    }
    
    
    // MARK: - Managing Menu View Controllers
    
    public func presentLeftViewControllerAnimated(animated: Bool, completion: (() -> Void)?) {
        guard let leftViewController = self.leftViewController else {
            return
        }
        
        animatedTransition.transitionDirection = .Left
        
        presentMenuViewController(leftViewController, animated: animated, completion: completion)
    }
    
    public func presentRightViewControllerAnimated(animated: Bool, completion: (() -> Void)?) {
        guard let rightViewController = self.rightViewController else {
            return
        }
        
        animatedTransition.transitionDirection = .Right
        
        presentMenuViewController(rightViewController, animated: animated, completion: completion)
    }
    
    private func presentMenuViewController(viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .OverFullScreen
        
        presentViewController(viewController, animated: animated, completion: completion)
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransition.presenting = true
        
        return animatedTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animatedTransition.presenting = false
        
        return animatedTransition
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactivelyTransitioning ? interactiveTransition : nil
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactivelyTransitioning ? interactiveTransition : nil
    }
    
    
    // MARK: - SlideMenuAnimatedTransitionDelegate
    
    func slideMenuAnimatedTransition(slideMenuAnimatedTransition: SlideMenuAnimatedTransition, handleTapGesture tapGestureRecognizer: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func slideMenuAnimatedTransition(slideMenuAnimatedTransition: SlideMenuAnimatedTransition, handlePanGesture panGestureRecognizer: UIPanGestureRecognizer) {
        let location = panGestureRecognizer.translationInView(panGestureRecognizer.view)
        let progress: CGFloat
        if leftViewControllerPresented {
            progress = max(0, min(-location.x / revealAmount, 1.0))
        } else {
            progress = max(0, min(location.x / revealAmount, 1.0))
        }
        
        switch panGestureRecognizer.state {
        case .Began:
            interactivelyTransitioning = true
            dismissViewControllerAnimated(true, completion: nil)
            
        case .Changed:
            interactiveTransition.updateInteractiveTransition(progress)
            
        case .Cancelled, .Ended, .Failed:
            interactiveTransition.completionSpeed = completionSpeedForProgress(progress)
        
            if progress > completionThreshold {
                interactiveTransition.finishInteractiveTransition()
            } else {
                interactiveTransition.cancelInteractiveTransition()
            }
            interactivelyTransitioning = false
            
        default:
            break
        }
    }
    
}
