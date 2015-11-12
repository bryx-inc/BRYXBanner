//
//  MockBanner.swift
//  BRYXBanner
//
//  Created by Anthony Miller on 11/12/15.
//

import Foundation

private let MockBannerShownNotificationName = "MockBannerShownNotification"

class MockBanner: Banner {
  
  var viewForBanner: UIView?
  
  override func show(view: UIView? = MockBanner.topWindow(), duration: NSTimeInterval?) {
    viewForBanner = view
    NSNotificationCenter.defaultCenter().postNotificationName(MockBannerShownNotificationName, object: self)
  }
  
  private class func topWindow() -> UIWindow? {
    for window in (UIApplication.sharedApplication().windows).reverse() {
      if window.windowLevel == UIWindowLevelNormal && !window.hidden { return window }
    }
    return nil
  }
  
}

class MockBannerVerifier: NSObject {
  
  var bannerShown: MockBanner?
  
  override init() {
    super.init()
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "bannerShown:",
      name: MockBannerShownNotificationName,
      object: nil)
  }
  
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func bannerShown(notification: NSNotification) {
    if let banner = notification.object as? MockBanner {
      bannerShown = banner
    }
  }
  
}
  