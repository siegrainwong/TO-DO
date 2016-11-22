//
// Created by Siegrain on 16/11/22.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SGMultipleDelegates.h"

@interface SGMultipleDelegates ()
@property(nonatomic, strong) NSHashTable *delegates;
@end

@implementation SGMultipleDelegates
- (id)init {
    if(self = [super init])
    _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    return self;
}

- (void)addDelegate:(id)delegate {
    [_delegates addObject:delegate];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    for (id delegate in _delegates) {
        [invocation invokeWithTarget:delegate];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *our = [super methodSignatureForSelector:selector];
    NSMethodSignature *delegated = [(NSObject *) [_delegates anyObject] methodSignatureForSelector:selector];
    return our ? our : delegated;
}

- (BOOL)respondsToSelector:(SEL)selector {
    return [[_delegates anyObject] respondsToSelector:selector];
}
@end