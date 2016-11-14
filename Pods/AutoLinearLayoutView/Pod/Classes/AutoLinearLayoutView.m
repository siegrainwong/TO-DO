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

#import "AutoLinearLayoutView.h"

// make a pair of LessThanOrEqual and GreaterThanOrEqual constraints
static void makePairedConstraints(UIView *view1, NSLayoutAttribute attr1, UIView *view2, NSLayoutAttribute attr2,
				  void (^block)(NSLayoutConstraint *le, NSLayoutConstraint *ge)) {
	NSLayoutConstraint *le = [NSLayoutConstraint constraintWithItem:view1
							      attribute:attr1
							      relatedBy:NSLayoutRelationLessThanOrEqual
								 toItem:view2
							      attribute:attr2
							     multiplier:1
							       constant:0];

	NSLayoutConstraint *ge = [NSLayoutConstraint constraintWithItem:view1
							      attribute:attr1
							      relatedBy:NSLayoutRelationGreaterThanOrEqual
								 toItem:view2
							      attribute:attr2
							     multiplier:1
							       constant:0];

	block(le, ge);
}

static BOOL isValidIntrinsicContentSize(CGSize size) { return !(size.width < 0 || size.height < 0); }

///////
@interface AutoLinearLayoutView () {
	NSArray<NSLayoutConstraint *> *_insetConstraints;
	NSArray<NSLayoutConstraint *> *_spacingConstraints;
	NSArray<NSLayoutConstraint *> *_centerConstraints;
	NSArray<NSLayoutConstraint *> *_sizeConstraints;
	NSArray<NSLayoutConstraint *> *_otherConstraints;
}
@end

IB_DESIGNABLE
@implementation AutoLinearLayoutView
#if !TARGET_INTERFACE_BUILDER
static Class NSIBPrototypingLayoutConstraint_;
+ (void)load {
	NSIBPrototypingLayoutConstraint_ = NSClassFromString(@"NSIBPrototypingLayoutConstraint");
}

- (void)awakeFromNib {
	[super awakeFromNib];

	NSMutableArray<NSLayoutConstraint *> *constraintsToSkip = [NSMutableArray array];
	// skip prototyping constraints added to self by IB
	for (NSLayoutConstraint *constraint in self.superview.constraints) {
		if ((constraint.firstItem == self || constraint.secondItem == self) && [constraint isKindOfClass:NSIBPrototypingLayoutConstraint_])
			[constraintsToSkip addObject:constraint];
	}
	[self.superview removeConstraints:constraintsToSkip];
}

- (void)addConstraint:(NSLayoutConstraint *)constraint {
	// skip prototyping constraints added to subview by IB
	if ([constraint isKindOfClass:NSIBPrototypingLayoutConstraint_])
		return;
	[super addConstraint:constraint];
}
#endif

- (void)didAddSubview:(UIView *)subview {
	[super didAddSubview:subview];
#if !TARGET_INTERFACE_BUILDER
	subview.translatesAutoresizingMaskIntoConstraints = NO;
#endif
	[self allv_setNeedsUpdateConstraints];
}

- (void)willRemoveSubview:(UIView *)subview {
	[super willRemoveSubview:subview];
	[self allv_setNeedsUpdateConstraints];
}

- (void)updateConstraints {

	[self removeConstraints:_insetConstraints];
	[self removeConstraints:_spacingConstraints];
	[self removeConstraints:_centerConstraints];
	[self removeConstraints:_sizeConstraints];
	[self removeConstraints:_otherConstraints];

	[self allv_buildConstraints];
	[self allv_updateConstraintsConstant];

	[self addConstraints:_insetConstraints];
	[self addConstraints:_spacingConstraints];
	[self addConstraints:_centerConstraints];
	[self addConstraints:_sizeConstraints];
	[self addConstraints:_otherConstraints];

	[super updateConstraints];
}

- (void)allv_setNeedsUpdateConstraints {
#if TARGET_INTERFACE_BUILDER
	[self setNeedsLayout];
#else
	[self setNeedsUpdateConstraints];
#endif
}

