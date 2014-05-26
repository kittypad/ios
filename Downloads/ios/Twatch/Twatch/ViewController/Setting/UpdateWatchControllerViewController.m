//
//  UpdateWatchControllerViewController.m
//  Twatch
//
//  Created by huxiaoxi on 14-2-26.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "UpdateWatchControllerViewController.h"
#import "DataManager.h"
#import "BLEServerManager.h"

@interface UpdateWatchController ()

@end

@implementation UpdateWatchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:@"f2f7fd"];
    // Do any additional setup after loading the view from its nib.
    
    _processView = [[UIProgressView alloc]initWithFrame:CGRectMake(10, IS_IPHONE_5?480:460, 300, 10)];
    [self.view addSubview:_processView];
    
    _processLable = [[UILabel alloc] init];
    [_processLable setFrame:CGRectMake(10, IS_IPHONE_5?450:430 ,100 , 30)];
    [_processLable setTextAlignment:NSTextAlignmentLeft];
    _processLable.backgroundColor = [UIColor clearColor];
    _processLable.text = NSLocalizedString(@"downloading version",nil);
    _processLable.textColor = [UIColor blackColor];
    
    [self.view addSubview:_processLable];
    
    _processPecentLable = [[UILabel alloc] init];
    [_processPecentLable setFrame:CGRectMake(270, IS_IPHONE_5?450:430 ,40 , 30)];
    [_processPecentLable setTextAlignment:NSTextAlignmentLeft];
    _processPecentLable.backgroundColor = [UIColor clearColor];
    _processPecentLable.textColor = [UIColor blackColor];
    [self.view addSubview:_processPecentLable];
    
    _bytesLable = [[UILabel alloc] init];
    [_bytesLable setFrame:CGRectMake(115, IS_IPHONE_5?450:430 ,150 , 30)];
    [_bytesLable setTextAlignment:NSTextAlignmentLeft];
    _bytesLable.backgroundColor = [UIColor clearColor];
    _bytesLable.textColor = [UIColor blackColor];
    [self.view addSubview:_bytesLable];

    
    [_processView setHidden:YES];
    [_processLable setHidden:YES];
    [_processPecentLable setHidden:YES];
    
    [_bytesLable setHidden:YES];
    
    
    
    _product =  [[NSMutableArray alloc] init];
    _versionList = [[NSMutableArray alloc] init];
    _isOneClick = NO;
    _isUpdated = NO;
//    [updateButton release];
    [self loadVersionNetworking];
    
    //获取到版本后的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkVersionNetworking:) name:kCheckWatchVersionNotification object:nil];
    //下载进度条通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadingWatchVersionProcess:) name:kDownloadingWatchVersionProcessNotification object:nil];
    
    

    //从版本地址中获得版本列表以后的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compareVersionList:) name:kcompareWatchVersionListNotification object:nil];
    
    //比对版本列表后，有新版本，下载完新版本后的通知,该通过蓝牙传输版本了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendWatchVersion:) name:kUpdateWatchVersionNotification object:nil];
    
    
    //蓝牙传输版本进度条
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendWatchVersionProcess:) name:kWatchVersionInstallAppNotification object:nil];

    
    
}

//从服务器活动版本列表地址
- (void)loadVersionNetworking;
{
//    void (^arrayBlock)(NSMutableArray *array);
//    arrayBlock = ^(NSMutableArray *array)
//    {
//        NSLog(@"OK");
//    };
    
    [[DataManager sharedManager] getWatchVersionDown:^(NSMutableArray *array){
        [_product addObjectsFromArray:array];
        
    }];
    

    

}



//从服务器版本地址后的通知，从该地址中开始下载版本列表
-(void)checkVersionNetworking:(NSNotification *)notification
{
    for (int i=0; i<[_product count]; i++)
    {
        NSMutableDictionary *tempDic = [_product objectAtIndex:i];
        if([(NSString *)[tempDic objectForKey:@"product"] isEqualToString:@"T-Fire"])
        {
            [[DataManager sharedManager] checkWatchVersionNewDown:[tempDic objectForKey:@"url"] success:^(NSMutableArray *array) {
                [_versionList addObjectsFromArray:array];
            }];
            
        }
        
    }
}


//从服务器获得版本列表的通知，比对服务器版本列表和从表获得的版本号，如果有升级路径，则从服务器下载版本
-(void)compareVersionList: (NSNotification *)notification

