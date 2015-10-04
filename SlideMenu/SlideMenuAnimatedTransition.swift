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
    public var transitionStyle: SlideMenuTransitionStyle = .Overlay
    
    public var prelayout: ((transition: SlideMenuAnimatedTransition, transitionContext: UIViewControllerContextTransitioning) -> Void)?
    public var animation: ((transition: SlideMenuAnimatedTransition, transitionContext: UIViewControllerContextTransitioning) -> Void)?
    public var completion: ((transition: SlideMenuAnimatedTransition, transitionContext: UIViewControllerContextTransitioning) -> Void)?
    
    public private(set) weak var presentedView: UIView?
    public private(set) weak var snapshotView: UIView?
    
    
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
        // When `modalPresentationStyle` is `UIModalPresentationFullScreen`, `fromView` is provided.
        // But when `modalPresentationStyle` is `UIModalPresentationOverFullScreen`,
        // `fromView` is not provided, though `fromViewController` is provided.
        // That's why the transition views are got via view controllers instead of using `viewForKey:`.
        guard let containerView = transitionContext.containerView(),
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        presentedView = toView
        
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
        
        if transitionStyle == .Shift {
            let snapshotView = fromView.snapshotViewAfterScreenUpdates(true)
            self.snapshotView = snapshotView
            
            snapshotView.frame = CGRectMake(
                0,
                0,
                CGRectGetWidth(containerView.frame),
                CGRectGetHeight(containerView.frame)
            )
            snapshotView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            containerView.insertSubview(snapshotView, aboveSubview: toView)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
            snapshotView.addGestureRecognizer(tapGestureRecognizer)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
            snapshotView.addGestureRecognizer(panGestureRecognizer)
        }
        
        prelayout?(transition: self, transitionContext: transitionContext)
        
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
                
                if self.transitionStyle == .Shift, let snapshotView = self.snapshotView {
                    if self.transitionDirection == .Left {
                        snapshotView.frame = CGRectMake(
                            self.revealAmount,
                            0,
                            CGRectGetWidth(containerView.frame),
                            CGRectGetHeight(containerView.frame)
                        )
                    } else {
                        snapshotView.frame = CGRectMake(
                            -self.revealAmount,
                            0,
                            CGRectGetWidth(containerView.frame),
                            CGRectGetHeight(containerView.frame)
                        )
                    }
                }
                
                self.animation?(transition: self, transitionContext: transitionContext)
            },
            completion: { (finished: Bool) in
                self.completion?(transition: self, transitionContext: transitionContext)
                
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
    
    private func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            let presentedView = self.presentedView else {
            return
        }
        
        // Prelayout
        prelayout?(transition: self, transitionContext: transitionContext)
        
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
                    presentedView.frame = CGRectMake(
                        -self.revealAmount,
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                } else {
                    presentedView.frame = CGRectMake(
                        CGRectGetWidth(containerView.frame),
                        0,
                        self.revealAmount,
                        CGRectGetHeight(containerView.frame)
                    )
                }
                
                if self.transitionStyle == .Shift, let snapshotView = self.snapshotView {
                    snapshotView.frame = CGRectMake(
                        0,
                        0,
                        CGRectGetWidth(containerView.frame),
                        CGRectGetHeight(containerView.frame)
                    )
                }
                
                self.animation?(transition: self, transitionContext: transitionContext)
            },
            completion: { (finished: Bool) in
                self.completion?(transition: self, transitionContext: transitionContext)
                
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
    
}
