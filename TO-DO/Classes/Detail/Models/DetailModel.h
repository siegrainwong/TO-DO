//
// Created by Siegrain on 16/11/24.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "MJExtension.h"
#import "SGCoordinate.h"
#import "SGCellViewModel.h"

@interface DetailModel : SGCellViewModel
@property(nonatomic, strong) NSString *iconName;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) SGCoordinate *location;
@property(nonatomic, strong) NSString *photoUrl;
@property(nonatomic, strong) NSString *photoPath;
@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) NSString *identifier;

#pragma mark -

- (BOOL)hasPhoto;

#pragma mark - initializers

- (instancetype)initWithIconName:(NSString *)iconName content:(NSString *)content location:(SGCoordinate *)location photoUrl:(NSString *)photoUrl photoPath:(NSString *)photoPath placeholder:(NSString *)placeholder identifier:(NSString *)identifier cellStyle:(NSInteger)cellStyle;

+ (instancetype)modelWithIconName:(NSString *)iconName content:(NSString *)content location:(SGCoordinate *)location photoUrl:(NSString *)photoUrl photoPath:(NSString *)photoPath placeholder:(NSString *)placeholder identifier:(NSString *)identifier cellStyle:(NSInteger)cellStyle;
@end