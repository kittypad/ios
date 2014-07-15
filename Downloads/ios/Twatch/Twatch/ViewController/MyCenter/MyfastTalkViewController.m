 //
//  MyfastTalkViewController.m
//  Twatch
//
//  Created by yugong on 14-6-16.
//  Copyright (c) 2014年 龚涛. All rights reserved.
//

#import "MyfastTalkViewController.h"

#import "MLAudioRecorder.h"
#import "CafRecordWriter.h"
#import "AmrRecordWriter.h"
#import <AVFoundation/AVFoundation.h>
#import "MLAudioMeterObserver.h"
#import "ChartMessage.h"
#import "ChartCellFrame.h"
#import "ChartCell.h"
#import "KeyBordVIew.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NSString+DocumentPath.h"
#import "VoiceConverter.h"
#import "NetDataManager.h"


@interface MyfastTalkViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,KeyBordVIewDelegate,ChartCellDelegate,AVAudioPlayerDelegate>
{
    NSString* strAmrFileName;
    NSString* plistfilepath;
    NSString* newMessageTime;
    NSMutableArray* addNewMessageFromFriend;
    NSTimer *peakTimer;
    NSTimeInterval _timeLen;
}

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic,strong) AVAudioRecorder *recorder;

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) KeyBordVIew *keyBordView;
@property (nonatomic,strong) NSMutableArray *cellFrames;
@property (nonatomic,assign) BOOL recording;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *content;

@end

static NSString *const cellIdentifier=@"QQChart";

@implementation MyfastTalkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatespeechRecords:) name:@"updatespeechRecords" object:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)updatespeechRecords:(NSNotification*)note
{
    addNewMessageFromFriend = [note.object objectForKey:[self.friendNameDic objectForKey:@"focusUserName"]];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //plist文件名字
    NSString* plistfileName = [NSString stringWithFormat:@"%@.plist",[self.friendNameDic objectForKey:@"focusUserName"]];
    plistfilepath = [documentsPath stringByAppendingPathComponent:plistfileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:plistfilepath];
    if (!fileExists) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        //找到Documents文件所在的路径
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //取得第一个Documents文件夹的路径
        NSString *filePath = [path objectAtIndex:0];
        
        //把Plist文件加入
        NSString *plistPath = [filePath stringByAppendingPathComponent:plistfileName];
        
        //开始创建文件
        [fm createFileAtPath:plistPath contents:nil attributes:nil];
    }
    
    //发送信息暂时存入plist
    NSMutableArray *data=[NSArray arrayWithContentsOfFile:plistfilepath];
    
    if (data == nil) {
        data = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<[addNewMessageFromFriend count]; i++) {
        NSMutableDictionary* addNewMessageDic = [addNewMessageFromFriend objectAtIndex:i];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[addNewMessageDic objectForKey:@"time"] forKey:@"time"];
        [dict setObject:[addNewMessageDic objectForKey:@"content"] forKey:@"content"];
        [dict setObject:@"0" forKey:@"type"];
        [dict setObject:[addNewMessageDic objectForKey:@"fromUser"] forKey:@"userName"];
        if ([[addNewMessageDic objectForKey:@"content"] isEqualToString:@""]) {
            [dict setObject:@"1" forKey:@"contenttype"];
            NSString* strfileName = [addNewMessageDic objectForKey:@"voice"];
            NSURL *voiceURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.yugong-tech.com/download_voice_wt?voice_file=%@",strfileName]];
            NSData *voiceData = [NSData dataWithContentsOfURL:voiceURL];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:strfileName];
            if ([fileManager fileExistsAtPath:applicationDocumentsDir])
                NSLog(@"applicationDocumentsDir exists");   // verifies directory exist


            if (voiceData) {
                NSString *content = [[NSString alloc]  initWithBytes:[voiceData bytes]
                                                              length:[voiceData length] encoding: NSUTF8StringEncoding];

                NSLog(@"%@", content); // verifies data was downloaded correctly

                NSError* error;
                [voiceData writeToFile:storePath options:NSDataWritingAtomic error:&error];
                
                if(error != nil)
                    NSLog(@"write error %@", error);
            }
            
 
            NSArray *array = [strfileName componentsSeparatedByString:@"."];
            NSString* strAmrToWAvFileName = [NSString stringWithFormat:@"%@.wav",[array objectAtIndex:0]];
            [dict setObject:[addNewMessageDic objectForKey:@"avatar"] forKey:@"icon"];
            [dict setObject:strAmrToWAvFileName forKey:@"content"];
            
            NSString* wavfilepath = [NSString documentPathWith: strAmrToWAvFileName];
            [VoiceConverter amrToWav:storePath wavSavePath:wavfilepath];
        }
        
        
        [data addObject:dict];
    }
    
    [data writeToFile:plistfilepath atomically:YES];
    
    if ([addNewMessageFromFriend count]>0) {
        //新信息读入缓存文件，发送更新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteMessageUpdate" object:[self.friendNameDic objectForKey:@"focusUserName"]];
    }
    
    //检查是否写入
    NSMutableArray *writeData=[[NSMutableArray alloc]initWithContentsOfFile:plistfilepath];
    NSLog(@"write data is :%@",writeData);
    
    [self.tableView reloadData];
}

