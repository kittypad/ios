//
//  SettingView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "SettingView.h"
#import "SettingCell.h"
#import "AppsView.h"
@interface SettingView ()

@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) SettingCell *lastSelectCell;

@property BOOL stopClick;

@end


static NSString *SettingViewCellId = @"SettingCell";

@implementation SettingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self setBackgroundColor:[UIColor colorWithHex:@"F3F8FE"]];
        
        // Initialization code
        UIButton *settingButton = [ViewUtils buttonWWithNormalImage:@"设置-默认.png" hiliteImage:@"设置.png" target:self selector:@selector(settingBUttonClicked:)];
        [settingButton addTarget:self action:@selector(settingBUttonClicked:) forControlEvents:UIControlEventTouchDragInside];
        settingButton.center = CGPointMake(CGRectGetWidth(settingButton.frame)/2, CGRectGetHeight(settingButton.frame));
        [self addSubview:settingButton];
        self.settingButton = settingButton;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(settingButton.frame), 0, CGRectGetWidth(frame) - CGRectGetWidth(settingButton.frame), CGRectGetHeight(frame))
                                                              style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 45;
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = [UIColor colorWithHex:@"F3F8FE"];
        tableView.separatorColor = [UIColor clearColor];
        [tableView registerClass:[SettingCell class] forCellReuseIdentifier:SettingViewCellId];
        tableView.layer.borderWidth = 0.5;
        UIColor *color = [UIColor colorWithHex:@"ffffff"];
        tableView.layer.borderColor = color.CGColor;
        [self addSubview:tableView];

        UISwipeGestureRecognizer *pan = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(settingBUttonClicked:)];
        pan.direction = UISwipeGestureRecognizerDirectionRight;
        [tableView addGestureRecognizer:pan];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIconClicked:) name:PlayAppsVideoNotification object:nil];
//         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingBUttonClicked:) name:SettingviewClickNotification object:nil];
//         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIconClicked:) name:AppIconClickNotification object:nil];
    }
    return self;
}
-(void)appIconClicked :(NSNotification*)notice
{
        NSString *name = [notice.userInfo objectForKey:@"name"];
        switch ([name integerValue])
        {
            case SettingAppType:
                [self settingBUttonClicked:nil];
                break;
            case PanoramicAppType:
                self.settingActionHandle(0);
                break;
            case ExclusuveAppType:
                self.settingActionHandle(2);
                break;
            case TryAppType:
                self.settingActionHandle(1);
                break;
            default:                
                break;
        }
}

- (void)settingBUttonClicked:(id *)sender
{
    if (self.stopClick){
        return;
    }
    self.stopClick = YES;
    
    __weak typeof(self) weakself = self;
    double delayInSeconds = .5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        weakself.stopClick = NO;
    });
    
    self.settingHasPullOut = !self.settingHasPullOut;
    
    if (self.settingHasPullOut) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            self.frame = CGRectMake(CGRectGetWidth(self.superview.frame) - CGRectGetWidth(self.settingButton.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return IS_IOS7 ? 20 : 0;
    else return 32.5f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 3;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingViewCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithHex:@"292929"];

    UIImageView *color = nil;
    if (indexPath.section == 0) {
        ((SettingCell *)cell).selectionImageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Panoramicview",nil);
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Try",nil);
                break;
            case 2:
//                cell.textLabel.text = @"专属刻字";
                cell.textLabel.text = NSLocalizedString(@"Engraving",nil);
                break;
                
            default:
                break;
        }

    }else if (indexPath.section == 1){
        UIImage *img = [UIImage imageNamed:@"黑.png"];
        color = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        color.center = CGPointMake(61, tableView.rowHeight/2);
        [cell addSubview:color];
        if (indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"Dark", nil);
            color.image = img;
        }else if(indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"Red", nil);
            color.image = [UIImage imageNamed:@"红.png"];
        }else if(indexPath.row == 2){
            cell.textLabel.text = NSLocalizedString(@"Blue", nil);
            color.image = [UIImage imageNamed:@"蓝.png"];
        }
        
        NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
        if (style == indexPath.row) {
            ((SettingCell *)cell).isSelected = YES;
            self.lastSelectCell = (SettingCell *)cell;
        }
    }
    else if (indexPath.section == 2){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ((SettingCell *)cell).selectionImageView.image = nil;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Accounts", nil);
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Settings", nil);
                break;
            default:
                break;
        }    }
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, tableView.rowHeight - .5, CGRectGetWidth(tableView.frame) - 15, .5)];
    line.backgroundColor = [UIColor colorWithHex:@"e2e1e4"];
    [cell addSubview:line];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"Color", nil);
    }else return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            self.settingActionHandle(indexPath.row);
            break;
        case 1:
        {
            SettingCell *cell = (SettingCell *)[tableView cellForRowAtIndexPath:indexPath];
            self.lastSelectCell.isSelected = NO;
            self.lastSelectCell = cell;
            cell.isSelected = !cell.isSelected;
            
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:WatchStyleStatus];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WatchStyleStatusChangeNotification object:nil];
        }
            break;
        default:
            break;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
