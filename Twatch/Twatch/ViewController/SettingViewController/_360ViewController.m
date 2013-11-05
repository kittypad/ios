//
//  360ViewController.m
//  Twatch
//
//  Created by yixiaoluo on 13-10-30.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "_360ViewController.h"
#import "FVImageSequence.h"

@interface _360ViewController ()
@property(nonatomic,strong)FVImageSequence *imageSquence;
@end

@implementation _360ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    FVImageSequence *imageSquence = [[FVImageSequence alloc] initWithImage:[UIImage imageNamed:@"0_0.jpg"]];
    imageSquence.frame = CGRectChangeSize(imageSquence.frame,640,360);
//    imageSquence.frame = CGRectChangeWidth(imageSquence.frame,640);
    imageSquence.center = self.view.center;
    imageSquence.userInteractionEnabled = YES;
    [self.view addSubview:imageSquence];
    self.imageSquence = imageSquence;
    
    //Set slides extension
	[imageSquence setExtension:@"jpg"];
	
	//Set slide prefix prefix
	[imageSquence setPrefix:@"0_"];
	
	//Set number of slides
	[imageSquence setNumberOfImages:24];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.imageSquence removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
