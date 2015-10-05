//
//  SlideMenuBackgroundView.swift
//  SlideMenu
//
//  Created by Katsuma Tanaka on 2015/10/05.
//  Copyright © 2015 Katsuma Tanaka. All rights reserved.
//

import UIKit

public class SlideMenuBackgroundView: UIView {
    
    // MARK: - Properties
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    
    var onTapGesture: ((tapGestureRecognizer: UITapGestureRecognizer) -> Void)?
    var onPanGesture: ((panGestureRecognizer: UIPanGestureRecognizer) -> Void)?
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        
        // Register gesture recognizers
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        addGestureRecognizer(panGestureRecognizer)
    }
    
    
    // MARK: - Actions
    
    func handleTapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
        onTapGesture?(tapGestureRecognizer: tapGestureRecognizer)
    }
    
    func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        onPanGesture?(panGestureRecognizer: panGestureRecognizer)
    }
    
}
