//
// Created by Siegrain on 16/11/22.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGDelegateProxy.h"
#import <objc/runtime.h>

@interface SGDelegateProxy ()

@property(nonatomic, weak) id target;

@end

@implementation SGDelegateProxy

#pragma mark - initial

- (instancetype)initWithTarget:(id)target {
    if (self) {
        self.target = target;
    }
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

#pragma mark - forward

- (id)forwardingTargetForSelector:(SEL)sel {
    BOOL isOriginalDelegateResponds = [self.originalDelegate respondsToSelector:sel];
    BOOL isTargetResponds = [self.target respondsToSelector:sel];
    if (isOriginalDelegateResponds && !isTargetResponds) {
        return self.originalDelegate;
    } else if (!isOriginalDelegateResponds && isTargetResponds) {
        return self.target;
    } else {
        return self;
    }
}

#pragma mark - nsproxy

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.target respondsToSelector:invocation.selector]) {
        NSInvocation *invocationCopy = [self copyInvocation:invocation];
        [invocationCopy invokeWithTarget:self.target];
    }
    
    if ([self.originalDelegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.originalDelegate];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    id result = [self.originalDelegate methodSignatureForSelector:sel];
    if (!result) {
        result = [self.target methodSignatureForSelector:sel];
    }
    
    return result;
}

#pragma mark - nsobject

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"keyboardInputChangedSelection:"])    //这个选择器要无限递归，估计内部实现又是一个respondsToSelector，直接扔出去
        return NO;
    
    return [self.originalDelegate respondsToSelector:aSelector] || [self.target respondsToSelector:aSelector];
}

#pragma mark - private methods

- (NSInvocation *)copyInvocation:(NSInvocation *)invocation {
    //某些控件的private api 在这里会 EXC_BAD_INSTRUCTION，无解
    
    NSInvocation *copy = [NSInvocation invocationWithMethodSignature:[invocation methodSignature]];
    NSUInteger argCount = [[invocation methodSignature] numberOfArguments];
    
    for (int i = 0; i < argCount; i++) {
        char buffer[sizeof(intmax_t)];
        [invocation getArgument:(void *) &buffer atIndex:i];
        [copy setArgument:(void *) &buffer atIndex:i];
    }
    
    return copy;
}

@end
