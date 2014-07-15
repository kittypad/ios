//
//  MyCenterManagerViewController.h
//  Twatch
//
//  Created by yugong on 14-6-4.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

@interface MyCenterManagerViewController : NaviCommonViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSMutableDictionary* myMessageDic;
@property (nonatomic) NSString* userNametext;

@end
