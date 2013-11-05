//
//  FVImageSequence.h
//  Untitled
//
//  Created by Fernando Valente on 12/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FVImageSequence : UIImageView {
	NSString *prefix;
	int numberOfImages;
	float current;
	int previous;
	NSString *extension;
	float increment;
}

@property (readwrite) float increment;
@property (readwrite, copy) NSString *extension;
@property (readwrite, copy) NSString *prefix;
@property (readwrite) int numberOfImages;

@end
