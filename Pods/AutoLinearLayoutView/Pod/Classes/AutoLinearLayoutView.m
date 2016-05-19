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

static CGFloat const CONSTRAINT_PRIORITY_WEAK = 100;
static CGFloat const CONSTRAINT_PRIORITY_MEDIUM = 500;
static CGFloat const CONSTRAINT_PRIORITY_STRONG = 900;

// make a pair of Equal and GreaterThanOrEqual constraints
static void makeEqualAndGreaterConstraints(UIView *view1, NSLayoutAttribute attr1, UIView *view2, NSLayoutAttribute attr2, CGFloat constant,
					   void (^block)(NSLayoutConstraint *equal, NSLayoutConstraint *greater)) {
	NSLayoutConstraint *equal = [NSLayoutConstraint constraintWithItem:view1
								 attribute:attr1
								 relatedBy:NSLayoutRelationEqual
								    toItem:view2
								 attribute:attr2
								multiplier:1
								  constant:constant];
	NSLayoutConstraint *greater = [NSLayoutConstraint constraintWithItem:view1
								   attribute:attr1
								   relatedBy:NSLayoutRelationGreaterThanOrEqual
								      toItem:view2
								   attribute:attr2
								  multiplier:1
								    constant:constant];

	block(equal, greater);
}

// make constraints for a view to simulate intrinsic content size
static NSArray<NSLayoutConstraint *> *makeSizeConstraints(UIView *view, CGSize size) {
	NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithCapacity:4];

	// for width
	makeEqualAndGreaterConstraints(view, NSLayoutAttributeWidth, nil, NSLayoutAttributeNotAnAttribute, size.width,
				       ^(NSLayoutConstraint *equal, NSLayoutConstraint *greater) {
					 equal.priority = [view contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
					 greater.priority = [view contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal];
					 [constraints addObject:equal];
					 [constraints addObject:greater];
				       });

	// for height
	makeEqualAndGreaterConstraints(view, NSLayoutAttributeHeight, nil, NSLayoutAttributeNotAnAttribute, size.height,
				       ^(NSLayoutConstraint *equal, NSLayoutConstraint *greater) {
					 equal.priority = [view contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];
					 greater.priority = [view contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisVertical];
					 [constraints addObject:equal];
					 [constraints addObject:greater];
				       });
	return constraints;
}

static BOOL isValidIntrinsicContentSize(CGSize size) { return !(size.width < 0 || size.height < 0); }

static void invalidateConstraintsAndLayout(UIView *view) {

	// traverse superviews and invalidate those are AutoLinearLayoutView
	while (view) {
		if ([view isKindOfClass:AutoLinearLayoutView.class]) {
#if !TARGET_INTERFACE_BUILDER
			[view setNeedsUpdateConstraints];
#endif
			[view setNeedsLayout];
		}
		view = view.superview;
	}
}

static NSInteger nestingDepth(UIView *view) {
	NSInteger depth = 0;
	view = view.superview;
	while (view) {
		if ([view isKindOfClass:AutoLinearLayoutView.class])
			++depth;
		view = view.superview;
	}
	return depth;
}

///////
@interface AutoLinearLayoutView () {
	NSArray<NSLayoutConstraint *> *_addedConstraints;
}
@end

IB_DESIGNABLE
@implementation AutoLinearLayoutView

- (void)awakeFromNib {
	[super awakeFromNib];

	const Class NSIBPrototypingLayoutConstraint_ = NSClassFromString(@"NSIBPrototypingLayoutConstraint");

	// skip prototyping constraints added to sub views by IB
	NSMutableArray<NSLayoutConstraint *> *constraintsToSkip = [NSMutableArray array];
	for (NSLayoutConstraint *constraint in self.constraints) {
		if ([constraint isKindOfClass:NSIBPrototypingLayoutConstraint_])
			[constraintsToSkip addObject:constraint];
	}
	[self removeConstraints:constraintsToSkip];

	[constraintsToSkip removeAllObjects];

	// skip prototyping constraints added to self by IB
	for (NSLayoutConstraint *constraint in self.superview.constraints) {
		if ((constraint.firstItem == self || constraint.secondItem == self) && [constraint isKindOfClass:NSIBPrototypingLayoutConstraint_])
			[constraintsToSkip addObject:constraint];
	}
	[self.superview removeConstraints:constraintsToSkip];
}

