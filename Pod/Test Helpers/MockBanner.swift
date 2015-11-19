//
//  MockBanner.swift
//  BRYXBanner
//
//  Created by Anthony Miller on 11/12/15.
//

import Foundation

private let MockBannerShownNotificationName = "MockBannerShownNotification"

/// This mock banner can be used in place of a `Banner` in unit tests in order to verify that it will be displayed.
public class MockBanner: Banner {
  
  /// The view that the banner is shown in. Captured from the `view` parameter in the `show(view: duration:)` method
  var viewForBanner: UIView?
  
  override public func show(view: UIView? = MockBanner.topWindow(), duration: NSTimeInterval? = nil) {
    viewForBanner = view
    NSNotificationCenter.defaultCenter().postNotificationName(MockBannerShownNotificationName, object: self)
  }
  
}

/// `MockBannerVerifier` can be used to verify that a `MockBanner` was shown in unit tests. This object will recieve notifications when a `MockBanner` is shown and capture the shown banner.
public class MockBannerVerifier: NSObject {
  
  /// The last banner that was shown
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
  