- (void)allv_buildConstraints {

	static CGFloat const BASE_PRIORITY_WEAK = 100;
	static CGFloat const BASE_PRIORITY_MEDIUM = 500;
	static CGFloat const BASE_PRIORITY_STRONG = 900;

	static CGFloat const PRIORITY_NESTING_DECREASE = 0.01;
	static CGFloat const PRIORITY_ALIGNMENT_INCREASE = 0.001;
	static CGFloat const PRIORITY_SPACING_INCREASE = PRIORITY_ALIGNMENT_INCREASE * 2;

	const CGFloat DECREASE = [self allv_nestingDepth] * PRIORITY_NESTING_DECREASE;
	const CGFloat PRIORITY_WEAK = BASE_PRIORITY_WEAK - DECREASE;
	const CGFloat PRIORITY_MEDIUM = BASE_PRIORITY_MEDIUM - DECREASE;
	const CGFloat PRIORITY_STRONG = BASE_PRIORITY_STRONG - DECREASE;

	const BOOL alignAxialEnd = _axisVertical ? _alignBottom : _alignTrailing;
	const BOOL alignNonAxialEnd = _axisVertical ? _alignTrailing : _alignBottom;

	const NSLayoutAttribute axialAttrStart = _axisVertical ? NSLayoutAttributeTop : NSLayoutAttributeLeading;
	const NSLayoutAttribute axialAttrEnd = _axisVertical ? NSLayoutAttributeBottom : NSLayoutAttributeTrailing;
	const NSLayoutAttribute nonAxialAttrStart = _axisVertical ? NSLayoutAttributeLeading : NSLayoutAttributeTop;
	const NSLayoutAttribute nonAxialAttrEnd = _axisVertical ? NSLayoutAttributeTrailing : NSLayoutAttributeBottom;

	NSMutableArray<NSLayoutConstraint *> *insetConstraints = [NSMutableArray array];
	NSMutableArray<NSLayoutConstraint *> *spacingConstraints = [NSMutableArray array];
	NSMutableArray<NSLayoutConstraint *> *centerConstraints = [NSMutableArray array];
	NSMutableArray<NSLayoutConstraint *> *sizeConstraints = [NSMutableArray array];
	NSMutableArray<NSLayoutConstraint *> *otherConstraints = [NSMutableArray array];

	NSArray<UIView *> *subviews = self.subviews;
	UIView *prevSibling = nil;
	for (UIView *sub in subviews) {

		const CGFloat horizHugging = [sub contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
		const CGFloat vertHugging = [sub contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];
		const CGFloat horizCompression = [sub contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal];
		const CGFloat vertCompression = [sub contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical];

		const CGFloat axialHugging = _axisVertical ? vertHugging : horizHugging;
		const CGFloat nonAxialHugging = _axisVertical ? horizHugging : vertHugging;
		const CGFloat nonAxialCompression = _axisVertical ? horizCompression : vertCompression;

		// non-axial start inset (top/leading)
		makePairedConstraints(sub, nonAxialAttrStart, self, nonAxialAttrStart, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
		  [insetConstraints addObject:le];
		  [insetConstraints addObject:ge];
		  // non-axial filling for low hugging sub view
		  le.priority = (nonAxialHugging < BASE_PRIORITY_WEAK ? PRIORITY_MEDIUM : PRIORITY_WEAK);
		  //
		  ge.priority = (nonAxialCompression > BASE_PRIORITY_STRONG ? PRIORITY_MEDIUM : PRIORITY_STRONG);
		});
		// non-axial end inset (bottom/trailing)
		makePairedConstraints(self, nonAxialAttrEnd, sub, nonAxialAttrEnd, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
		  [insetConstraints addObject:le];
		  [insetConstraints addObject:ge];

		  // non-axial filling for low hugging sub view
		  le.priority = (nonAxialHugging < BASE_PRIORITY_WEAK ? PRIORITY_MEDIUM : PRIORITY_WEAK);
		  ge.priority = (nonAxialCompression > BASE_PRIORITY_STRONG ? PRIORITY_MEDIUM : PRIORITY_STRONG);

		  // apply bottom/trailing alignment
		  CGFloat delta = alignNonAxialEnd ? PRIORITY_ALIGNMENT_INCREASE : -PRIORITY_ALIGNMENT_INCREASE;
		  le.priority += delta;
		  ge.priority += delta;
		});

		// axial start inset (leading/top)
		if (sub == subviews.firstObject) {
			makePairedConstraints(sub, axialAttrStart, self, axialAttrStart, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
			  [insetConstraints addObject:le];
			  [insetConstraints addObject:ge];

			  le.priority = PRIORITY_WEAK;
			  ge.priority = PRIORITY_STRONG;
			});
		}
		// axial end inset (trailing/bottom)
		if (sub == subviews.lastObject) {
			makePairedConstraints(self, axialAttrEnd, sub, axialAttrEnd, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
			  [insetConstraints addObject:le];
			  [insetConstraints addObject:ge];

			  le.priority = PRIORITY_WEAK;
			  ge.priority = PRIORITY_STRONG;

			  // apply trailing/bottom alignment
			  CGFloat delta = alignAxialEnd ? PRIORITY_ALIGNMENT_INCREASE : -PRIORITY_ALIGNMENT_INCREASE;
			  le.priority += delta;
			  ge.priority += delta;

			});
		}

		if (prevSibling) {
			// spacing
			makePairedConstraints(sub, axialAttrStart, prevSibling, axialAttrEnd, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
			  [spacingConstraints addObject:le];
			  [spacingConstraints addObject:ge];

			  le.priority = PRIORITY_WEAK + PRIORITY_SPACING_INCREASE;
			  ge.priority = PRIORITY_STRONG + PRIORITY_SPACING_INCREASE;
			});
		}

		if (_alignCenterAgainstAxis) {
			// make constraints for center alignment
			NSLayoutAttribute attr = _axisVertical ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;
			NSLayoutConstraint *center = [NSLayoutConstraint constraintWithItem:sub
										  attribute:attr
										  relatedBy:NSLayoutRelationEqual
										     toItem:self
										  attribute:attr
										 multiplier:1
										   constant:0];
			[centerConstraints addObject:center];
			center.priority = PRIORITY_MEDIUM;
		}

		if (!isValidIntrinsicContentSize(sub.intrinsicContentSize)) {
			if (axialHugging < PRIORITY_WEAK) {
				// axial filling for low hugging sub view
				NSLayoutConstraint *start = [NSLayoutConstraint constraintWithItem:sub
											 attribute:axialAttrStart
											 relatedBy:NSLayoutRelationLessThanOrEqual
											    toItem:self
											 attribute:axialAttrStart
											multiplier:1
											  constant:0];

				NSLayoutConstraint *end = [NSLayoutConstraint constraintWithItem:self
										       attribute:axialAttrEnd
										       relatedBy:NSLayoutRelationLessThanOrEqual
											  toItem:sub
										       attribute:axialAttrEnd
										      multiplier:1
											constant:0];

				[otherConstraints addObject:start];
				[otherConstraints addObject:end];
				start.priority = end.priority = PRIORITY_MEDIUM;
			}

			if (![sub isKindOfClass:AutoLinearLayoutView.class]) {
				// hug sub view as small as possible
				NSLayoutConstraint *widthHug = [NSLayoutConstraint constraintWithItem:sub
											    attribute:NSLayoutAttributeWidth
											    relatedBy:NSLayoutRelationLessThanOrEqual
											       toItem:nil
											    attribute:NSLayoutAttributeNotAnAttribute
											   multiplier:1
											     constant:0];

				NSLayoutConstraint *heightHug = [NSLayoutConstraint constraintWithItem:sub
											     attribute:NSLayoutAttributeHeight
											     relatedBy:NSLayoutRelationLessThanOrEqual
												toItem:nil
											     attribute:NSLayoutAttributeNotAnAttribute
											    multiplier:1
											      constant:0];

				[otherConstraints addObject:widthHug];
				[otherConstraints addObject:heightHug];
				widthHug.priority = horizHugging;
				heightHug.priority = vertHugging;
			}
		}

		prevSibling = sub;
	}

	// hug self as small as possible
	makePairedConstraints(self, NSLayoutAttributeWidth, nil, NSLayoutAttributeNotAnAttribute, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
	  [sizeConstraints addObject:le];
	  [sizeConstraints addObject:ge];

	  le.priority = [self contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
	  ge.priority = [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal];

	});

	makePairedConstraints(self, NSLayoutAttributeHeight, nil, NSLayoutAttributeNotAnAttribute, ^(NSLayoutConstraint *le, NSLayoutConstraint *ge) {
	  [sizeConstraints addObject:le];
	  [sizeConstraints addObject:ge];

	  le.priority = [self contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];
	  ge.priority = [self contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical];
	});

	_insetConstraints = [insetConstraints copy];
	_spacingConstraints = [spacingConstraints copy];
	_centerConstraints = [centerConstraints copy];
	_sizeConstraints = [sizeConstraints copy];
	_otherConstraints = [otherConstraints copy];
}

