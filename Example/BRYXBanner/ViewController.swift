//
//  ViewController.swift
//  BRYXBanner
//
//  Created by Harlan Haskins on 07/27/2015.
//  Copyright (c) 2015 Harlan Haskins. All rights reserved.
//

import UIKit
import BRYXBanner

struct BannerColors {
    static let red = UIColor(red:198.0/255.0, green:26.00/255.0, blue:27.0/255.0, alpha:1.000)
    static let green = UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000)
    static let yellow = UIColor(red:255.0/255.0, green:204.0/255.0, blue:51.0/255.0, alpha:1.000)
    static let blue = UIColor(red:31.0/255.0, green:136.0/255.0, blue:255.0/255.0, alpha:1.000)
}

class ViewController: UIViewController {
    @IBOutlet weak var imageSwitch: UISwitch!
    @IBOutlet weak var positionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var springinessSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var subtitleField: UITextField!
    @IBOutlet weak var colorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var inViewSwitch: UISwitch!
    @IBOutlet weak var blurSegmentControl: UISegmentedControl!
    
    @IBAction func showButtonTapped(_ sender: UIButton) {
        let color = currentColor()
        let image = imageSwitch.isOn ? #imageLiteral(resourceName: "Icon") : nil
        let title = titleField.text?.validated
        let subtitle = subtitleField.text?.validated
        let banner = Banner(title: title, subtitle: subtitle, image: image, backgroundColor: color)
        banner.blurStyle = currentBlurStyle()

        banner.springiness = currentSpringiness()
        banner.position = currentPosition()
        banner.didTapBlock = {
            print("Banner was tapped on \(Date())!")
        }
        if inViewSwitch.isOn {
            banner.show(view, duration: 3.0)
        } else {
            banner.show(duration: 3.0)
        }
    }
    
    func currentPosition() -> BannerPosition {
        switch positionSegmentedControl.selectedSegmentIndex {
        case 0: return .top
        default: return .bottom
        }
    }
    
    func currentSpringiness() -> BannerSpringiness {
        switch springinessSegmentedControl.selectedSegmentIndex {
        case 0: return .none
        case 1: return .slight
        default: return .heavy
        }
    }
    
    func currentColor() -> UIColor {
        switch colorSegmentedControl.selectedSegmentIndex {
        case 0: return BannerColors.red
        case 1: return BannerColors.green
        case 2: return BannerColors.yellow
        default: return BannerColors.blue
        }
    }

    func currentBlurStyle() -> UIBlurEffectStyle? {
        switch blurSegmentControl.selectedSegmentIndex {
        case 1: return .light
        case 2: return .extraLight
        case 3: return .dark
        default: return nil
        }
    }
    
}

extension String {
    var validated: String? {
        if self.isEmpty { return nil }
        return self
    }
}

