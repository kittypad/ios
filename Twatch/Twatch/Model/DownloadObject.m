//
//  DownloadObject.m
//  Twatch
//
//  Created by 龚 涛 on 13-12-4.
//  Copyright (c) 2013年 龚涛. All rights reserved.
//

#import "DownloadObject.h"

@implementation DownloadObject

@synthesize apkUrl;
@synthesize iconUrl;
@synthesize intro;
@synthesize name;
@synthesize pkg;
@synthesize size;
@synthesize type;
@synthesize ver;
@synthesize state;

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.apkUrl = [coder decodeObjectForKey:kApkUrl];
        self.iconUrl = [coder decodeObjectForKey:kIconUrl];
        self.intro = [coder decodeObjectForKey:kIntro];
        self.name = [coder decodeObjectForKey:kName];
        self.pkg = [coder decodeObjectForKey:kPkg];
        self.size = [coder decodeObjectForKey:kSize];
        self.type = [coder decodeObjectForKey:kType];
        self.ver = [coder decodeObjectForKey:kVer];
        self.state = [coder decodeObjectForKey:kState];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.apkUrl forKey:kApkUrl];
    [coder encodeObject:self.iconUrl forKey:kIconUrl];
    [coder encodeObject:self.intro forKey:kIntro];
    [coder encodeObject:self.name forKey:kName];
    [coder encodeObject:self.pkg forKey:kPkg];
    [coder encodeObject:self.size forKey:kSize];
    [coder encodeObject:self.type forKey:kType];
    [coder encodeObject:self.ver forKey:kVer];
    [coder encodeObject:self.state forKey:kState];
}

@end
