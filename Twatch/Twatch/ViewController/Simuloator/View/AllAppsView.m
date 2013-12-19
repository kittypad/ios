//
//  AllAppsView.m
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "AllAppsView.h"

@implementation AllAppsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(10.0, 28.0, 105.0, 127.0);
        
//        UIButton *settingButton = [[UIButton alloc] initWithFrame:rect];
//        [settingButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
//        [settingButton setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
//        settingButton.tag = SettingAppType;
//        [self addSubview:settingButton];
//        rect.origin.x += rect.size.width+10.0;
        
        UIButton *musicButton = [[UIButton alloc] initWithFrame:rect];
        [musicButton setImage:[UIImage imageNamed:@"360度.png"] forState:UIControlStateNormal];
        [musicButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        musicButton.tag = PanoramicAppType;
        [self addSubview:musicButton];
        rect.origin.x += rect.size.width+10.0;
        
        UIButton *runningButton = [[UIButton alloc] initWithFrame:rect];
        [runningButton setImage:[UIImage imageNamed:@"刻字.png"] forState:UIControlStateNormal];
        [runningButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        runningButton.tag = ExclusuveAppType;
        [self addSubview:runningButton];
        rect.origin.x = 10.0;
        rect.origin.y += rect.size.height+12.0;
        
        UIButton *weatherButton = [[UIButton alloc] initWithFrame:rect];
        [weatherButton setImage:[UIImage imageNamed:@"试戴.png"] forState:UIControlStateNormal];
        [weatherButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        weatherButton.tag = TryAppType;
        [self addSubview:weatherButton];
    }
    return self;
}

@end