{
    NSLog(@"the versionlist is %@",_versionList);

    NSString * currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"watch version"];
    
    
    
    //如果有更新路径，则置isUpdate 为 yes，
    for(NSInteger i = 0; i < [_versionList count]; i++)
    {
        NSDictionary * tempDic = (NSDictionary *)[_versionList objectAtIndex:i];
        if ([currentVersion isEqualToString: [tempDic objectForKey:@"oldVersion"]])
        {
            _updateVersion = [tempDic objectForKey:@"newVersion"];
            _VersionURL = [tempDic objectForKey:@"url"];
            _VersionSize = [tempDic objectForKey:@"size"];
            _description = [tempDic objectForKey:@"description"];
            _isUpdated = YES;
            break;
            
        }
        
    }
  
    
    if(_isUpdated) //如果有新版本，手表需要升级
    {
        [self UpdateViewload:currentVersion];
    }
    else
    {
        UIImageView *updateView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.yOffset, self.view.frame.size.width, IS_IPHONE_5?210:190)];
        [updateView setImage:[UIImage imageNamed:@"update_bg.png"]];
        [self.view addSubview:updateView];
        
        
        
        UILabel * WatchVersioninfo = [[UILabel alloc] init];
        [WatchVersioninfo setFrame:CGRectMake(10,  IS_IPHONE_5?self.yOffset + 179:self.yOffset + 159 ,300 , 20)];
        [WatchVersioninfo setTextAlignment:NSTextAlignmentLeft];
        WatchVersioninfo.backgroundColor = [UIColor clearColor];
        NSString *currenttext = NSLocalizedString(@"current version:",nil);
        WatchVersioninfo.font = [UIFont fontWithName:@"Arial" size:12];
        if(currentVersion != nil)
        {
            WatchVersioninfo.text = [currenttext stringByAppendingString:currentVersion];
        }
        else
        {
            WatchVersioninfo.text = [currenttext stringByAppendingString:@"unknown version"];
        }
        WatchVersioninfo.textColor = [UIColor blackColor];
        
        [self.view addSubview:WatchVersioninfo];
        

        UILabel * informationLatble = [[UILabel alloc] init];
        [informationLatble setFrame:CGRectMake(10, IS_IPHONE_5?self.yOffset + 220:self.yOffset + 200 ,300 , 30)];
        [informationLatble setTextAlignment:NSTextAlignmentLeft];
        informationLatble.backgroundColor = [UIColor clearColor];
        
        informationLatble.text = NSLocalizedString(@"current version is the latest version",nil);
        informationLatble.textColor = [UIColor blackColor];
        
        [self.view addSubview:informationLatble];
    }

    
    
}

//下载版本进度条
-(void)downloadingWatchVersionProcess:(NSNotification *)notification
{
    _isOneClick = YES;//防止用户多次下载，在下载过程中为yes，用户不能再次下载
    NSDictionary *processDic = [notification userInfo];
    CGFloat percent = [[processDic objectForKey:@"readFileBytes"] floatValue]/ [[processDic objectForKey:@"totalFileBytes"] floatValue];
    [_processView setProgress:percent animated:(YES)];
    _processPecentLable.text = [NSString stringWithFormat:@"%d%%", (int)(percent*100) ];// s
    
    if(percent == 1)
    {
        _processLable.text = NSLocalizedString(@"updating version now",nil);
        _processPecentLable.text = [NSString stringWithFormat:@"0%%"];// s
        [_processView setProgress:0];
        [_bytesLable setHidden:NO];
    }
    
}

//版本下载完成后的通知,开始传输
-(void)sendWatchVersion:(NSNotification *)notification
{
    
    [[BLEServerManager sharedManager] sendWatchVersion:[_VersionURL lastPathComponent]];
    
    
    
}

//蓝牙传输进度条
-(void) sendWatchVersionProcess:(NSNotification *)notification
{
    _processLable.text = NSLocalizedString(@"updating version now",nil);
    
    NSDictionary *processDic = [notification userInfo];
    CGFloat percent = [[processDic objectForKey:@"readFileBytes"] floatValue]/ [[processDic objectForKey:@"totalFileBytes"] floatValue];
    [_processView setProgress:percent animated:(YES)];
    
    _bytesLable.text = [NSString stringWithFormat:@"%@bytes",[processDic objectForKey:@"readFileBytes"]];
    
    _processPecentLable.text = [NSString stringWithFormat:@"%d%%", (int)(percent*100) ];// s

    
    if(percent == 1)
    {
        _isOneClick = NO;//设置为NO表示可以再次下载传输版本
        [_processView setHidden:YES];
        [_processLable setHidden:YES];
        [_processPecentLable setHidden:YES];
        [_bytesLable setHidden:YES];
    }
}

