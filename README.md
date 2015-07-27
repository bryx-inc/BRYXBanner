# BRYXBanner

[![Version](https://img.shields.io/cocoapods/v/BRYXBanner.svg?style=flat)](http://cocoapods.org/pods/BRYXBanner)
[![License](https://img.shields.io/cocoapods/l/BRYXBanner.svg?style=flat)](http://cocoapods.org/pods/BRYXBanner)
[![Platform](https://img.shields.io/cocoapods/p/BRYXBanner.svg?style=flat)](http://cocoapods.org/pods/BRYXBanner)

## Usage

Create a banner using the designated initializer.

```rust
let banner = Banner(title: "Image Notification", subtitle: "Here's a great image notification.", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
banner.dismissesOnTap = true
banner.show(duration: 3.0)
```

If you want the banner to persist until you can `.dismiss()`, leave the argument out of the call to `.show()`

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Demo project requires iOS 8, though BRYXBanner works on iOS 7+.

## Installation

BRYXBanner is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BRYXBanner"
```

If you need to support iOS 7, just copy `Banner.swift` into your Xcode project.

## Author

Harlan Haskins, harlan@harlanhaskins.com

## License

BRYXBanner is available under the MIT license. See the LICENSE file for more info.
