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
    public let menuBackgroundView = UIView()
    
    weak var delegate: SlideMenuAnimatedTransitionDelegate?
    
    var transitionDirection: TransitionDirection = .Left
    
    public internal(set) var presenting: Bool = true
    
    public var revealAmount: CGFloat = 300
    public var animationDuration: NSTimeInterval = 0.4
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        // Configure menu container view
        menuContainerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePanGesture:"))
        
        // Configure menu background view
        menuBackgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        menuBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTapGesture:"))
        menuBackgroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePanGesture:"))
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
        
        // Animation
        let animations = {
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
        }
        
        let completion = { (finished: Bool) in
            let cancelled = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!cancelled)
        }
        
        if transitionContext.isInteractive() {
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                options: [.CurveLinear],
                animations: animations,
                completion: completion
            )
        } else {
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [],
                animations: animations,
                completion: completion
            )
        }
    }
    
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        // Animation
        let animations = {
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
        }
        
        let completion = { (finished: Bool) in
            let cancelled = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!cancelled)
        }
        
        if transitionContext.isInteractive() {
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                options: [.CurveLinear],
                animations: animations,
                completion: completion
            )
        } else {
            UIView.animateWithDuration(
                animationDuration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [],
                animations: animations,
                completion: completion
            )
        }
    }
    
}
