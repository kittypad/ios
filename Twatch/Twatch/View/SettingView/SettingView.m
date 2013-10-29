//
//  SettingView.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-29.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "SettingView.h"
#import "SettingCell.h"

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
        // Initialization code
        UIButton *settingButton = [FactoryMethods buttonWWithNormalImage:@"设置-默认.png" hiliteImage:@"设置.png" target:self selector:@selector(settingBUttonClicked:)];
        [settingButton addTarget:self action:@selector(settingBUttonClicked:) forControlEvents:UIControlEventTouchDragInside];
        settingButton.center = CGPointMake(CGRectGetWidth(settingButton.frame)/2, CGRectGetHeight(settingButton.frame));
        [self addSubview:settingButton];
        self.settingButton = settingButton;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(settingButton.frame), 0, CGRectGetWidth(frame) - CGRectGetWidth(settingButton.frame), CGRectGetHeight(frame))
                                                              style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 45;
        tableView.backgroundColor = RGB(243, 248, 254, 1);
        tableView.separatorColor = [UIColor clearColor];
        [tableView registerClass:[SettingCell class] forCellReuseIdentifier:SettingViewCellId];
        [self addSubview:tableView];

        UISwipeGestureRecognizer *pan = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(settingBUttonClicked:)];
        pan.direction = UISwipeGestureRecognizerDirectionRight;
        [tableView addGestureRecognizer:pan];
    }
    return self;
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
    else return 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 3;
    }else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingViewCellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];

    UIImageView *color = nil;
    if (indexPath.section == 1) {
        ((SettingCell *)cell).isSelected = YES;
        cell.textLabel.text = @"240 * 320";
    }else if (indexPath.section == 2){
        UIImage *img = [UIImage imageNamed:@"黑.png"];
        color = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        color.center = CGPointMake(61, tableView.rowHeight/2);
        [cell addSubview:color];
        if (indexPath.row == 0){
            cell.textLabel.text = @"暗黑";
            color.image = img;
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"嫣红";
            color.image = [UIImage imageNamed:@"红.png"];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"湛蓝";
            color.image = [UIImage imageNamed:@"蓝.png"];
        }
        
        NSInteger style = [[NSUserDefaults standardUserDefaults] integerForKey:WatchStyleStatus];
        if (style == indexPath.row) {
            ((SettingCell *)cell).isSelected = YES;
            self.lastSelectCell = (SettingCell *)cell;
        }
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, tableView.rowHeight - .5, CGRectGetWidth(tableView.frame) - 15, .5)];
    line.backgroundColor = RGB(239, 239, 239, 1);
    [cell addSubview:line];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"屏幕尺寸";
    }else if (section == 2){
        return @"外壳颜色";
    }else return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) return;
    
    SettingCell *cell = (SettingCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 2) {
        self.lastSelectCell.isSelected = NO;
        self.lastSelectCell = cell;
    }
    
    cell.isSelected = !cell.isSelected;
    
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:WatchStyleStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WatchStyleStatusChangeNotification object:nil];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


@end
