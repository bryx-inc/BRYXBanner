//
//  Banner.swift
//
//  Created by Harlan Haskins on 7/27/15.
//  Copyright (c) 2015 Bryx. All rights reserved.
//

import UIKit

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
        for window in UIApplication.sharedApplication().windows.reverse() {
            if window.windowLevel == UIWindowLevelNormal && !window.hidden && window.frame != CGRectZero { return window }
        }
        return nil
    }
    
    private let contentView = UIView()
    private let labelView = UIView()
    private let backgroundView = UIView()
    
    /// How long the slide down animation should last.
    public var animationDuration: NSTimeInterval = 0.4
    
    /// The preferred style of the status bar during display of the banner. Defaults to `.LightContent`.
    ///
    /// If the banner's `adjustsStatusBarStyle` is false, this property does nothing.
    public var preferredStatusBarStyle = UIStatusBarStyle.LightContent
    
    /// Whether or not this banner should adjust the status bar style during its presentation. Defaults to `false`.
    public var adjustsStatusBarStyle = false
    
    /// How 'springy' the banner should display. Defaults to `.Slight`
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
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        }()
    
    /// The label that displays the banner's subtitle.
    public let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        }()
    
    /// The image on the left of the banner.
    let image: UIImage?
    
    /// The image view that displays the `image`.
    public let imageView: UIImageView = {
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
    /// - parameter title: The title of the banner. Optional. Defaults to nil.
    /// - parameter subtitle: The subtitle of the banner. Optional. Defaults to nil.
    /// - parameter image: The image on the left of the banner. Optional. Defaults to nil.
    /// - parameter backgroundColor: The color of the banner's background view. Defaults to `UIColor.blackColor()`.
    /// - parameter didTapBlock: An action to be called when the user taps on the banner. Optional. Defaults to `nil`.
    public required init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, backgroundColor: UIColor = UIColor.blackColor(), didTapBlock: (() -> ())? = nil) {
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
        let views = [
            "backgroundView": backgroundView,
            "contentView": contentView,
            "imageView": imageView,
            "labelView": labelView,
            "titleLabel": titleLabel,
            "detailLabel": detailLabel
        ]
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        addConstraint(backgroundView.constraintWithAttribute(.Height, .GreaterThanOrEqual, to: 80))
        addConstraints(backgroundView.constraintsEqualToSuperview())
        backgroundView.backgroundColor = backgroundColor
        backgroundView.addSubview(contentView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelView)
        labelView.addSubview(titleLabel)
        labelView.addSubview(detailLabel)
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        let heightOffset = min(statusBarSize.height, statusBarSize.width) // Arbitrary, but looks nice.
        for format in ["H:|[contentView]|", "V:|-(\(heightOffset))-[contentView]|"] {
            backgroundView.addConstraints(NSLayoutConstraint.defaultConstraintsWithVisualFormat(format, views: views))
        }
        let leftConstraintText: String
        if image == nil {
            leftConstraintText = "|"
        } else {
            contentView.addSubview(imageView)
            contentView.addConstraint(imageView.constraintWithAttribute(.Leading, .Equal, to: contentView, constant: 15.0))
            contentView.addConstraint(imageView.constraintWithAttribute(.CenterY, .Equal, to: contentView))
            imageView.addConstraint(imageView.constraintWithAttribute(.Width, .Equal, to: 25.0))
            imageView.addConstraint(imageView.constraintWithAttribute(.Height, .Equal, to: .Width))
            leftConstraintText = "[imageView]"
        }
        let constraintFormat = "H:\(leftConstraintText)-(15)-[labelView]-(8)-|"
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.defaultConstraintsWithVisualFormat(constraintFormat, views: views))
        contentView.addConstraints(NSLayoutConstraint.defaultConstraintsWithVisualFormat("V:|-(>=1)-[labelView]-(>=1)-|", views: views))
        backgroundView.addConstraints(NSLayoutConstraint.defaultConstraintsWithVisualFormat("H:|[contentView]-(<=1)-[labelView]", options: .AlignAllCenterY, views: views))
        
        for view in [titleLabel, detailLabel] {
            let constraintFormat = "H:|[label]-(8)-|"
            contentView.addConstraints(NSLayoutConstraint.defaultConstraintsWithVisualFormat(constraintFormat, options: .DirectionLeadingToTrailing, metrics: nil, views: ["label": view]))
        }
        labelView.addConstraints(NSLayoutConstraint.defaultConstraintsWithVisualFormat("V:|-(10)-[titleLabel][detailLabel]-(10)-|", views: views))
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
        commonConstraints = self.constraintsWithAttributes([.Leading, .Trailing], .Equal, to: superview)
        superview.addConstraints(commonConstraints)
        let yOffset: CGFloat = -7.0 // Offset the bottom constraint to make room for the shadow to animate off screen.
        showingConstraint = self.constraintWithAttribute(.Top, .Equal, to: .Top, of: superview, constant: yOffset)
        hiddenConstraint = self.constraintWithAttribute(.Bottom, .Equal, to: .Top, of: superview, constant: yOffset)
    }
    
    /// Shows the banner. If a view is specified, the banner will be displayed at the top of that view, otherwise at top of the top window. If a `duration` is specified, the banner dismisses itself automatically after that duration elapses.
    /// - parameter view: A view the banner will be shown in. Optional. Defaults to 'nil', which in turn means it will be shown in the top window. duration A time interval, after which the banner will dismiss itself. Optional. Defaults to `nil`.
    public func show(view: UIView? = Banner.topWindow(), duration: NSTimeInterval? = nil) {
        guard let view = view else {
            print("[Banner]: Could not find view. Aborting.")
            return
        }
        view.addSubview(self)
        forceUpdates()
        let (damping, velocity) = self.springiness.springValues
        let oldStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        if adjustsStatusBarStyle {
            UIApplication.sharedApplication().setStatusBarStyle(preferredStatusBarStyle, animated: true)
        }
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .AllowUserInteraction, animations: {
            self.bannerState = .Showing
            }, completion: { finished in
                guard let duration = duration else { return }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * NSTimeInterval(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.dismiss(self.adjustsStatusBarStyle ? oldStatusBarStyle : nil)
                }
        })
    }
    
    /// Dismisses the banner.
    public func dismiss(oldStatusBarStyle: UIStatusBarStyle? = nil) {
        let (damping, velocity) = self.springiness.springValues
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .AllowUserInteraction, animations: {
            self.bannerState = .Hidden
            if let oldStatusBarStyle = oldStatusBarStyle {
                UIApplication.sharedApplication().setStatusBarStyle(oldStatusBarStyle, animated: true)
            }
            }, completion: { finished in
                self.bannerState = .Gone
                self.removeFromSuperview()
                self.didDismissBlock?()
        })
    }
}