-(void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY=keyBoardRect.size.height;
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        self.view.transform=CGAffineTransformMakeTranslation(0, -deltaY);
    }];
}
-(void)keyboardHide:(NSNotification *)note
{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //add UItableView
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, IS_IOS7?64:44, self.view.frame.size.width, self.view.frame.size.height-108) style:UITableViewStylePlain];
    [self.tableView registerClass:[ChartCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    
    //add keyBorad
    
    self.keyBordView=[[KeyBordVIew alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    self.keyBordView.delegate=self;
    [self.view addSubview:self.keyBordView];
    
    //初始化数据
    [self initwithData];
}

-(void)initwithData
{
    self.cellFrames=[NSMutableArray array];
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //plist文件名字
    NSString* plistfileName = [NSString stringWithFormat:@"%@.plist",[self.friendNameDic objectForKey:@"focusUserName"]];
    plistfilepath = [documentsPath stringByAppendingPathComponent:plistfileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:plistfilepath];
    if (!fileExists) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        //找到Documents文件所在的路径
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //取得第一个Documents文件夹的路径
        NSString *filePath = [path objectAtIndex:0];
        
        //把Plist文件加入
        NSString *plistPath = [filePath stringByAppendingPathComponent:plistfileName];
        
        //开始创建文件
        [fm createFileAtPath:plistPath contents:nil attributes:nil];
    }
    
    NSMutableArray *data=[NSArray arrayWithContentsOfFile:plistfilepath];
    
    if (data == nil) {
        data = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<[self.addupdateMessageArray count]; i++) {
        NSMutableDictionary* addNewMessageDic = [self.addupdateMessageArray objectAtIndex:i];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[addNewMessageDic objectForKey:@"avatar"] forKey:@"icon"];
        [dict setObject:[addNewMessageDic objectForKey:@"time"] forKey:@"time"];
        [dict setObject:[addNewMessageDic objectForKey:@"content"] forKey:@"content"];
        [dict setObject:@"0" forKey:@"type"];
        [dict setObject:[addNewMessageDic objectForKey:@"fromUser"] forKey:@"userName"];
        if ([[addNewMessageDic objectForKey:@"content"] isEqualToString:@""]) {
            [dict setObject:@"1" forKey:@"contenttype"];
            NSString* strfileName = [addNewMessageDic objectForKey:@"voice"];
            NSURL *voiceURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.yugong-tech.com/download_voice_wt?voice_file=%@",strfileName]];
            NSData *voiceData = [NSData dataWithContentsOfURL:voiceURL];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:strfileName];
            if ([fileManager fileExistsAtPath:applicationDocumentsDir])
                NSLog(@"applicationDocumentsDir exists");   // verifies directory exist
            
            
            if (voiceData) {
                NSString *content = [[NSString alloc]  initWithBytes:[voiceData bytes]
                                                              length:[voiceData length] encoding: NSUTF8StringEncoding];
                
                NSLog(@"%@", content); // verifies data was downloaded correctly
                
                NSError* error;
                [voiceData writeToFile:storePath options:NSDataWritingAtomic error:&error];
                
                if(error != nil)
                    NSLog(@"write error %@", error);
            }
            
            
            NSArray *array = [strfileName componentsSeparatedByString:@"."];
            NSString* strAmrToWAvFileName = [NSString stringWithFormat:@"%@.wav",[array objectAtIndex:0]];
            [dict setObject:[addNewMessageDic objectForKey:@"avatar"] forKey:@"icon"];
            [dict setObject:strAmrToWAvFileName forKey:@"content"];
            
            NSString* wavfilepath = [NSString documentPathWith: strAmrToWAvFileName];
            [VoiceConverter amrToWav:storePath wavSavePath:wavfilepath];
        }
        
        
        [data addObject:dict];
    }
    
    for(NSDictionary *dict in data){
        
        ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
        ChartMessage *chartMessage=[[ChartMessage alloc]init];
        chartMessage.dict=dict;
        cellFrame.chartMessage=chartMessage;
        [self.cellFrames addObject:cellFrame];
    }
    
    if ([self.addupdateMessageArray count]>0) {
        //新信息读入缓存文件，发送更新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteMessageUpdate" object:[self.friendNameDic objectForKey:@"focusUserName"]];
    }
    
    [data writeToFile:plistfileName atomically:YES];
    
    //检查是否写入
    NSMutableDictionary *writeData=[[NSMutableDictionary alloc]initWithContentsOfFile:plistfileName];
    NSLog(@"write data is :%@",writeData);
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellFrames.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChartCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate=self;
    cell.cellFrame=self.cellFrames[indexPath.row];
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellFrames[indexPath.row] cellHeight];
}
-(void)chartCell:(ChartCell *)chartCell tapContent:(NSString *)content
{
    if(self.player.isPlaying){
        
        [self.player stop];
    }
    //播放
    NSString *filePath=[NSString documentPathWith:content];
    NSURL *fileUrl=[NSURL fileURLWithPath:filePath];
    
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileUrl error:nil];
    //初始化播放器
    [self.player prepareToPlay];
    self.player.numberOfLoops = -1;
    
    //设置音频音量 volume的取值范围在 0.0为最小 0.1为最大 可以根据自己的情况而设置
    self.player.volume = 0.1f;
    
    if (![self.player isPlaying])
    {
        [self.player play];
    }

    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //在这里判断以下是否能找到这个音乐文件
    if (filePath) {
        //从path路径中 加载播放器
        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[[NSURL alloc]initFileURLWithPath:filePath]error:nil];
        //初始化播放器
        [self.player prepareToPlay];
        
        //设置播放循环次数，如果numberOfLoops为负数 音频文件就会一直循环播放下去
        self.player.numberOfLoops = 0;
        
        //设置音频音量 volume的取值范围在 0.0为最小 0.1为最大 可以根据自己的情况而设置
        self.player.volume = 0.1f;
    }
    if (![self.player isPlaying])
    {
        [self.player play];
    }
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    [self.player stop];
    self.player=nil;
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)sendText:(NSString *)text
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    //[dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    newMessageTime = [dateFormater stringFromDate:now];
    
    if ([text isEqualToString:@""]|| text == nil) {
        return;
    }
    
    ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
    ChartMessage *chartMessage=[[ChartMessage alloc]init];
    
    chartMessage.icon=[self.userNameDic objectForKey:@"avatar"];
    chartMessage.messageType=1;
    chartMessage.content = text;
    chartMessage.contentType = @"0";
    cellFrame.chartMessage=chartMessage;
    
    strAmrFileName = @"";
    //上传信息到服务器
    [[NetDatamanager sharedManager] sendMessage:[self.userNameDic objectForKey:@"userName"] toUserName:[self.friendNameDic objectForKey:@"focusUserName"] content:text voiceFileName:strAmrFileName success:^(id response, NSString* str){
        //        NSMutableDicti onary* allmessagedic = response
        
        //发送信息暂时存入plist
        NSMutableArray *data=[NSArray arrayWithContentsOfFile:plistfilepath];
        if (data == nil||[data count]==0) {
            data = [[NSMutableArray alloc] init];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[self.userNameDic objectForKey:@"Avatar"] forKey:@"icon"];
        [dict setObject:newMessageTime forKey:@"time"];
        [dict setObject:text forKey:@"content"];
        [dict setObject:@"1" forKey:@"type"];
        [dict setObject:[self.userNameDic objectForKey:@"userName"] forKey:@"userName"];
        [dict setObject:@"0" forKey:@"contenttype"];
        
        [data addObject:dict];
        
        [data writeToFile:plistfilepath atomically:YES];
        
        //检查是否写入
        NSMutableArray *writeData=[[NSMutableArray alloc]initWithContentsOfFile:plistfilepath];
        NSLog(@"write data is :%@",writeData);
        
    }failure:^(NSError* error){
        
    }];
    
    
    [self.cellFrames addObject:cellFrame];
    [self.tableView reloadData];
    
    //滚动到当前行
    [self tableViewScrollCurrentIndexPath];
}

