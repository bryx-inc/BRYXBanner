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
        for window in (UIApplication.sharedApplication().windows as! [UIWindow]).reverse() {
            if window.windowLevel == UIWindowLevelNormal && !window.hidden { return window }
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
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    /// The label that displays the banner's subtitle.
    public let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        label.numberOfLines = 0
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    /// The image on the left of the banner.
    let image: UIImage?
    
    /// The image view that displays the `image`.
    public let imageView: UIImageView = {
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
    
    /// A Banner with the provided `title`, `subtitle`, and optional `image`, ready to be presented with `show()`.
    ///
    /// :param: title The title of the banner. Optional. Defaults to nil.
    /// :param: subtitle The subtitle of the banner. Optional. Defaults to nil.
    /// :param: image The image on the left of the banner. Optional. Defaults to nil.
    /// :param: backgroundColor The color of the banner's background view. Defaults to `UIColor.blackColor()`.
    /// :param: didTapBlock An action to be called when the user taps on the banner. Optional. Defaults to `nil`.
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
        let views = [
            "backgroundView": backgroundView,
            "contentView": contentView,
            "imageView": imageView,
            "labelView": labelView,
            "titleLabel": titleLabel,
            "detailLabel": detailLabel
        ]
        setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(backgroundView)
        backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[backgroundView(>=80)]|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
        backgroundView.backgroundColor = backgroundColor
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        backgroundView.addSubview(contentView)
        labelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(labelView)
        labelView.addSubview(titleLabel)
        labelView.addSubview(detailLabel)
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        let heightOffset = min(statusBarSize.height, statusBarSize.width) // Arbitrary, but looks nice.
        for format in ["H:|[contentView]|", "V:|-(\(heightOffset))-[contentView]|"] {
            backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: .DirectionLeadingToTrailing, metrics: nil, views: views))
        }
        let leftConstraintText: String
        if let image = image {
            contentView.addSubview(imageView)
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(15)-[imageView]", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
            contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 25.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1.0, constant: 0.0))
            leftConstraintText = "[imageView]"
        } else {
            leftConstraintText = "|"
        }
      let constraintFormat = "H:\(leftConstraintText)-(15)-[labelView]-(8)-|"
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraintFormat, options: .DirectionLeadingToTrailing, metrics: nil, views: views))
      contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=1)-[labelView]-(>=1)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
      backgroundView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]-(<=1)-[labelView]", options: .AlignAllCenterY, metrics: nil, views: views))

      for view in [titleLabel, detailLabel] {
          let constraintFormat = "H:|-(15)-[label]-(8)-|"
          contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(constraintFormat, options: .DirectionLeadingToTrailing, metrics: nil, views: ["label": view]))
      }
      labelView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(10)-[titleLabel][detailLabel]-(10)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
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
            let yOffset: CGFloat = -7.0 // Offset the bottom constraint to make room for the shadow to animate off screen.
            showingConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1.0, constant: yOffset)
            hiddenConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1.0, constant: yOffset)
        }
    }    

    /// Shows the banner. If a view is specified, the banner will be displayed at the top of that view, otherwise at top of the top window. If a `duration` is specified, the banner dismisses itself automatically after that duration elapses.
    /// :param: view A view the banner will be shown in. Optional. Defaults to 'nil', which in turn means it will be shown in the top window. duration A time interval, after which the banner will dismiss itself. Optional. Defaults to `nil`.
    public func show(view: UIView? = Banner.topWindow(), duration: NSTimeInterval? = nil) {
        if let view = view {
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
                    if let duration = duration {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * NSTimeInterval(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                            self.dismiss(oldStatusBarStyle: self.adjustsStatusBarStyle ? oldStatusBarStyle : nil)
                        }
                    }
            })
        } else {
            println("[Banner]: Could not find window. Aborting.")
        }
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
