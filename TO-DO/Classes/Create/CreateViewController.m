//
//  CreateViewController.m
//  TO-DO
//
//  Created by Siegrain on 16/5/19.
//  Copyright © 2016年 com.siegrain. All rights reserved.
//

#import "CreateViewController.h"
#import "Macros.h"
#import "UIImage+Extension.h"

@implementation CreateViewController {
    UITextField* titleTextField;
}
#pragma mark - localization
- (void)localizeStrings
{
    [self setMenuTitle:NSLocalizedString(@"LABEL_CREATENEW", nil)];
}
#pragma mark - initial
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self localizeStrings];
}
- (void)setupView
{
    [super setupView];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    headerView = [HeaderView headerViewWithAvatarPosition:HeaderAvatarPositionCenter titleAlignement:HeaderTitleAlignementCenter];
    headerView.backgroundImageView.image = [UIImage imageAtResourcePath:@"create header bg"];
    headerView.avatarButton.hidden = YES;
    headerView.rightOperationButton.hidden = YES;

    [self.view addSubview:headerView];
}
- (void)bindConstraints
{
    [super bindConstraints];

    [headerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.left.offset(0);
        make.width.offset(kScreenWidth);
        make.height.offset(kScreenHeight * 0.35);
    }];
}
@end