#if !TARGET_INTERFACE_BUILDER
- (void)didAddSubview:(UIView *)subview {
	[super didAddSubview:subview];
	// as an auto layout fan ...
	subview.translatesAutoresizingMaskIntoConstraints = NO;

	invalidateConstraintsAndLayout(self);
}
#endif

- (void)willRemoveSubview:(UIView *)subview {
	[super willRemoveSubview:subview];
	invalidateConstraintsAndLayout(self);
}

- (void)updateConstraints {

	static CGFloat const CONSTRAINT_PRIORITY_NESTING_DECREASE = 0.01;
	static CGFloat const CONSTRAINT_PRIORITY_ALIGNMENT_INCREASE = 0.001;
	static CGFloat const CONSTRAINT_PRIORITY_SPACING_INCREASE = 0.002;

	if (_addedConstraints) {
		[self removeConstraints:_addedConstraints];
		_addedConstraints = nil;
	}

	CGSize mySize = CGSizeZero;
	NSMutableArray<NSLayoutConstraint *> *constraintsToAdd = [NSMutableArray array];

	NSArray<UIView *> *subviews = self.subviews;
	if (subviews.count > 0) {

		const CGFloat priorityDecrease = nestingDepth(self) * CONSTRAINT_PRIORITY_NESTING_DECREASE;

		CGFloat minHorizHugging = UILayoutPriorityRequired;
		CGFloat minVertHugging = UILayoutPriorityRequired;

		for (UIView *subview in subviews) {
			minHorizHugging = MIN(minHorizHugging, [subview contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal]);
			minVertHugging = MIN(minVertHugging, [subview contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical]);
		}

		for (int i = 0; i < subviews.count; ++i) {
			UIView *sub = subviews[i];

			const CGFloat horizHugging = [sub contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal];
			const CGFloat vertHugging = [sub contentHuggingPriorityForAxis:UILayoutConstraintAxisVertical];

			id block = ^(NSLayoutConstraint *equal, NSLayoutConstraint *greater) {
			  [constraintsToAdd addObject:equal];
			  [constraintsToAdd addObject:greater];

			  equal.priority = CONSTRAINT_PRIORITY_WEAK;
			  greater.priority = CONSTRAINT_PRIORITY_STRONG;

			  if (equal.firstAttribute == NSLayoutAttributeLeading || equal.firstAttribute == NSLayoutAttributeTrailing) {
				  if ((_axisVertical ? horizHugging : minHorizHugging) < CONSTRAINT_PRIORITY_WEAK)
					  equal.priority = CONSTRAINT_PRIORITY_MEDIUM;
			  } else {
				  if ((_axisVertical ? minVertHugging : vertHugging) < CONSTRAINT_PRIORITY_WEAK)
					  equal.priority = CONSTRAINT_PRIORITY_MEDIUM;
			  }

			  if (equal.firstAttribute != equal.secondAttribute) {
				  // spacing
				  equal.priority += CONSTRAINT_PRIORITY_SPACING_INCREASE;
				  greater.priority += CONSTRAINT_PRIORITY_SPACING_INCREASE;
			  } else {
				  // insets
				  if (equal.firstAttribute == (_alignTrailing ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading) ||
				      equal.firstAttribute == (_alignBottom ? NSLayoutAttributeBottom : NSLayoutAttributeTop)) {

					  equal.priority += CONSTRAINT_PRIORITY_ALIGNMENT_INCREASE;
					  greater.priority += CONSTRAINT_PRIORITY_ALIGNMENT_INCREASE;
				  }
			  }
			  equal.priority -= priorityDecrease;
			  greater.priority -= priorityDecrease;
			};

			{
				// make constraints for insets against axis
				NSLayoutAttribute attribute = _axisVertical ? NSLayoutAttributeLeading : NSLayoutAttributeTop;
				makeEqualAndGreaterConstraints(sub, attribute, self, attribute, (_axisVertical ? _insets.left : _insets.top), block);
			}
			{
				// make constraints for insets against axis
				NSLayoutAttribute attribute = _axisVertical ? NSLayoutAttributeTrailing : NSLayoutAttributeBottom;
				makeEqualAndGreaterConstraints(self, attribute, sub, attribute, (_axisVertical ? _insets.right : _insets.bottom), block);
			}

			if (sub == subviews.firstObject) {
				// make constraints for first sub view with me
				NSLayoutAttribute attribute = _axisVertical ? NSLayoutAttributeTop : NSLayoutAttributeLeading;
				makeEqualAndGreaterConstraints(sub, attribute, self, attribute, (_axisVertical ? _insets.top : _insets.left), block);
			} else {
				// make constraints for spacing between sub views
				makeEqualAndGreaterConstraints(sub, (_axisVertical ? NSLayoutAttributeTop : NSLayoutAttributeLeading), subviews[i - 1],
							       (_axisVertical ? NSLayoutAttributeBottom : NSLayoutAttributeTrailing), _spacing, block);
			}

			if (sub == subviews.lastObject) {
				// make constraints for last sub view with me
				NSLayoutAttribute attribute = _axisVertical ? NSLayoutAttributeBottom : NSLayoutAttributeTrailing;
				makeEqualAndGreaterConstraints(self, attribute, sub, attribute, (_axisVertical ? _insets.bottom : _insets.right), block);
			}

			if (_alignCenterAgainstAxis) {
				// make constraints for center alignment
				CGFloat constant = (_axisVertical ? (_insets.left - _insets.right) : (_insets.top - _insets.bottom)) / 2;
				NSLayoutAttribute attribute = _axisVertical ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;
				NSLayoutConstraint *center = [NSLayoutConstraint constraintWithItem:sub
											  attribute:attribute
											  relatedBy:NSLayoutRelationEqual
											     toItem:self
											  attribute:attribute
											 multiplier:1
											   constant:constant];

				center.priority = CONSTRAINT_PRIORITY_STRONG + CONSTRAINT_PRIORITY_ALIGNMENT_INCREASE * 2 - priorityDecrease;
				[constraintsToAdd addObject:center];
			}

			// measure
			CGSize subViewSize = [sub systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

			if (!isValidIntrinsicContentSize(sub.intrinsicContentSize) && ![sub isKindOfClass:AutoLinearLayoutView.class]) {
				// to simulate intrinsic content size for sub view that has no intrinsic content size
				[constraintsToAdd addObjectsFromArray:makeSizeConstraints(sub, subViewSize)];
			}

			mySize.width = _axisVertical ? MAX(subViewSize.width, mySize.width) : (mySize.width + MAX(subViewSize.width, 0));
			mySize.height = _axisVertical ? (mySize.height + subViewSize.height) : MAX(mySize.height, MAX(subViewSize.height, 0));
		}

		CGFloat totalSpacing = _spacing * (subviews.count - 1);
		if (_axisVertical)
			mySize.height += totalSpacing;
		else
			mySize.width += totalSpacing;
	}
	mySize.width += (_insets.left + _insets.right);
	mySize.height += (_insets.top + _insets.bottom);

	// simulate intrinsic content size to get hugging and compression work
	[constraintsToAdd addObjectsFromArray:makeSizeConstraints(self, mySize)];

	[self addConstraints:constraintsToAdd];
	_addedConstraints = constraintsToAdd;

	[super updateConstraints];
}

- (void)setAxisVertical:(BOOL)axisVertical {
	if (_axisVertical == axisVertical)
		return;

	_axisVertical = axisVertical;
	invalidateConstraintsAndLayout(self);
}

- (void)setInsets:(UIEdgeInsets)insets {
	if (UIEdgeInsetsEqualToEdgeInsets(_insets, insets))
		return;

	_insets = insets;
	invalidateConstraintsAndLayout(self);
}

- (void)setSpacing:(CGFloat)spacing {
	if (_spacing == spacing)
		return;

	_spacing = spacing;
	invalidateConstraintsAndLayout(self);
}

- (void)setAlignTrailing:(BOOL)alignTrailing {
	if (_alignTrailing == alignTrailing)
		return;

	_alignTrailing = alignTrailing;
	invalidateConstraintsAndLayout(self);
}
- (void)setAlignBottom:(BOOL)alignBottom {
	if (_alignBottom == alignBottom)
		return;

	_alignBottom = alignBottom;
	invalidateConstraintsAndLayout(self);
}

- (void)setAlignCenterAgainstAxis:(BOOL)alignCenterAgainstAxis {
	if (_alignCenterAgainstAxis == alignCenterAgainstAxis)
		return;

	_alignCenterAgainstAxis = alignCenterAgainstAxis;
	invalidateConstraintsAndLayout(self);
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
