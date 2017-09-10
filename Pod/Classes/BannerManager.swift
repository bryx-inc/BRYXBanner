//
//  BannerManager.swift
//  BRYXBanner
//
//  Created by Kyle May on 10/9/17.
//

import UIKit

/// BannerManager keeps track of presented banners and their state
open class BannerManager: NSObject {
    
    /// Banner manager singleton
    public static let shared = BannerManager()
    
    private override init() {}
    
    /// An array of all the banners, regardless of state
    public internal(set) var banners: [Banner] = []
    
    /// An array of all the visible banners
    public var presentedBanners: [Banner] {
        return banners.filter { $0.bannerState == .showing }
    }
    
    /// Whether a banner is currently visible
    public var isShowingBanner: Bool {
        return presentedBanners.count != 0
    }
    
    /// Dismisses all active banners
    open func dismissAllBanners() {
        presentedBanners.forEach { $0.dismiss() }
    }
}