- (void)allv_updateConstraintsConstant {

	for (NSLayoutConstraint *cons in _insetConstraints) {
		switch (cons.firstAttribute) {
		case NSLayoutAttributeLeading:
			cons.constant = _insets.left;
			break;
		case NSLayoutAttributeTrailing:
			cons.constant = _insets.right;
			break;
		case NSLayoutAttributeTop:
			cons.constant = _insets.top;
			break;
		case NSLayoutAttributeBottom:
			cons.constant = _insets.bottom;
			break;
		default:
			NSAssert(NO, @"unexcepted attribute %ld", cons.firstAttribute);
			break;
		}
	}

	for (NSLayoutConstraint *cons in _spacingConstraints)
		cons.constant = _spacing;

	for (NSLayoutConstraint *cons in _centerConstraints)
		cons.constant = (_axisVertical ? (_insets.left - _insets.right) : (_insets.top - _insets.bottom)) / 2;

	NSArray<UIView *> *subviews = self.subviews;
	CGFloat totalSpacing = subviews.count > 1 ? _spacing * (subviews.count - 1) : 0;
	for (NSLayoutConstraint *cons in _sizeConstraints) {
		if (cons.firstAttribute == NSLayoutAttributeWidth)
			cons.constant = _insets.left + _insets.right + (_axisVertical ? 0 : totalSpacing);
		else if (cons.firstAttribute == NSLayoutAttributeHeight)
			cons.constant = _insets.top + _insets.bottom + (_axisVertical ? totalSpacing : 0);
		else
			NSAssert(NO, @"unexcepted attribute %ld", cons.firstAttribute);
	}
}

