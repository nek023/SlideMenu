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
    
    public let backgroundView: SlideMenuBackgroundView
    
    weak var delegate: SlideMenuAnimatedTransitionDelegate?
    
    var transitionDirection: TransitionDirection = .Left
    
    public internal(set) var presenting: Bool = true
    
    public var animationDuration: NSTimeInterval = 0.35
    public var revealAmount: CGFloat = 300
    
    
    // MARK: - Initializers
    
    override init() {
        backgroundView = SlideMenuBackgroundView()
        
        super.init()
        
        backgroundView.onTapGesture = { (tapGestureRecognizer: UITapGestureRecognizer) in
            self.handleTapGesture(tapGestureRecognizer)
        }
        backgroundView.onPanGesture = { (panGestureRecognizer: UIPanGestureRecognizer) in
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
        
        // Prelayout
        let backgroundView = self.backgroundView
        backgroundView.frame = containerView.bounds
        backgroundView.alpha = 0
        backgroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        containerView.addSubview(backgroundView)
        
        if transitionDirection == .Left {
            toView.frame = CGRectMake(
                -self.revealAmount,
                0,
                self.revealAmount,
                CGRectGetHeight(containerView.frame)
            )
            toView.autoresizingMask = [.FlexibleRightMargin, .FlexibleHeight]
        } else {
            toView.frame = CGRectMake(
                CGRectGetWidth(containerView.frame),
                0,
                self.revealAmount,
                CGRectGetHeight(containerView.frame)
            )
            toView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleHeight]
        }
        containerView.insertSubview(toView, aboveSubview: backgroundView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        toView.addGestureRecognizer(panGestureRecognizer)
        
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
                backgroundView.alpha = 1
                
                if self.transitionDirection == .Left {
                    toView.frame = CGRectMake(
                        0,
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                } else {
                    toView.frame = CGRectMake(
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
        guard let containerView = transitionContext.containerView(),
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) else {
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
                self.backgroundView.alpha = 0
                
                if self.transitionDirection == .Left {
                    fromView.frame = CGRectMake(
                        -self.revealAmount,
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                } else {
                    fromView.frame = CGRectMake(
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
