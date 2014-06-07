//
//  QRCodeManagerViewController.m
//  Twatch
//
//  Created by 龚涛 on 11/29/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "QRCodeManagerViewController.h"
#import "ImageLabelView.h"
#import "QRCodeCaptureViewController.h"
#

@interface QRCodeManagerViewController ()

@end

@implementation QRCodeManagerViewController

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
	// Do any additional setup after loading the view.
    
    UIButton* captureBtn = [[UIButton alloc] initWithFrame:CGRectMake(240, IS_IOS7?25:5, 45, 30)];
    [captureBtn setBackgroundImage:[UIImage imageNamed:@"CaptureQRCode"] forState:UIControlStateNormal];
    [captureBtn addTarget:self action:@selector(captureClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captureBtn];
}

-(void)captureClicked
{
    QRCodeCaptureViewController *qrcodeCapture = [[QRCodeCaptureViewController alloc] init];
    qrcodeCapture.backName = NSLocalizedString(@"扫描二维码", nil);
    [self.navigationController pushViewController:qrcodeCapture animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
