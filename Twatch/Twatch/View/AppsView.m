//
//  AppsView.m
//  Twatch
//
//  Created by 龚涛 on 10/11/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import "AppsView.h"

@implementation AppsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)playVideo:(id)sender
{
    
    NSLog(@"haha");
    NSString *name = nil;
////    NSString *type = nil;
//    switch ([sender tag]) {
//        case SettingAppType: {
////            name = @"setting";
//            break;
//        }
//        case PanoramicAppType: {
////            name = @"panoramic";
//            break;
//        }
//        case ExclusuveAppType: {
////            name = @"exclisive";
//            break;
//        }
//        case TryAppType: {
//            name = @"try";
//            break;
//        }
//
//        default:
//            break;
//    }
    name = [NSString stringWithFormat:@"%d",[sender tag]];
    if (name) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PlayAppsVideoNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", nil]];
    }
}

@end
