//
//  ViewController.swift
//  BRYXBanner
//
//  Created by Harlan Haskins on 07/27/2015.
//  Copyright (c) 2015 Harlan Haskins. All rights reserved.
//

import UIKit
import BRYXBanner

class ViewController: UIViewController {
    
    @IBAction func showImageNotification(sender: UIButton) {
        let banner = Banner(title: "Image Notification", subtitle: "Here's a great image notification.", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
        banner.show(duration: 3.0)
    }

    @IBAction func showRegularNotification(sender: UIButton) {
        let banner = Banner(title: "Notification", subtitle: "Here's a great regular notification.", backgroundColor: UIColor(red:255.0/255.0, green:204.0/255.0, blue:51.0/255.0, alpha:1.000)) {
            let c = UIAlertController(title: "Woo!", message: "You tapped the banner!", preferredStyle: .Alert)
            c.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(c, animated: true, completion: nil)
        }
        banner.show(duration: 3.0)
    }
    
}

