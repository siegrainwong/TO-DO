//
//  SGSearchBar.m
//  GamePlatform
//
//  Created by Siegrain on 16/8/15.
//  Copyright © 2016年 com.lurenwang.gameplatform. All rights reserved.
//

#import "SGSearchBar.h"
#import "UIImage+Extension.h"
#import "UISearchBar+Additions.h"

@implementation SGSearchBar
+ (instancetype)searchBar
{
    SGSearchBar* searchBar = [SGSearchBar new];
    searchBar.backgroundColor = [SGHelper themeColorRed];
    searchBar.backgroundImage = [UIImage imageWithColor:[SGHelper themeColorRed]];
    searchBar.placeholder = @"搜索";
    searchBar.tintColor = [UIColor blackColor];
    [searchBar setBarBackgroundColor:[UIColor whiteColor]];
    [searchBar setTextColor:[UIColor blackColor]];
    [searchBar sizeToFit];

    return searchBar;
}

@end
