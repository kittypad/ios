//
//  ShareViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-11-17.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareCell.h"

@interface ShareViewController ()

@property (nonatomic, strong) NSArray *listNames;

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *defaultContent;
@property (nonatomic, strong) id<ISSCAttachment> image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *description;
@property (nonatomic) SSPublishContentMediaType mediaType;

@end


@implementation ShareViewController

- (id)initWithContent:(NSString *)content
       defaultContent:(NSString *)defaultContent
                image:(id<ISSCAttachment>)image
                title:(NSString *)title
                  url:(NSString *)url
          description:(NSString *)description
            mediaType:(SSPublishContentMediaType)mediaType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.listNames = [NSArray arrayWithObjects:@"微信",@"人人",@"豆瓣",@"腾讯微博",@"新浪", nil];
        
        self.content = content;
        self.defaultContent = defaultContent;
        self.image = image;
        self.title = title;
        self.url = url;
        self.description = description;
        self.mediaType = mediaType;
    }
    return self;
}


- (void)viewDidLoad
{
    self.backName = @"分享";
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    PSTCollectionViewFlowLayout *watchLayout = [[PSTCollectionViewFlowLayout alloc] init];
    watchLayout.itemSize = CGSizeMake(232/2, 204/2);
    watchLayout.sectionInset = UIEdgeInsetsMake(60/2, 63/2 , 0/2, 63/2);
    watchLayout.minimumLineSpacing = 45/2;
    watchLayout.minimumInteritemSpacing = 45/2;
    watchLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    PSTCollectionView *watchCollectiongView = [[PSTCollectionView alloc] initWithFrame:CGRectChangeOrigin(self.view.frame, 0, (IS_IOS7 ? 64 : 44))
                                                                  collectionViewLayout:watchLayout];
    watchCollectiongView.delegate = self;
    watchCollectiongView.dataSource = self;
    watchCollectiongView.pagingEnabled = YES;
    [watchCollectiongView registerClass:[ShareCell class] forCellWithReuseIdentifier:@"ShareCell"];
    [self.view addSubview:watchCollectiongView];
}

//MARK: PSTCollectionViewDataSource
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listNames.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ShareCell"
                                                                            forIndexPath:indexPath];
    
    [((ShareCell *)cell) configCellWithInfo:self.listNames[indexPath.row] atIndex:indexPath.row];
    
    return cell;
}

//MARK: PSTCollectionViewDelegate
- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *shareList = [NSArray arrayWithObjects:[NSNumber numberWithInt:(int)ShareTypeWeixiSession],[NSNumber numberWithInt:(int)ShareTypeWeixiTimeline],[NSNumber numberWithInt:(int)ShareTypeDouBan],[NSNumber numberWithInt:(int)ShareTypeTencentWeibo],[NSNumber numberWithInt:(int)ShareTypeSinaWeibo], nil];
    
    id<ISSContent> publishContent = [ShareSDK content:self.content
                                       defaultContent:self.defaultContent
                                                image:self.image
                                                title:self.title
                                                  url:self.url
                                          description:self.description
                                            mediaType:self.mediaType ];
    
    [ShareSDK shareContent:publishContent
                      type:[shareList[indexPath.row] integerValue]
               authOptions:nil
             statusBarTips:YES
                    result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        if (state == SSPublishContentStateSuccess)
                        {
                            NSLog(@"分享成功");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode],  [error errorDescription]);
                        }
                    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
