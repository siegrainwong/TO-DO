// AutoLinearLayoutView.h
//
// Copyright (c) 2016 modoohut.com
//
// cola.tin.com@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

@interface AutoLinearLayoutView : UIView

@property(nonatomic) UIEdgeInsets insets;

@property(nonatomic) IBInspectable BOOL axisVertical;

@property(nonatomic) IBInspectable BOOL alignTrailing;
@property(nonatomic) IBInspectable BOOL alignBottom;

@property(nonatomic) IBInspectable BOOL alignCenterAgainstAxis;

@property(nonatomic) IBInspectable CGFloat spacing;
@end

@interface AutoLinearLayoutView (SeparatedInsets)
@property(nonatomic) IBInspectable CGFloat insetLeading;
@property(nonatomic) IBInspectable CGFloat insetTrailing;
@property(nonatomic) IBInspectable CGFloat insetTop;
@property(nonatomic) IBInspectable CGFloat insetBottom;
@end
