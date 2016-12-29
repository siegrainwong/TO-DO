//
// Created by Siegrain on 16/12/29.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//


#import "LCUserDataManager.h"
#import "AVUser.h"
#import "LCUser.h"
#import "SGSyncManager.h"
#import "AppDelegate.h"
#import "UIImage+Extension.h"
#import <XCTest/XCTest.h>

@interface RegisterTests : XCTestCase
@property(nonatomic, strong) LCUserDataManager *dataManager;
@property(nonatomic, strong) LCUser *user;

@property(nonatomic, strong) NSString *unitName;

@end


@implementation RegisterTests

#pragma mark - tests

- (void)testAvatar {
    self.unitName = @"Avatar";
    
    self.user.avatarImage = nil;
    XCTAssertFalse([self validate], @"%@ is %@ but succeed", self.unitName, self.user.avatarImage);
    [self resetUser];
}

- (void)testName {
    self.unitName = @"Name";
    
    self.user.name = nil;
    XCTAssertFalse([self validate], @"%@ is %@ but succeed", self.unitName, self.user.name);
    [self resetUser];
    
    self.user.name = @"aaa";
    XCTAssertFalse([self validate], @"%@ should longer than %@ but succeed", self.unitName, self.user.name);
    [self resetUser];
    
    self.user.name = @"我";
    XCTAssertFalse([self validate], @"%@ should longer than %@ but succeed", self.unitName, self.user.name);
    [self resetUser];
    
    self.user.name = @"themaxlengthofnameis20";
    XCTAssertFalse([self validate], @"%@ should shorter than %@ but succeed", self.unitName, self.user.name);
    [self resetUser];
    
    self.user.name = @"名称的最大长度应该不超";
    XCTAssertFalse([self validate], @"%@ should shorter than %@ but succeed", self.unitName, self.user.name);
    [self resetUser];
    
    self.user.name = @"@#%*@#$%-";
    XCTAssertFalse([self validate], @"%@ should'nt have %@ but succeed", self.unitName, self.user.name);
    [self resetUser];
}

- (void)testEmail {
    self.unitName = @"Email";
    
    self.user.email = nil;
    XCTAssertFalse([self validate], @"%@ is %@ but succeed", self.unitName, self.user.email);
    [self resetUser];
    
    self.user.email = @"thisisnotaemail";
    XCTAssertFalse([self validate], @"%@ is not a valid format but succeed", self.user.email);
    [self resetUser];
}

- (void)testPassword {
    self.unitName = @"Password";
    
    self.user.password = nil;
    XCTAssertFalse([self validate], @"%@ is %@ but succeed", self.unitName, self.user.password);
    [self resetUser];
    
    self.user.password = @"aaaaa";
    XCTAssertFalse([self validate], @"%@ should longer than %@ but succeed", self.unitName, self.user.password);
    [self resetUser];
    
    self.user.password = @"maxlengthofpasswordisthirty3031";
    XCTAssertFalse([self validate], @"%@ should shorter than %@ but succeed", self.unitName, self.user.password);
    [self resetUser];
}

- (void)testRegisterAndSync {
    self.unitName = @"Register";
    __weak __typeof(self) weakSelf = self;
    
    [self resetUser];
    NSLog(@"%@", [self.user dictionaryForObject]);
    
    __block BOOL registerResult;
    [self registerWithComplete:^(bool succeed, NSString *errorMessage) {
        XCTAssertTrue(succeed, @"%@ failed because of : %@", weakSelf.unitName, errorMessage);
        registerResult = succeed;
    }];
    
    if (registerResult) {
        [self syncWithComplete:^(BOOL succeed) {
            XCTAssertTrue(succeed, @"Sync after %@ failed, please read log", self.unitName);
        }];
    }
}

#pragma mark - test helper

- (void)registerWithComplete:(SGUserResponse)complete {
    XCTestExpectation *expectation = [self expectationWithDescription:@"register time out?"];
    [_dataManager commitWithUser:self.user isSignUp:YES complete:^(bool succeed, NSString *errorMessage) {
        complete(succeed, errorMessage);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {}];
}

- (void)syncWithComplete:(CompleteBlock)complete {
    XCTestExpectation *expectation = [self expectationWithDescription:@"sync time out?"];
    [[AppDelegate globalDelegate] setupUser];
    [[SGSyncManager sharedInstance] synchronize:SyncModeAutomatically complete:^(BOOL succeed) {
        complete(succeed);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {}];
}


- (BOOL)validate {
    return [_dataManager validateWithUser:self.user isModify:NO];
}

- (void)resetUser {
    CGFloat random = arc4random() % 99999 + 1;
    NSString *name = [NSString stringWithFormat:@"sgtest%@", @(random)];
    
    self.user = [LCUser object];
    self.user.name = name;
    self.user.avatarImage = [UIImage imageAtResourcePath:@"avatar1"];
    self.user.email = [NSString stringWithFormat:@"%@@qq.com", name];
    self.user.username = self.user.email;
    self.user.password = @"testuser";
}

#pragma mark - life cycle

- (void)setUp {
    [super setUp];
    self.dataManager = [LCUserDataManager new];
    self.dataManager.isSignUp = YES;
    
    [self resetUser];
}

- (void)tearDown {
    [super tearDown];
}
@end