-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledReturn:(UITextField *)textFiled
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    //[dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    newMessageTime = [dateFormater stringFromDate:now];
    
    if ([textFiled.text isEqualToString:@""]|| textFiled.text == nil) {
        return;
    }
    
    ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
    ChartMessage *chartMessage=[[ChartMessage alloc]init];
    
    chartMessage.icon=[self.userNameDic objectForKey:@"avatar"];
    chartMessage.messageType=1;
    chartMessage.content=textFiled.text;
    chartMessage.contentType = @"0";
    cellFrame.chartMessage=chartMessage;

    strAmrFileName = @"";
    //上传信息到服务器
    [[NetDatamanager sharedManager] sendMessage:[self.userNameDic objectForKey:@"userName"] toUserName:[self.friendNameDic objectForKey:@"focusUserName"] content:textFiled.text voiceFileName:strAmrFileName success:^(id response, NSString* str){
        //        NSMutableDicti onary* allmessagedic = response
        
        //发送信息暂时存入plist
        NSMutableArray *data=[NSArray arrayWithContentsOfFile:plistfilepath];
        if (data == nil||[data count]==0) {
            data = [[NSMutableArray alloc] init];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[self.userNameDic objectForKey:@"Avatar"] forKey:@"icon"];
        [dict setObject:newMessageTime forKey:@"time"];
        [dict setObject:textFiled.text forKey:@"content"];
        [dict setObject:@"1" forKey:@"type"];
        [dict setObject:[self.userNameDic objectForKey:@"userName"] forKey:@"userName"];
        [dict setObject:@"0" forKey:@"contenttype"];
        
        [data addObject:dict];
        
        [data writeToFile:plistfilepath atomically:YES];
        
        //检查是否写入
        NSMutableArray *writeData=[[NSMutableArray alloc]initWithContentsOfFile:plistfilepath];
        NSLog(@"write data is :%@",writeData);
        
         textFiled.text = @"";
        
    }failure:^(NSError* error){
        
    }];
    
    
    [self.cellFrames addObject:cellFrame];
    [self.tableView reloadData];
    
    //滚动到当前行
    [self tableViewScrollCurrentIndexPath];
}
-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledBegin:(UITextField *)textFiled
{
    
    [self tableViewScrollCurrentIndexPath];
    
}
-(void)beginRecord
{
    if(self.recording)return;
    
    self.recording=YES;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:16000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    //[dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    newMessageTime = [dateFormater stringFromDate:now];
    
    NSTimeInterval interval = [now timeIntervalSince1970]*1000;
    
    NSNumber* numStage = [NSNumber numberWithDouble:interval];
    NSString *numStr = [NSString stringWithFormat:@"%0.0lf",[numStage doubleValue]];
    
    NSString* userName = [self.userNameDic objectForKey:@"userName"];
    
    NSString *fileName = [NSString stringWithFormat:@"%@%@.wav", userName, numStr];
    self.fileName=fileName;
    strAmrFileName = [NSString stringWithFormat:@"%@%@.amr",userName,numStr];
    
    NSString *filePath = [NSString documentPathWith:fileName];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc]initWithURL:fileUrl settings:settings error:&error];
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder peakPowerForChannel:0];
    [self.recorder record];
}
-(void)finishRecord
{
    //转换wav到amr
    NSString *savefilePath=[NSString documentPathWith:strAmrFileName];
    NSString *filePath = [NSString documentPathWith:self.fileName];
    [VoiceConverter wavToAmr:filePath amrSavePath:savefilePath];
    
    _timeLen = self.recorder.currentTime;
    
    if (_timeLen<0.5) {
        MBProgressHUD *hud= [[MBProgressHUD alloc] initWithView:self.view];
        hud.labelText = @"录音时间太短";
        hud.mode = MBProgressHUDModeText;
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:2];
        return;
    }
    
    self.recording=NO;