extension NSLayoutConstraint {
    class func defaultConstraintsWithVisualFormat(format: String, options: NSLayoutFormatOptions = .DirectionLeadingToTrailing, metrics: [String: AnyObject]? = nil, views: [String: AnyObject] = [:]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: views)
    }
}

extension UIView {
    func constraintsEqualToSuperview(edgeInsets: UIEdgeInsets = UIEdgeInsetsZero) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if let superview = self.superview {
            constraints.append(self.constraintWithAttribute(.Leading, .Equal, to: superview, constant: edgeInsets.left))
            constraints.append(self.constraintWithAttribute(.Trailing, .Equal, to: superview, constant: edgeInsets.right))
            constraints.append(self.constraintWithAttribute(.Top, .Equal, to: superview, constant: edgeInsets.top))
            constraints.append(self.constraintWithAttribute(.Bottom, .Equal, to: superview, constant: edgeInsets.bottom))
        }
        return constraints
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to constant: CGFloat, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: multiplier, constant: constant)
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to otherAttribute: NSLayoutAttribute, of item: AnyObject? = nil, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item ?? self, attribute: otherAttribute, multiplier: multiplier, constant: constant)
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, _ relation: NSLayoutRelation, to item: AnyObject, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: item, attribute: attribute, multiplier: multiplier, constant: constant)
    }
    
    func constraintsWithAttributes(attributes: [NSLayoutAttribute], _ relation: NSLayoutRelation, to item: AnyObject, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return attributes.map { self.constraintWithAttribute($0, relation, to: item, multiplier: multiplier, constant: constant) }
    }
}