//
//  UIViewController+ESSeparatorInset.m
//  TableViewSeparatorInset
//
//  Created by 尹桥印 on 15/7/18.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "UIViewController+ESSeparatorInset.h"
#import <objc/runtime.h>

static NSString *ES_INSETS_ASS_KEY = @"ES_INSETS_ASS_KEY";

@interface UIViewController()

@property (nonatomic, assign) UIEdgeInsets inset;

@end

@implementation UIViewController (ESSeparatorInset)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(tableView:willDisplayCell:forRowAtIndexPath:);
        SEL swizzledSelector = @selector(es_tableView:willDisplayCell:forRowAtIndexPath:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)es_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self respondsToSelector:@selector(es_tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self es_tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    [self setSeparatorInsetWithTarget:cell insets:self.inset];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)setSeparatorInsetZeroWithTableView:(UITableView *)tableView{
    [self setSeparatorInsetWithTableView:tableView inset:UIEdgeInsetsZero];
}

- (void)setSeparatorInsetWithTableView:(UITableView *)tableView inset:(UIEdgeInsets)inset{
    self.inset = inset;
    [self setSeparatorInsetWithTarget:tableView insets:inset];
}

- (void)setSeparatorInsetWithTarget:(id)target insets:(UIEdgeInsets)insets{
    if ([target respondsToSelector:@selector(setSeparatorInset:)]) {
        [target setSeparatorInset:insets];
    }
    if ([target respondsToSelector:@selector(setLayoutMargins:)]) {
        [target setLayoutMargins:insets];
    }
}

- (void)setInset:(UIEdgeInsets)insets{
    NSValue *value = [NSValue valueWithUIEdgeInsets:insets];
    objc_setAssociatedObject(self, &ES_INSETS_ASS_KEY, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)inset{
    NSValue *value = objc_getAssociatedObject(self, &ES_INSETS_ASS_KEY);
    return [value UIEdgeInsetsValue];
}

@end
