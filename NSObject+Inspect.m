//
//  NSObject+Inspect.m
//  NuSomewhere
//
//  Created by Grayson Hansard on 4/24/09.
//  Copyright 2009 From Concentrate Software. All rights reserved.
//

#import "NSObject+Inspect.h"
#import <objc/runtime.h>

@implementation NSObject (Inspect)

-(NSArray *)ivars {
	unsigned int ivarCount = 0;
	Ivar *ivars = class_copyIvarList([self class], &ivarCount);
	if (ivars && ivarCount) {
		NSMutableArray *array = [NSMutableArray array];
		unsigned int idx = 0;
		for (idx=0; idx < ivarCount; idx++) {
			Ivar ivar = ivars[idx];
			[array addObject:[NSString stringWithUTF8String:ivar_getName(ivar)]];
		}
		free(ivars);
		return array;
	}
	return nil;
}

@end
