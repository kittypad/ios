//
//  AppsView.m
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "AppsView.h"

@implementation AppsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        
        UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 50.0, 30.0)];
        [settingButton setTitle:@"设置" forState:UIControlStateNormal];
        [settingButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        settingButton.tag = SettingAppType;
        [self addSubview:settingButton];
    }
    return self;
}

- (void)playVideo:(id)sender
{
    NSLog(@"haha");
    NSString *name = nil;
    NSString *type = nil;
    switch ([sender tag]) {
        case SettingAppType: {
//            name = @"naruto554";
//            type = @"mp4";
            break;
        }
        default:
            break;
    }
    if (name && type) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayAppsVideoNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", type, @"type", nil]];
    }
}

@end
