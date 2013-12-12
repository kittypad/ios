//
//  WatchStyleViewController.m
//  T-Fire2.0
//
//  Created by yixiaoluo on 13-11-28.
//  Copyright (c) 2013年 tomoon. All rights reserved.
//

#import "WatchStyleViewController.h"

#import "BGColorButton.h"

@interface WatchStyleViewController ()

- (void)_handleButtonPressed:(id)sender;

@end

@implementation WatchStyleViewController

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
    // Do any additional setup after loading the view from its nib.
    
//    CGFloat y = IS_IOS7?94:74;
//    UIButton *button1 = [UIButton alloc] initWithFrame:CGRectMake(, , , )
    
    BGColorButton *handleButton = [[BGColorButton alloc] initWithFrame:CGRectMake(22.0, self.view.frame.size.height-55.0, 276.0, 40.0)];
    handleButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    handleButton.titleLabel.textColor = [UIColor whiteColor];
    handleButton.titleLabel.text = NSLocalizedString(@"Handle", nil);
    [handleButton setBackgroundColor:[UIColor colorWithHex:@"6fc6fc"] forState:UIControlStateNormal];
    [handleButton setBackgroundColor:[UIColor colorWithHex:@"1ca1f6"] forState:UIControlStateHighlighted];
    [handleButton addTarget:self action:@selector(_handleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:handleButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)_handleButtonPressed:(id)sender
{
    
}

@end
