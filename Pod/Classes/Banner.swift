//
//  Banner.swift
//
//  Created by Harlan Haskins on 7/27/15.
//  Copyright (c) 2015 Bryx. All rights reserved.
//

import Foundation

private enum BannerState {
    case Showing, Hidden, Gone
}

public class Banner: UIView {
    private class func topWindow() -> UIWindow? {
        var finalWindow: UIWindow? = nil
        for window in (UIApplication.sharedApplication().windows as! [UIWindow]).reverse() {
            if window.windowLevel == UIWindowLevelNormal && !window.hidden { finalWindow = window }
        }
        return finalWindow
    }
    
    private let contentView = UIView()
    private let backgroundView = UIView()
    public var animationDuration: NSTimeInterval = 0.4
    public var textColor = UIColor.whiteColor() {
        didSet {
            resetTintColor()
        }
    }
    public var hasShadows = true {
        didSet {
            resetShadows()
        }
    }
    
    override public var backgroundColor: UIColor? {
        get { return backgroundView.backgroundColor }
        set { backgroundView.backgroundColor = newValue }
    }
    
    override public var alpha: CGFloat {
        get { return backgroundView.alpha }
        set { backgroundView.alpha = newValue }
    }
    
    public var didTapBlock: (() -> ())?
    public var didDismissBlock: (() -> ())?
    public var dismissesOnTap = true
    public var dismissesOnSwipe = true
    public var shouldTintImage = true {
        didSet {
            resetTintColor()
        }
    }
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    public var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.numberOfLines = 2
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    let image: UIImage?
    
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    private var bannerState = BannerState.Hidden {
        didSet {
            if bannerState != oldValue {
                forceUpdates()
            }
        }
    }
    
    public init(title: String, subtitle: String, image: UIImage? = nil, backgroundColor: UIColor = UIColor.blackColor(), didTapBlock: (() -> ())? = nil) {
        self.didTapBlock = didTapBlock
        self.image = image
        super.init(frame: CGRectZero)
        resetShadows()
        addGestureRecognizers()
        initializeSubviews()
        resetTintColor()
        titleLabel.text = title
        detailLabel.text = subtitle
        backgroundView.backgroundColor = backgroundColor
        backgroundView.alpha = 0.95
    }
    
    private func forceUpdates() {
        if let superview = superview, showingConstraint = showingConstraint, hiddenConstraint = hiddenConstraint {
            switch bannerState {
            case .Hidden:
                superview.removeConstraint(showingConstraint)
                superview.addConstraint(hiddenConstraint)
            case .Showing:
                superview.removeConstraint(hiddenConstraint)
                superview.addConstraint(showingConstraint)
            case .Gone:
                superview.removeConstraint(hiddenConstraint)
                superview.removeConstraint(showingConstraint)
                superview.removeConstraints(commonConstraints)
            }
            setNeedsLayout()
            setNeedsUpdateConstraints()
            layoutIfNeeded()
            updateConstraintsIfNeeded()
        }
    }
    
    internal func didTap(recognizer: UITapGestureRecognizer) {
        if dismissesOnTap {
            dismiss()
        }
        didTapBlock?()
    }
    
    internal func didSwipe(recognizer: UISwipeGestureRecognizer) {
        if dismissesOnSwipe {
            dismiss()
        }
    }
    
    private func addGestureRecognizers() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTap:"))
        let swipe = UISwipeGestureRecognizer(target: self, action: "didSwipe:")
        swipe.direction = .Up
        addGestureRecognizer(swipe)
    }
    
    private func resetTintColor() {
        titleLabel.textColor = textColor
        detailLabel.textColor = textColor
        imageView.image = shouldTintImage ? image?.imageWithRenderingMode(.AlwaysTemplate) : image
        imageView.tintColor = shouldTintImage ? textColor : nil
    }
    
    private func resetShadows() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = self.hasShadows ? 0.5 : 0.0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 4
    }
    
    private func initializeSubviews() {
        setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(backgroundView)
        backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        for side in ["H", "V"] {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("\(side):|[view]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": backgroundView]))
        }
        backgroundView.backgroundColor = backgroundColor
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        backgroundView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        let heightOffset = min(statusBarSize.height, statusBarSize.width) - 7.0 // Arbitrary, but looks nice.
        for format in ["H:|[view]|", "V:|-(\(heightOffset))-[view]|"] {
            backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": contentView]))
        }
        let leftConstraintText: String
        var views = [String: UIView]()
        if let image = image {
            contentView.addSubview(imageView)
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(15)-[view]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": imageView]))
            contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 25.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1.0, constant: 0.0))
            leftConstraintText = "[imageView]"
            views["imageView"] = imageView
        } else {
            leftConstraintText = "|"
        }
        for view in [titleLabel, detailLabel] {
            views["label"] = view
            let constraintFormat = "H:\(leftConstraintText)-(15)-[label]-(8)-|"
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraintFormat, options: .DirectionLeadingToTrailing, metrics: nil, views: views))
        }
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(10)-[titleLabel][detailLabel]-(10)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel, "detailLabel": detailLabel]))
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var showingConstraint: NSLayoutConstraint?
    private var hiddenConstraint: NSLayoutConstraint?
    private var commonConstraints = [NSLayoutConstraint]()
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview where bannerState != .Gone {
            commonConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[banner]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["banner": self]) as! [NSLayoutConstraint]
            superview.addConstraints(commonConstraints)
            let yOffset: CGFloat = -5.0 // Offset the bottom constraint to make room for the shadow to animate off screen.
            showingConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: 0.0)
            hiddenConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: yOffset)
        }
    }
    
    public func show(duration: NSTimeInterval? = nil) {
        if let window = Banner.topWindow() {
            window.addSubview(self)
            forceUpdates()
            UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {
                self.bannerState = .Showing
            }, completion: { finished in
                if let duration = duration {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * NSTimeInterval(NSEC_PER_SEC))), dispatch_get_main_queue(), self.dismiss)
                }
            })
        } else {
            println("[Banner]: Could not find window. Aborting.")
        }
    }
    
    public func dismiss() {
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {
            self.bannerState = .Hidden
        }, completion: { finished in
            self.bannerState = .Gone
            self.removeFromSuperview()
            self.didDismissBlock?()
        })
    }
}