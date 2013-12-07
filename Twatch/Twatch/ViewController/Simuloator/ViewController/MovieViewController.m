//
//  MovieViewController.m
//  Twatch
//
//  Created by 龚涛 on 10/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "MovieViewController.h"

@interface MovieViewController ()

@end

@implementation MovieViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContentURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        _moviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        [self addChildViewController:_moviePlayerViewController];
        [self.view addSubview:_moviePlayerViewController.view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_moviePlayerViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
