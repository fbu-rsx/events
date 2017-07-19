# EVContactsPicker

[![CI Status](http://img.shields.io/travis/edwardvalentini/EVContactsPicker.svg?style=flat)](https://travis-ci.org/edwardvalentini/EVContactsPicker)
[![codecov](https://codecov.io/gh/edwardvalentini/EVContactsPicker/branch/master/graph/badge.svg)](https://codecov.io/gh/edwardvalentini/EVContactsPicker)
[![Code Climate](https://codeclimate.com/github/edwardvalentini/EVContactsPicker/badges/gpa.svg)](https://codeclimate.com/github/edwardvalentini/EVContactsPicker)
[![Version](https://img.shields.io/cocoapods/v/EVContactsPicker.svg?style=flat)](http://cocoapods.org/pods/EVContactsPicker)
[![License](https://img.shields.io/cocoapods/l/EVContactsPicker.svg?style=flat)](http://cocoapods.org/pods/EVContactsPicker)
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat)](http://cocoapods.org/pods/EVContactsPicker)
[![Downloads](https://img.shields.io/cocoapods/dt/EVContactsPicker.svg?style=flat)](http://cocoapods.org/pods/EVContactsPicker)

 ![EVContactsPickerMasthead][img2]

## Swift Versions

Xcode 8.x / Swift 3.0


## Screenshots

![Screenshot0][img0] &nbsp;&nbsp; ![Screenshot1][img1]

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
import EVContactsPicker
```

## Requirements

* iOS 9.0+
* ARC
* Swift 3.0


## Installation

EVContactsPicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EVContactsPicker"
```

## Example

```swift

import UIKit
import EVContactsPicker

class DemoController: UIViewController, EVContactsPickerDelegate {

    ...

    func showPicker() {
        let contactPicker = EVContactsPickerViewController()
        contactPicker.delegate = self
        self.navigationController?.pushViewController(contactPicker, animated: true)
    }

    func didChooseContacts(contacts: [EVContactProtocol]?) {
        if let cons = contacts {
            for con in cons {
                print("\(con.fullname())")
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    ...

}

```


## Author

Edward Valentini, edward@interlook.com

## License

EVContactsPicker is available under the MIT license. See the LICENSE file for more info.

[img0]:https://raw.githubusercontent.com/edwardvalentini/EVContactsPicker/master/Screenshots/screenshot0.png
[img1]:https://raw.githubusercontent.com/edwardvalentini/EVContactsPicker/master/Screenshots/screenshot1.png
[img2]:https://raw.githubusercontent.com/edwardvalentini/EVContactsPicker/master/Screenshots/EVContactsPickerMasthead.png
