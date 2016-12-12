About EMString
===

![demo](https://dl.dropboxusercontent.com/u/20482310/EMString.gif)


<strong>EMString</strong> stands for <em><strong>E</strong>asy <strong>M</strong>arkup <strong>S</strong>tring</em>. I hesitated to call it SONSAString : Sick Of NSAttributedString...

Even if Apple tried to make it easier for us to work with custom fonts and text styling, it still isn't as convenient as it should be.
Most of the time if you need to display a text with different styling in it, like "<strong>This text is bold</strong> but then <em>italic.</em>", you would use an <code>NSAttributedString</code> and its API.<br>Personnaly I don't like it! It clusters my classes with a lot of boilerplate code to find range and apply style, etc... Or even worse you would use two labels but then struggle to make their frame aligned with dymamic text...

This should be an easier task. Like right now when I'm typing this <b>README</b> file. I just naturally wrote :
```
<strong>This text is bold</strong> but then <em>italic.</em>
```
This is what <strong>EMString</strong> is about. Use the efficient <ins>HTML markup</ins> system we all know and get an iOS string stylized in one line of code and behave like you would expect it to.

How it works
===

What else but to show you a without/with <strong>EMString</strong> snippet of code to illustrate how awesome it is?
Lets take our "<strong>This text is bold</strong> but then <em>italic.</em>" example and write it in Objective-c.

<strong>Without EMString</strong>
```objc
NSString *myString = @"This text is bold but then italic.";
NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:myString];
[attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[myString rangeOfString:@"This text is bold"]];
[attributedString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:16] range:[myString rangeOfString:@"italic."]];

myLabel.attributedText = attributedString;
```

<strong>With EMString</strong>
```objc
myLabel.attributedText = @"<strong>This text is bold</strong> but then <em>italic.</em>".attributedString;
```

Do I need to say more? :)

Installation
===

#### CocoaPods

With CocoaPods by adding in your podfile the following line :

```ruby
pod 'EMString'
```

#### Manually

It's quite easy, just download the archive and add the <code>EMString</code> folder to your own project.
Don't forget to import the header file wherever you need it :

``` objective-c
#import "NSString+EMAdditions.h"
```

Customization's magic
===

If we talk about styling text then we talk about <em>customization</em> and <em>versatility</em>. 
<strong>EMString</strong> gives you precisely that.
Firstly, it comes with a set of default markup:
<em><ul><li>strong</li><li>em</li><li>p</li><li>u</li><li>s</li><li>and headings h1,h2,...,h6</li></ul></em>

Those markup can be easily customized to fit your need.
Basically you can set for each of those pre-defined markup:
<em><ul><li>A specific font</li><li>A specific color</li><li>A display rule (inline/block)</li></ul></em>

To apply a different style you have to modify properties of <code>EMStringStylingConfiguration</code>

For example, in the followup code I will show you how to change the <strong>h1</strong> and <strong>strong</strong> markup behavior:

```objc
// Change h1 font
[EMStringStylingConfiguration sharedInstance].h1Font = [UIFont fontWithName:@"OpenSans" size:26];
// Change h1 color
[EMStringStylingConfiguration sharedInstance].h1Color = [UIColor blueColor];
// Change strong font
[EMStringStylingConfiguration sharedInstance].strongFont = [UIFont fontWithName:@"OpenSans-Bold" size:fontSize];
```

Also if you have a default color and/or font for your whole app you can use those two convenient properties.
```objc
@property (strong, nonatomic) UIFont *defaultFont;

@property (strong, nonatomic) UIColor *defaultColor;
```

Secondly, what if you need your own markup? Well <strong>EMString</strong> make it simple once again.
Use the convenient <code>EMStylingClass</code> object to create a custom class:

```objc
EMStylingClass *aStylingClass = [[EMStylingClass alloc] initWithMarkup:@"<customMarkup>"];
aStylingClass.color = [UIColor blueColor];
aStylingClass.font  = [UIFont fontWithName:@"OpenSans" size:16];
// Or you can use the attributes property for full control
// aStylingClass.attributes = @{};
[[EMStringStylingConfiguration sharedInstance] addNewStylingClass:aStylingClass];
```

Since <code>EMStringStylingConfiguration.h</code> is a singleton you don't have to do this everytime. <em>Only once</em>, to setup your styling need. After that, all call to .attributedString will give you the NSAttributedString properly styled.
This will help you to be consistent in your design as well.

For a better idea of all you the things you can do, I suggest you take a look at the header files <code>EMStringStylingConfiguration.h</code> and <code>EMStylingClass.h</code>.


Advantages
===

Here is a list of advantages I personnaly found while using <strong>EMString</strong>:
<ul>
<li>Cleaner & prettier code</li>
<li>One configuration to rule them all!</li>
<li>Better consistency in your design</li>
<li>Abstraction of <code>NSAttributedString</code> API</li>
<li>Localization/Dynamic text</li>
</ul>

The last one may need further explanation. When working on a project while using <code>NSAttributedString</code> I stumble upon this issue:
I had a label showing a string with a bold and light font mixed up.
Basically the text would be compose of a place name (in bold) followed by its city location (in light).
So I used range of string to apply styling. But it got complicated when a restaurant's name would have have the city in it.
Like for example <q>Café de Paris, Paris.</q> The first instance of Paris would be light and not bold, and the second instance would not have been styled. This problem could be raised by any dynamic/translated text.
I know that I could fix this by appending attributedString together... but making my code longer and uglier for a simple matter.

```objc
// Simply like that with EMString
[NSString stringWithFormat:@"<strong>%@,</strong><light>%@</light>", place.name, place.city].attributedString
```

License
===

EMString is available under the MIT license. See the LICENSE file for more info.

More
===

Contribute to this repository as much as you like, and any advice are welcome! =). I hope you will enjoy it.
