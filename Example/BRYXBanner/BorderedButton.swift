//
//  BorderedButton.swift
//
//
//  Created by Adam Binsz on 7/26/15.
//
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    
    @IBInspectable var borderRadius: CGFloat = 13 {
        didSet {
            self.layer.cornerRadius = borderRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    private var selectionBackgroundColor: UIColor? {
        didSet {
            self.setTitleColor(selectionBackgroundColor, for: .highlighted)
        }
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            self.selectionBackgroundColor = newValue
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            self.setTitleColor(tintColor, for: UIControlState())
            self.layer.borderColor = tintColor?.cgColor
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        loadView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    convenience init(title: String, tintColor: UIColor? = UIColor.lightGray, backgroundColor: UIColor? = UIColor.white) {
        self.init(frame: CGRect.zero)
        self.setTitle(title, for: UIControlState())
        
        ({ self.tintColor = tintColor }())
        ({ self.backgroundColor = backgroundColor }())
    }
    
    private func loadView() {
        
        super.backgroundColor = UIColor.clear
        
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        
        self.borderWidth = 1.0
        self.layer.cornerRadius = borderRadius
        if let tint = self.tintColor {
            self.layer.borderColor = tint.cgColor
        }
        
        self.layer.masksToBounds = false
        self.clipsToBounds = false
    }
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue == self.isHighlighted { return }
            let background = self.backgroundColor
            let tint = self.tintColor
            super.backgroundColor = tint
            self.tintColor = background
        }
    }
}
