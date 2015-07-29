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
    func topWindow() -> UIWindow? {
        var finalWindow: UIWindow? = nil
        for window in (UIApplication.sharedApplication().windows ).reverse() {
            if window.windowLevel == UIWindowLevelNormal && !window.hidden { finalWindow = window }
        }
        return finalWindow
    }
    
    private let contentView = UIView()
    public var animationDuration: NSTimeInterval = 0.4
    
    public var didTapBlock: (() -> ())?
    public var didDismissBlock: (() -> ())?
    public var dismissesOnTap = true
    public var dismissesOnSwipe = true
    
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var bannerState = BannerState.Hidden {
        didSet {
            if self.bannerState != oldValue {
                self.forceUpdates()
            }
        }
    }
    
    private func forceUpdates() {
        if let superview = self.superview, showingConstraint = self.showingConstraint, hiddenConstraint = self.hiddenConstraint {
            switch self.bannerState {
            case .Hidden:
                superview.removeConstraint(showingConstraint)
                superview.addConstraint(hiddenConstraint)
            case .Showing:
                superview.removeConstraint(hiddenConstraint)
                superview.addConstraint(showingConstraint)
            case .Gone:
                superview.removeConstraint(hiddenConstraint)
                superview.removeConstraint(showingConstraint)
                superview.removeConstraints(self.commonConstraints)
            }
            self.setNeedsLayout()
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
    
    internal func didTap(recognizer: UITapGestureRecognizer) {
        if self.dismissesOnTap {
            self.dismiss()
        }
        self.didTapBlock?()
    }
    
    internal func didSwipe(recognizer: UISwipeGestureRecognizer) {
        if self.dismissesOnSwipe {
            self.dismiss()
        }
    }
    
    public init(title: String, subtitle: String, image: UIImage? = nil, backgroundColor: UIColor = UIColor.blackColor(), textColor: UIColor = UIColor.whiteColor(), opacity: CGFloat = 0.95, didTapBlock: (() -> ())? = nil) {
        self.didTapBlock = didTapBlock
        super.init(frame: CGRectZero)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentView)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTap:"))
        let swipe = UISwipeGestureRecognizer(target: self, action: "didSwipe:")
        swipe.direction = .Up
        self.addGestureRecognizer(swipe)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 4
        self.backgroundColor = backgroundColor.colorWithAlphaComponent(opacity)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.text = title
        self.detailLabel.text = subtitle
        self.titleLabel.textColor = textColor
        self.detailLabel.textColor = textColor
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailLabel)
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        let heightOffset = min(statusBarSize.height, statusBarSize.width) - 7.0 // Arbitrary, but looks nice.
        for format in ["H:|[view]|", "V:|-(\(heightOffset))-[view]|"] {
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": self.contentView]))
        }
        let leftConstraintText: String
        var views = [String: UIView]()
        if let image = image {
            let imageView = UIImageView(image: image.imageWithRenderingMode(.AlwaysTemplate))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .ScaleAspectFit
            imageView.tintColor = textColor
            self.contentView.addSubview(imageView)
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(15)-[view]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": imageView]))
            self.contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 25.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1.0, constant: 0.0))
            leftConstraintText = "[imageView]"
            views["imageView"] = imageView
        } else {
            leftConstraintText = "|"
        }
        for view in [self.titleLabel, self.detailLabel] {
            views["label"] = view
            let constraintFormat = "H:\(leftConstraintText)-(15)-[label]-(8)-|"
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraintFormat, options: .DirectionLeadingToTrailing, metrics: nil, views: views))
        }
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(10)-[titleLabel][detailLabel]-(10)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["titleLabel": self.titleLabel, "detailLabel": self.detailLabel]))
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
        if let superview = self.superview where self.bannerState != .Gone {
            self.commonConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[banner]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["banner": self]) 
            superview.addConstraints(self.commonConstraints)
            self.showingConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: 0.0)
            self.hiddenConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: 0.0)
        }
    }
    
    public func show(duration: NSTimeInterval? = nil) {
        if let window = self.topWindow() {
            window.addSubview(self)
            self.forceUpdates()
            UIView.animateWithDuration(self.animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {
                self.bannerState = .Showing
            }, completion: { finished in
                if let duration = duration {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * NSTimeInterval(NSEC_PER_SEC))), dispatch_get_main_queue(), self.dismiss)
                }
            })
        } else {
            print("[Banner]: Could not find window. Aborting.")
        }
    }
    
    public func dismiss() {
        UIView.animateWithDuration(self.animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .AllowUserInteraction, animations: {
            self.bannerState = .Hidden
        }, completion: { finished in
            self.bannerState = .Gone
            self.removeFromSuperview()
            self.didDismissBlock?()
        })
    }
}