//    [self.recorder stop];
    self.recorder=nil;
    ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
    ChartMessage *chartMessage=[[ChartMessage alloc]init];
    
    chartMessage.icon=[self.userNameDic objectForKey:@"avatar"];
    chartMessage.messageType=1;
    chartMessage.content=self.fileName;
    cellFrame.chartMessage=chartMessage;
    [self.cellFrames addObject:cellFrame];
    [self.tableView reloadData];
    [self tableViewScrollCurrentIndexPath];
    
    self.content = @"";
    [[NetDatamanager sharedManager] sendMessage:[self.userNameDic objectForKey:@"userName"] toUserName:[self.friendNameDic objectForKey:@"focusUserName"] content:self.content voiceFileName:strAmrFileName success:^(id response, NSString* str){
        //        NSMutableDicti onary* allmessagedic = response
        
        //发送信息暂时存入plist
        NSMutableArray *data=[NSArray arrayWithContentsOfFile:plistfilepath];
        if (data == nil||[data count]==0) {
            data = [[NSMutableArray alloc] init];
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[self.userNameDic objectForKey:@"Avatar"] forKey:@"icon"];
        [dict setObject:newMessageTime forKey:@"time"];
        [dict setObject:self.fileName forKey:@"content"];
        [dict setObject:@"1" forKey:@"type"];
        [dict setObject:[self.userNameDic objectForKey:@"userName"] forKey:@"userName"];
        [dict setObject:@"1" forKey:@"contenttype"];
 
        [data addObject:dict];
        
        [data writeToFile:plistfilepath atomically:YES];
        
        //检查是否写入
        NSMutableArray *writeData=[[NSMutableArray alloc]initWithContentsOfFile:plistfilepath];
        NSLog(@"write data is :%@",writeData);
        
    }failure:^(NSError* error){
        
    }];
    
    [[NetDatamanager sharedManager] uploadVoiceFile:[NSString documentPathWith:strAmrFileName]];
}
-(void)tableViewScrollCurrentIndexPath
{
    if ([self.cellFrames count]>0) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.cellFrames.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
-(void)initPlayer{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
