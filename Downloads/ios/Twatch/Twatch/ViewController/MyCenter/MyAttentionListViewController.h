//
//  MyAttentionListViewController.h
//  Twatch
//
//  Created by yugong on 14-6-16.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "NaviCommonViewController.h"

@interface MyAttentionListViewController : NaviCommonViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong)NSMutableArray* friendarray;
@property (nonatomic, strong)NSMutableDictionary* myDic;

@end
