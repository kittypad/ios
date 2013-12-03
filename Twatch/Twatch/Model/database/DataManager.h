//
//  DataManager.h
//  Twatch
//
//  Created by 龚涛 on 12/3/13.
//  Copyright (c) 2013 龚涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

+ (DataManager *)sharedManager;

- (BOOL)saveContext:(NSManagedObjectContext *)context;

@end
