//
// Created by Siegrain on 16/12/18.
// Copyright (c) 2016 com.siegrain. All rights reserved.
//

#import "SettingTableViewController.h"
#import "MRTodoDataManager.h"
#import "SGTextEditorViewController.h"
#import "SettingModel.h"
#import "SettingTableViewCell.h"
#import "SGSectionHeader.h"
#import "UITableView+Extension.h"
#import "DateUtil.h"
#import "LCUserDataManager.h"
#import "RTRootNavigationController.h"
#import "SCLAlertView.h"
#import "AboutViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

typedef NS_ENUM(NSInteger, SGSettingSection) {
    SGSettingSectionUser,
    SGSettingSectionSync,
//    SGSettingSectionNotification, //TODO: 这个可能要在云引擎上部署自己的repo，然后用node.js的nodemailer来定时发送邮件，先不搞了
            SGSettingSectionApplication
};

typedef NS_ENUM(NSInteger, SGSettingUser) {
    SGSettingUserAccount,
    SGSettingUserName,
    SGSettingUserChangePassword,
    SGSettingUserSignOut
};

typedef NS_ENUM(NSInteger, SGSettingSync) {
    SGSettingSyncAuto,
    SGSettingSyncTime
};

typedef NS_ENUM(NSInteger, SGSettingNotification) {
    SGSettingNotificationAuto
};

typedef NS_ENUM(NSInteger, SGSettingApplication) {
    SGSettingApplicationAbout,
    SGSettingApplicationFeedback,
    SGSettingApplicationClearCache
};

@interface SettingTableViewController () <MFMailComposeViewControllerDelegate>
@property(nonatomic, strong) CDUser *user;

@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, copy) NSArray<NSArray<SettingModel *> *> *dataArray;

@property(nonatomic, strong) LCUserDataManager *dataManager;
@property(nonatomic, strong) SGTextEditorViewController *editorViewController;
@end

@implementation SettingTableViewController

#pragma mark - initial

- (void)viewDidLoad {
    _editorViewController = [SGTextEditorViewController new];
    _dataManager = [LCUserDataManager new];
    _user = [AppDelegate globalDelegate].cdUser;
    
    _titleArray = @[Localized(@"ACCOUNT"), Localized(@"SYNC"), Localized(@"EXTRAS")];
    _dataArray = @[
            @[
                    [SettingModel modelWithIconName:@"sys_account" title:Localized(@"Account") content:_user.email style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_name" title:Localized(@"Name") content:_user.name style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_password" title:Localized(@"Change Password") content:nil style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_signout" title:Localized(@"Sign Out") content:nil style:SettingCellStyleNone isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:@"sys_sync" title:Localized(@"Enable auto sync") content:nil style:SettingCellStyleSwitch isOn:_user.enableAutoSync ? _user.enableAutoSync.boolValue : NO],
                    [SettingModel modelWithIconName:@"sys_synctime" title:Localized(@"Last sync time") content:_user.lastSyncTime ? [DateUtil dateString:_user.lastSyncTime withFormat:@"yyyy-MM-dd HH:mm"] : @"No record" style:SettingCellStyleNone isOn:NO],
            ],
            @[
                    [SettingModel modelWithIconName:@"sys_info" title:Localized(@"About") content:nil style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_feedback" title:Localized(@"Feedback") content:nil style:SettingCellStyleNavigator isOn:NO],
                    [SettingModel modelWithIconName:@"sys_clean" title:Localized(@"Clear Cache") content:[NSString stringWithFormat:@"%.02f MB",[SGHelper folderSizeAtPath:[SGHelper photoPath]]] style:SettingCellStyleNone isOn:NO],
            ]
    ];
    
    [super viewDidLoad];
}

- (void)setupViews {
    [super setupViews];
    
    [self setSeparatorInsetWithTableView:self.tableView inset:UIEdgeInsetsMake(0, kScreenWidth * kSpacingRatioToWidth * 2 + kIconSize, 0, kScreenWidth * kSpacingRatioToWidth)];
    self.tableView.sectionHeaderHeight = 20;
    self.tableView.sectionFooterHeight = 20;
    
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNavigator).stringValue];
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleNone).stringValue];
    [self.tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:@(SettingCellStyleSwitch).stringValue];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray[section].count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SGSectionHeader *header = [SGSectionHeader new];
    header.text = _titleArray[section];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    if (!model.rowHeight) model.rowHeight = [self.tableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SettingTableViewCell class] contentViewWidth:kScreenWidth];
    return model.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifierAtIndexPath:indexPath] forIndexPath:indexPath];
    
    __block SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    cell.model = model;
    
    __weak __typeof(self) weakSelf = self;
    [cell setSwitchDidChange:^(BOOL value) {
        if (indexPath.section == SGSettingSectionSync && indexPath.row == SGSettingSyncAuto) {
            weakSelf.user.enableAutoSync = @(value);
        }
        //遗留配置代码
//        else if (indexPath.section == SGSettingSectionNotification && indexPath.row == SGSettingNotificationAuto) {
//            weakSelf.user.enableAutoReminder = @(value);
//        }
        
        model.isOn = value;
        [weakSelf saveConfig];
    }];
    return cell;
}

