//
//  NewFriendViewController.h
//  Twatch
//
//  Created by yugong on 14-7-2.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

@interface NewFriendViewController : NaviCommonViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong) NSArray* addFriendList;

@end
