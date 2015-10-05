//
//  SlideMenuAnimatedTransition.swift
//  SlideMenu
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

protocol SlideMenuAnimatedTransitionDelegate: NSObjectProtocol {
    
    func slideMenuAnimatedTransition(slideMenuAnimatedTransition: SlideMenuAnimatedTransition, handleTapGesture tapGestureRecognizer: UITapGestureRecognizer)
    func slideMenuAnimatedTransition(slideMenuAnimatedTransition: SlideMenuAnimatedTransition, handlePanGesture panGestureRecognizer: UIPanGestureRecognizer)
    
}

public class SlideMenuAnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    enum TransitionDirection {
        case Left
        case Right
    }
    
    public let menuContainerView = UIView()
    public let menuBackgroundView = SlideMenuBackgroundView()
    
    weak var delegate: SlideMenuAnimatedTransitionDelegate?
    
    var transitionDirection: TransitionDirection = .Left
    
    public internal(set) var presenting: Bool = true
    
    public var animationDuration: NSTimeInterval = 0.35
    public var revealAmount: CGFloat = 300
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        menuBackgroundView.onTapGesture = { (tapGestureRecognizer: UITapGestureRecognizer) in
            self.handleTapGesture(tapGestureRecognizer)
        }
        menuBackgroundView.onPanGesture = { (panGestureRecognizer: UIPanGestureRecognizer) in
            self.handlePanGesture(panGestureRecognizer)
        }
    }
    
    
    // MARK: - Actions
    
    func handleTapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.slideMenuAnimatedTransition(self, handleTapGesture: tapGestureRecognizer)
    }
    
    func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        delegate?.slideMenuAnimatedTransition(self, handlePanGesture: panGestureRecognizer)
    }
    
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(transitionContext)
        } else {
            animateDismissal(transitionContext)
        }
    }
    
    private func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey) else {
                return
        }
        
        // Prelayout menu background view
        menuBackgroundView.frame = containerView.bounds
        menuBackgroundView.alpha = 0
        menuBackgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        containerView.addSubview(menuBackgroundView)
        
        // Prelayout menu container view
        if transitionDirection == .Left {
            menuContainerView.frame = CGRectMake(
                -self.revealAmount,
                0,
                self.revealAmount,
                CGRectGetHeight(containerView.frame)
            )
            menuContainerView.autoresizingMask = [.FlexibleRightMargin, .FlexibleHeight]
        } else {
            menuContainerView.frame = CGRectMake(
                CGRectGetWidth(containerView.frame),
                0,
                self.revealAmount,
                CGRectGetHeight(containerView.frame)
            )
            menuContainerView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleHeight]
        }
        
        containerView.insertSubview(menuContainerView, aboveSubview: menuBackgroundView)
        
        // Embed toView in menuContainerView
        toView.removeFromSuperview()
        toView.frame = menuContainerView.bounds
        toView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        menuContainerView.addSubview(toView)
        
        // Add pan gesture recognizer to menu container view
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        menuContainerView.addGestureRecognizer(panGestureRecognizer)
        
        // Animation
        let options: UIViewAnimationOptions
        if transitionContext.isInteractive() {
            options = [.CurveLinear]
        } else {
            options = [.CurveEaseInOut]
        }
        
        UIView.transitionWithView(
            containerView,
            duration: transitionDuration(transitionContext),
            options: options,
            animations: {
                self.menuBackgroundView.alpha = 1
                
                if self.transitionDirection == .Left {
                    self.menuContainerView.frame = CGRectMake(
                        0,
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                } else {
                    self.menuContainerView.frame = CGRectMake(
                        CGRectGetWidth(containerView.frame) - self.revealAmount,
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                }
            },
            completion: { (finished: Bool) in
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
    
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        // Animation
        let options: UIViewAnimationOptions
        if transitionContext.isInteractive() {
            options = [.CurveLinear]
        } else {
            options = [.CurveEaseInOut]
        }
        
        UIView.transitionWithView(
            containerView,
            duration: transitionDuration(transitionContext),
            options: options,
            animations: {
                self.menuBackgroundView.alpha = 0
                
                if self.transitionDirection == .Left {
                    self.menuContainerView.frame = CGRectMake(
                        -self.revealAmount,
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                } else {
                    self.menuContainerView.frame = CGRectMake(
                        CGRectGetWidth(containerView.frame),
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                }
            },
            completion: { (finished: Bool) in
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
    
}