- (SettingModel *)modelAtIndexPath:(NSIndexPath *)indexPath {
    return _dataArray[indexPath.section][indexPath.row];
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    return @(_dataArray[indexPath.section][indexPath.row].style).stringValue;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block SettingModel *model = (SettingModel *) [self modelAtIndexPath:indexPath];
    __block LCUser *user = [AppDelegate globalDelegate].lcUser;
    
    _editorViewController.title = model.title;
    _editorViewController.value = model.content;
    __weak __typeof(self) weakSelf = self;
    if (indexPath.section == SGSettingSectionUser && indexPath.row == SGSettingUserAccount) {
        [_editorViewController setEditorDidSave:^(NSString *value) {
            user.username = value;
            user.email = value;
            [weakSelf.dataManager modifyWithUser:user complete:^(bool succeed) {
                if (!succeed) return;
                [SGHelper errorAlertWithMessage:Localized(@"Account information has changed, please log in again")];
                [[AppDelegate globalDelegate] logOut];
            }];
        }];
        [self showEditor];
    } else if (indexPath.section == SGSettingSectionUser && indexPath.row == SGSettingUserName) {
        [_editorViewController setEditorDidSave:^(NSString *value) {
            user.name = value;
            [weakSelf.dataManager modifyWithUser:user complete:^(bool succeed) {
                if (!succeed) return;
                model.content = value;
                [weakSelf reloadData];
            }];
        }];
        [self showEditor];
    } else if (indexPath.section == SGSettingSectionUser && indexPath.row == SGSettingUserChangePassword) {
        NSError *error = nil;
        [LCUser requestPasswordResetForEmail:user.email error:&error];
        if (error) {
            [SGHelper errorAlertWithMessage:error.localizedDescription];
            return;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showInfo:Localized(@"Change Password") subTitle:Localized(@"We'll send you an email with a link to reset your password.") closeButtonTitle:Localized(@"Close") duration:0];
    } else if (indexPath.section == SGSettingSectionUser && indexPath.row == SGSettingUserSignOut) {
        SCLAlertView *confirm = [[SCLAlertView alloc] initWithNewWindow];
        [confirm addButton:@"Sign Out" actionBlock:^{
            [[AppDelegate globalDelegate] logOut];
        }];
        [confirm showWarning:Localized(@"Are you sure?") subTitle:nil closeButtonTitle:Localized(@"Cancel") duration:0];
    } else if (indexPath.section == SGSettingSectionApplication && indexPath.row == SGSettingApplicationAbout) {
        AboutViewController *viewController = [AboutViewController new];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.section == SGSettingSectionApplication && indexPath.row == SGSettingApplicationFeedback) {
        if (![MFMailComposeViewController canSendMail]) return;
        MFMailComposeViewController *viewController = [MFMailComposeViewController new];
        [viewController setSubject:Localized(@"TO-DO feedback")];
        NSString *content = [NSString stringWithFormat:@"\n\n\n[%@]:%@ + iOS %@", Localized(@"Running environment"), [SGHelper phoneModel], @(iOSVersion)];
        [viewController setMessageBody:content isHTML:NO];
        [viewController setToRecipients:@[@"siegrain@qq.com"]];
        viewController.mailComposeDelegate = self;
        [self presentViewController:viewController animated:YES completion:nil];
    } else if (indexPath.section == SGSettingSectionApplication && indexPath.row == SGSettingApplicationClearCache) {
        SCLAlertView *confirm = [[SCLAlertView alloc] initWithNewWindow];
        [confirm addButton:Localized(@"Yes") actionBlock:^{
            [SGHelper clearCache:[SGHelper photoPath]];
            model.content = [NSString stringWithFormat:@"%.02f MB",[SGHelper folderSizeAtPath:[SGHelper photoPath]]];
            [weakSelf reloadData];
            [[AppDelegate globalDelegate] clearStateHolder];
        }];
        [confirm showWarning:Localized(@"Are you sure?") subTitle:Localized(@"The cache may contain photos you aren't synchronized") closeButtonTitle:Localized(@"Cancel") duration:0];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultCancelled) {
        NSLog(@"取消发送");
    } else if (result == MFMailComposeResultSent) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showSuccess:Localized(@"Thank you") subTitle:Localized(@"Greatly appreciate your feedback, we will use it to evaluate changes and make improvements in this app.") closeButtonTitle:Localized(@"Close") duration:0];
    } else {
        
    }
}

#pragma mark - private methods

- (void)saveConfig {
    MR_saveAndWait();
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)showEditor {
    RTRootNavigationController *rootNavigationController = [[RTRootNavigationController alloc] initWithRootViewController:_editorViewController];
    [self presentViewController:rootNavigationController animated:YES completion:nil];
}

@end