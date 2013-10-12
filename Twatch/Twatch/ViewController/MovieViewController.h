//
//  MovieViewController.h
//  Twatch
//
//  Created by 龚涛 on 10/12/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MovieViewController : UIViewController
{
    MPMoviePlayerViewController *_moviePlayerViewController;
}

- (id)initWithContentURL:(NSURL *)url;

@end
