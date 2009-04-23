//
//  NuSController.m
//  NuSomewhere
//
//  Created by Grayson Hansard on 4/23/09.
//  Copyright 2009 From Concentrate Software. All rights reserved.
//

#import "NuSController.h"


@implementation NuSController
@synthesize runningApplications = _runningApplications;

- (void)awakeFromNib
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSMutableArray *array = [NSMutableArray array];
	for (NSDictionary *app in [ws launchedApplications]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:app];
		[dict setObject:[ws iconForFile:[app objectForKey:@"NSApplicationPath"]] forKey:@"icon"];
		[array addObject:dict];
	}
	self.runningApplications = array;
}

- (IBAction)inject:(id)sender {
	NSIndexSet *indexSet = [tableView selectedRowIndexes];
	if (!indexSet) return;
	
	int idx = [indexSet lastIndex];
	if (idx < 0) return;
	
	NSDictionary *app = [self.runningApplications objectAtIndex:idx];
	[self injectBundleWithPath:[[NSBundle mainBundle] pathForResource:@"NuConsole" ofType:@"bundle"] intoProcess:[[app objectForKey:@"NSApplicationProcessIdentifier"] unsignedIntValue]];
}

// Stolen directly from the NuInject source for NuAnywhere from Nu's Example folder.
- (void)injectBundleWithPath:(NSString *)bundlePath intoProcess:(pid_t)pid
{
    if ([bundlePath isAbsolutePath] == 0) {
        bundlePath = [[[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:bundlePath] stringByStandardizingPath];
    }
    mach_error_t err = mach_inject_bundle_pid([bundlePath fileSystemRepresentation], pid);
    if (err != err_none)
        NSLog(@"Failure code %x", err);
}

@end
