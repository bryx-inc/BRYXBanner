# BRYXBanner

[![Version](https://img.shields.io/cocoapods/v/BRYXBanner.svg?style=flat)](http://cocoapods.org/pods/BRYXBanner)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/BRYXBanner.svg?style=flat)](http://cocoapods.org/pods/BRYXBanner)
[![Platform](https://img.shields.io/cocoapods/p/BRYXBanner.svg?style=flat)](http://cocoapods.org/pods/BRYXBanner)

A lightweight dropdown banner for iOS 7+.

![Example](https://raw.githubusercontent.com/bryx-inc/BRYXBanner/master/Example/Demo.gif)

## Usage

Import `BRYXBanner`

```rust
import BRYXBanner
```

Create a banner using the designated initializer.

```rust
let banner = Banner(title: "Image Notification", subtitle: "Here's a great image notification.", image: UIImage(named: "Icon"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
banner.dismissesOnTap = true
banner.show(duration: 3.0)
```

If you want the banner to persist until you call `.dismiss()`, leave the argument out of the call to `.show()`

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Demo project requires iOS 8, though BRYXBanner works on iOS 7+.

## Installation

BRYXBanner is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage). 

#### Using CocoaPods

To install it, simply add the following line to your Podfile:

```ruby
pod 'BRYXBanner'
```

If you need to support iOS 7, just copy `Banner.swift` into your Xcode project.

#### Using Carthage

Create a Cartfile in your project directory and add the following line.

```ruby
github "bryx-inc/BRYXBanner"
```
Run `carthage update` from the command line. This will build the framework. The framework will be within `Carthage/build/example.framework`.

Add the framework to your project by going to your app's targets and selecting the General tab. Drag the built framework onto `Linked Frameworks and Libraries`

Go to the Build Phases tab, click the `+` sign and add a new run script phase. Then add the following:

```
/usr/local/bin/carthage copy-frameworks
```
to the box under Shell. Finally click `+` to add a new input file. Replace the default with:

```
$(SRCROOT)/Carthage/Build/iOS/BRYXBanner.framework
```

Now build and run. You're all set! More information on Carthage is available [here](https://github.com/Carthage/Carthage).


## Documentation

Docs are automatically generated and available [right here](http://cocoadocs.org/docsets/BRYXBanner/).

## Maintainer

Adam Binsz ([@adambinsz](https://github.com/adambinsz))

## Author

Harlan Haskins ([@harlanhaskins](https://github.com/harlanhaskins))

## License

BRYXBanner is available under the MIT license. See the LICENSE file for more info.
