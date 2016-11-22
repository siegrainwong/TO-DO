SSDynamicText
=============

[![Circle CI](https://circleci.com/gh/splinesoft/SSDynamicText.svg?style=svg)](https://circleci.com/gh/splinesoft/SSDynamicText) [![codecov.io](http://codecov.io/github/splinesoft/SSDynamicText/coverage.svg?branch=master)](http://codecov.io/github/splinesoft/SSDynamicText?branch=master)
[![Version](https://img.shields.io/cocoapods/v/SSDynamicText.svg)](http://cocoapods.org/pods/SSDynamicText)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

iOS 7's [`UIFontDescriptor`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIFontDescriptor_Class/) is pretty neat. Also pretty neat is dynamic text that responds to the preferred text size that the user specified in Settings.app.

What's not so neat, though, is that `+[UIFont preferredFontForTextStyle:]` only works with the system font, Helvetica Neue (iOS 8) or San Francisco (iOS 9). What if you have custom fonts and want to respect the user's text size preference?

SSDynamicText is a collection of simple `UILabel`, `UIButton`, `UITextField`, and `UITextView` subclasses inspired by [this](http://stackoverflow.com/questions/18758227/ios7-can-we-use-other-than-helvetica-neue-fonts-with-dynamic-type/19024944#19024944) SO answer.

## Requirements

Xcode 7.0+ with iOS 7.0+ SDK.

## Install

### [CocoaPods](http://cocoapods.org)
Add to your `Podfile`:

```ruby
pod 'SSDynamicText', '~> 1.0.0'
```

### [Carthage](https://github.com/Carthage/Carthage)
Add to your `Cartfile`:

```ruby
github "splinesoft/SSDynamicText", ~> 1.1.0
```

## Example usage

`SSDynamicText` provides dynamic auto-sizing labels, buttons, text fields, and text views that respond when the user changes her preferred text size. Check out a full [example](https://github.com/splinesoft/SSDynamicText/blob/master/Example/SSDynamicTextExample/SSViewController.m).

UIKit views that responds when the user changes her preferred text size:

### `SSDynamicLabel`

```objc
SSDynamicLabel *myLabel = [SSDynamicLabel labelWithFont:@"Courier"
                                               baseSize:16.0f];
myLabel.text = @"Auto-sizing text!";

// Already have a font descriptor?
UIFontDescriptor *aDescriptor = [UIFontDescriptor fontDescriptorWithName:@"Courier"
                                                                    size:16.0f];
SSDynamicLabel *otherLabel = [SSDynamicLabel labelWithFontDescriptor:aDescriptor];
```

### `SSDynamicButton`

```objc
SSDynamicButton *myButton = [SSDynamicButton buttonWithFont:@"Courier"
                                                   baseSize:16.0f];
[myButton setText:@"Auto-sizing text!" forControlState:UIControlStateNormal];
```

### `SSDynamicTextField`

```objc
SSDynamicTextField *myTextField = [SSDynamicTextField textFieldWithFont:@"Courier"
                                                               baseSize:16.0f];
myTextField.text = @"Auto-sizing text!";
```

### `SSDynamicTextView`

```objc
SSDynamicTextView *myTextView = [SSDynamicTextView textViewWithFont:@"Courier"
                                                           baseSize:16.0f];
myTextView.text = @"Auto-sizing text!";
```

## `UIFont+SSTextSize`

Create a `UIFont` object using the specified font name and base size.
The actual size of the returned font is adjusted by the user's current preferred font size (specified in Settings.app).

```objc
UIFont *myFont = [UIFont dynamicFontWithName:@"Courier" baseSize:16.0f];
```

## `UIApplication+SSTextSize`

This property returns a numeric delta between the default size setting (Large) and the user's current preferred text size.

You probably don't need to use this directly.

```objc
NSInteger textDelta = [[UIApplication sharedApplication] preferredFontSizeDelta];
```

## `NSAttributedString` Support

SSDynamicText supports attributed text! Assign your `NSAttributedString` to the new `dynamicAttributedText` property.

`UITextView` and `UITextField` sometimes internally call `-setAttributedText:` even with normal text. To best accommodate that internal implementation detail, we've added a new `dynamicAttribtuedText` property instead of overriding `-setAttributedText:`.

```objc
@property (nonatomic, copy) NSAttributedString *dynamicAttributedText;
```

## Thanks!

`SSDynamicText` is a [@jhersh](https://github.com/jhersh) production -- ([electronic mail](mailto:jon@her.sh) | [@jhersh](https://twitter.com/jhersh))