- (NSUInteger)allv_nestingDepth {
	NSUInteger depth = 0;
	UIView *view = self.superview;
	while (view) {
		if ([view isKindOfClass:AutoLinearLayoutView.class])
			++depth;
		view = view.superview;
	}
	return depth;
}

- (void)setAxisVertical:(BOOL)axisVertical {
	if (_axisVertical == axisVertical)
		return;

	_axisVertical = axisVertical;
	[self allv_setNeedsUpdateConstraints];
}

- (void)setInsets:(UIEdgeInsets)insets {
	if (UIEdgeInsetsEqualToEdgeInsets(_insets, insets))
		return;

	_insets = insets;
	[self allv_updateConstraintsConstant];
}

- (void)setSpacing:(CGFloat)spacing {
	if (_spacing == spacing)
		return;

	_spacing = spacing;
	[self allv_updateConstraintsConstant];
}

- (void)setAlignTrailing:(BOOL)alignTrailing {
	if (_alignTrailing == alignTrailing)
		return;

	_alignTrailing = alignTrailing;
	[self allv_setNeedsUpdateConstraints];
}
- (void)setAlignBottom:(BOOL)alignBottom {
	if (_alignBottom == alignBottom)
		return;

	_alignBottom = alignBottom;
	[self allv_setNeedsUpdateConstraints];
}

- (void)setAlignCenterAgainstAxis:(BOOL)alignCenterAgainstAxis {
	if (_alignCenterAgainstAxis == alignCenterAgainstAxis)
		return;

	_alignCenterAgainstAxis = alignCenterAgainstAxis;
	[self allv_setNeedsUpdateConstraints];
}
@end

@implementation AutoLinearLayoutView (SeparatedInsets)

- (CGFloat)insetLeading {
	return _insets.left;
}

- (void)setInsetLeading:(CGFloat)insetLeading {
	UIEdgeInsets insets = self.insets;
	insets.left = insetLeading;
	self.insets = insets;
}

- (CGFloat)insetTrailing {
	return _insets.right;
}

- (void)setInsetTrailing:(CGFloat)insetTrailing {
	UIEdgeInsets insets = self.insets;
	insets.right = insetTrailing;
	self.insets = insets;
}

- (CGFloat)insetTop {
	return _insets.top;
}

- (void)setInsetTop:(CGFloat)insetTop {
	UIEdgeInsets insets = self.insets;
	insets.top = insetTop;
	self.insets = insets;
}

- (CGFloat)insetBottom {
	return _insets.bottom;
}

- (void)setInsetBottom:(CGFloat)insetBottom {
	UIEdgeInsets insets = self.insets;
	insets.bottom = insetBottom;
	self.insets = insets;
}

@end