-(void)actionForUpdateButton
{
    [_processView setHidden:NO];
    [_processLable setHidden:NO];
    [_processPecentLable setHidden:NO];
    //下载按钮只能按一次,下载安装过程中不能再次下载
    if (_isOneClick == NO)
    {

        if(_isUpdated)
        {
            NSString * path = [[AFDownloadRequestOperation cacheFolder] stringByAppendingPathComponent:[_VersionURL lastPathComponent]];
            NSFileManager *manager = [[NSFileManager alloc] init];
            //如果文件已经存在，不需要下载，
            if ([manager fileExistsAtPath:path isDirectory:NO]) {
                _processLable.text = NSLocalizedString(@"updating version now",nil);
                _processPecentLable.text = [NSString stringWithFormat:@"0%%"];// s
                [_processView setProgress:0];
                [_bytesLable setHidden:NO];
                [[BLEServerManager sharedManager] sendWatchVersion:[_VersionURL lastPathComponent]];
            }
            else//否则，下载版本
            {

                [[DataManager sharedManager]  downLoadWatchVersion:_VersionURL];
            }
            
        }
    }
}



-(void) UpdateViewload:(NSString *)currentVersion
{
    _updateInfoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.yOffset, self.view.frame.size.width, IS_IPHONE_5?210:190)];
    [_updateInfoView setImage:[UIImage imageNamed:@"updateinfo_bg.png"]];
    [self.view addSubview:_updateInfoView];
    
    _updateInfoText = [[UITextView alloc]initWithFrame:CGRectMake(0, IS_IPHONE_5?self.yOffset + 210:self.yOffset + 190 , self.view.frame.size.width, 100)];
    _updateInfoText.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"information_bg.png"]];
    _updateInfoText.editable = NO;
    _updateInfoText.selectable = NO;
    _updateInfoText.text = _description;
    [self.view addSubview:_updateInfoText];
    
    
    UILabel * WatchVersioninfo = [[UILabel alloc] init];
    [WatchVersioninfo setFrame:CGRectMake(10,  IS_IPHONE_5?self.yOffset + 158:self.yOffset + 138 ,300 , 20)];
    [WatchVersioninfo setTextAlignment:NSTextAlignmentLeft];
    WatchVersioninfo.backgroundColor = [UIColor clearColor];
    NSString *currenttext = NSLocalizedString(@"current version:",nil);
    
    if(currentVersion != nil)
    {
        WatchVersioninfo.text = [currenttext stringByAppendingString:currentVersion];
    }
    else
    {
        WatchVersioninfo.text = NSLocalizedString(@"unknow version",nil);
    }
    WatchVersioninfo.font = [UIFont fontWithName:@"Arial" size:12];
    WatchVersioninfo.textColor = [UIColor whiteColor];
    
    [self.view addSubview:WatchVersioninfo];
    
    
    UILabel * updatedVersionInfo = [[UILabel alloc] init];
    [updatedVersionInfo setFrame:CGRectMake(10, IS_IPHONE_5?self.yOffset + 179:self.yOffset + 159 ,300 , 30)];
    [updatedVersionInfo setTextAlignment:NSTextAlignmentLeft];
    updatedVersionInfo.backgroundColor = [UIColor clearColor];
    NSString *text = NSLocalizedString(@"new version:",nil);
    updatedVersionInfo.font = [UIFont fontWithName:@"Arial" size:12];
    
    if(_updateVersion)
    {
        updatedVersionInfo.text = [text stringByAppendingString:_updateVersion];
    }
    updatedVersionInfo.textColor = [UIColor whiteColor];
    
    [self.view addSubview:updatedVersionInfo];
    
    
    UILabel * clictToUpdate = [[UILabel alloc] init];
    [clictToUpdate setFrame:CGRectMake(30, IS_IPHONE_5?self.yOffset + 320:self.yOffset + 300 ,160 , 30)];
    [clictToUpdate setTextAlignment:NSTextAlignmentLeft];
    clictToUpdate.backgroundColor = [UIColor clearColor];
    clictToUpdate.text  = NSLocalizedString(@"click to update",nil);
    clictToUpdate.textColor = [UIColor blackColor];
    [self.view addSubview:clictToUpdate];
    
    _updateButton = [[UIButton alloc]initWithFrame:CGRectMake(170, IS_IPHONE_5?self.yOffset + 320:self.yOffset + 300 ,50 , 50)];
    [_updateButton addTarget:self action:@selector(actionForUpdateButton) forControlEvents:UIControlEventTouchUpInside];
    //    [_updateButton setBackgroundColor:[UIColor redColor]];
    [_updateButton setBackgroundImage:[UIImage imageNamed:@"update_button.png"] forState:(UIControlStateNormal)];
    [self.view addSubview:_updateButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _isOneClick = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
