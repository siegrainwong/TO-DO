//
//  JVDrawerTableViewCell.h
//  JVFloatingDrawer
//
//  Created by Julian Villella on 2015-01-15.
//  Copyright (c) 2015 JVillella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerTableViewCell : UITableViewCell

+ (CGFloat)leftSpaceFromView;

- (void)setTitle:(NSString*)title;
- (void)setIcon:(UIImage*)icon;

@end
