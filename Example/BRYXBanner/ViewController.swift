//
//  ViewController.swift
//  BRYXBanner
//
//  Created by Harlan Haskins on 07/27/2015.
//  Copyright (c) 2015 Harlan Haskins. All rights reserved.
//

import UIKit
import BRYXBanner

enum BannerColors {
    case Red, Green, Yellow
    
    var color: UIColor {
        switch self {
        case .Red: return UIColor(red:198.0/255.0, green:26.00/255.0, blue:27.0/255.0, alpha:1.000)
        case .Green: return UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000)
        case .Yellow: return UIColor(red:255.0/255.0, green:204.0/255.0, blue:51.0/255.0, alpha:1.000)
        }
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BRYXBanner"
        self.view.backgroundColor = UIColor.whiteColor()
        let textButton = BorderedButton(title: "Send Text Notification", tintColor: BannerColors.Red.color, backgroundColor: UIColor.whiteColor())
        textButton.addTarget(self, action: "showRegularNotification:", forControlEvents: .TouchUpInside)
        let imageButton = BorderedButton(title: "Send Image Notification", tintColor: BannerColors.Red.color, backgroundColor: UIColor.whiteColor())
        imageButton.addTarget(self, action: "showImageNotification:", forControlEvents: .TouchUpInside)
        for button in [textButton, imageButton] {
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(button)
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 44.0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(75)-[button]-(75)-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["button": button]))
        }
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-(15.0)-[text]-(5)-[image]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["topLayoutGuide": topLayoutGuide, "text": textButton, "image": imageButton]))
    }
    
    @IBAction func showImageNotification(sender: UIButton) {
        let banner = Banner(title: "Image Notification", subtitle: "Here's a great image notification.", image: UIImage(named: "Icon"), backgroundColor: BannerColors.Green.color)
        banner.springiness = .Heavy
        banner.show(duration: 3.0)
    }

    @IBAction func showRegularNotification(sender: UIButton) {
        let banner = Banner(title: "Notification", subtitle: "Here's a great regular notification.", backgroundColor: BannerColors.Yellow.color) {
            let c = UIAlertController(title: "Woo!", message: "You tapped the banner!", preferredStyle: .Alert)
            c.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(c, animated: true, completion: nil)
        }
        banner.show(duration: 3.0)
    }
    
}

