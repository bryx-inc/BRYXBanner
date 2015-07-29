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

/// A level of 'springiness' for Banners.
///
/// - None: The banner will slide in and not bounce.
/// - Slight: The banner will bounce a little.
/// - Heavy: The banner will bounce a lot.
public enum BannerSpringiness {
    case None, Slight, Heavy
    private var springValues: (damping: CGFloat, velocity: CGFloat) {
        switch self {
        case .None: return (damping: 1.0, velocity: 1.0)
        case .Slight: return (damping: 0.7, velocity: 1.5)
        case .Heavy: return (damping: 0.6, velocity: 2.0)
        }
    }
}

/// Banner is a dropdown notification view that presents above the main view controller, but below the status bar.
public class Banner: UIView {
    private class func topWindow() -> UIWindow? {
        for window in UIApplication.sharedApplication().windows.reverse() where window.windowLevel == UIWindowLevelNormal && !window.hidden {
            return window
        }
        return nil
    }
    
    private let contentView = UIView()
    private let backgroundView = UIView()
    
    /// How long the slide down animation should last.
    public var animationDuration: NSTimeInterval = 0.4
    
    public var springiness = BannerSpringiness.Slight
    
    /// The color of the text as well as the image tint color if `shouldTintImage` is `true`.
    public var textColor = UIColor.whiteColor() {
        didSet {
            resetTintColor()
        }
    }
    
    /// Whether or not the banner should show a shadow when presented.
    public var hasShadows = true {
        didSet {
            resetShadows()
        }
    }
    
    /// The color of the background view. Defaults to `nil`.
    override public var backgroundColor: UIColor? {
        get { return backgroundView.backgroundColor }
        set { backgroundView.backgroundColor = newValue }
    }
    
    /// The opacity of the background view. Defaults to 0.95.
    override public var alpha: CGFloat {
        get { return backgroundView.alpha }
        set { backgroundView.alpha = newValue }
    }
    
    /// A block to call when the uer taps on the banner.
    public var didTapBlock: (() -> ())?
    
    /// A block to call after the banner has finished dismissing and is off screen.
    public var didDismissBlock: (() -> ())?
    
    /// Whether or not the banner should dismiss itself when the user taps. Defaults to `true`.
    public var dismissesOnTap = true
    
    /// Whether or not the banner should dismiss itself when the user swipes up. Defaults to `true`.
    public var dismissesOnSwipe = true
    
    /// Whether or not the banner should tint the associated image to the provided `textColor`. Defaults to `true`.
    public var shouldTintImage = true {
        didSet {
            resetTintColor()
        }
    }
    
    /// The label that displays the banner's title.
    public var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// The label that displays the banner's subtitle.
    public var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// The image on the left of the banner.
    let image: UIImage?
    
    /// The image view that displays the `image`.
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
    
    /// A Banner with the provided `title`, `subtitle`, and optional `image`, ready to be presented with `show()`.
    ///
    /// - parameter title: The title of the banner.
    /// - parameter subtitle: The subtitle of the banner.
    /// - parameter image: The image on the left of the banner. Optional. Defaults to nil.
    /// - parameter backgroundColor: The color of the banner's background view. Defaults to `UIColor.blackColor()`.
    /// - parameter didTapBlock: An action to be called when the user taps on the banner. Optional. Defaults to `nil`.
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
        guard let superview = superview, showingConstraint = showingConstraint, hiddenConstraint = hiddenConstraint else { return }
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
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        for side in ["H", "V"] {
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("\(side):|[view]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": backgroundView]))
        }
        backgroundView.backgroundColor = backgroundColor
        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        let heightOffset = min(statusBarSize.height, statusBarSize.width) // Arbitrary, but looks nice.
        for format in ["H:|[view]|", "V:|-(\(heightOffset))-[view]|"] {
            backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": contentView]))
        }
        let leftConstraintText: String
        var views = [String: UIView]()
        if image == nil {
            leftConstraintText = "|"
        } else {
            contentView.addSubview(imageView)
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(15)-[view]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["view": imageView]))
            contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 25.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1.0, constant: 0.0))
            leftConstraintText = "[imageView]"
            views["imageView"] = imageView
        }
        for view in [titleLabel, detailLabel] {
            views["label"] = view
            let constraintFormat = "H:\(leftConstraintText)-(15)-[label]-(8)-|"
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraintFormat, options: .DirectionLeadingToTrailing, metrics: nil, views: views))
        }
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(10)-[titleLabel][detailLabel]-(10)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel, "detailLabel": detailLabel]))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var showingConstraint: NSLayoutConstraint?
    private var hiddenConstraint: NSLayoutConstraint?
    private var commonConstraints = [NSLayoutConstraint]()
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview where bannerState != .Gone else { return }
        commonConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[banner]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["banner": self])
        superview.addConstraints(commonConstraints)
        let yOffset: CGFloat = -7.0 // Offset the bottom constraint to make room for the shadow to animate off screen.
        showingConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: yOffset)
        hiddenConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: yOffset)
    }
    
    /// Shows the banner. If a `duration` is specified, the banner dismisses itself automatically after that duration elapses.
    /// - parameter duration: A time interval, after which the banner will dismiss itself. Optional. Defaults to `nil`.
    public func show(duration duration: NSTimeInterval? = nil) {
        guard let window = Banner.topWindow() else {
            print("[Banner]: Could not find window. Aborting.")
            return
        }
        
        window.addSubview(self)
        forceUpdates()
        let (damping, velocity) = self.springiness.springValues
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .AllowUserInteraction, animations: {
            self.bannerState = .Showing
            }, completion: { finished in
                if let duration = duration {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * NSTimeInterval(NSEC_PER_SEC))), dispatch_get_main_queue(), self.dismiss)
                }
        })
    }
    
    /// Dismisses the banner.
    public func dismiss() {
        let (damping, velocity) = self.springiness.springValues
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .AllowUserInteraction, animations: {
            self.bannerState = .Hidden
            }, completion: { finished in
                self.bannerState = .Gone
                self.removeFromSuperview()
                self.didDismissBlock?()
        })
    }
}