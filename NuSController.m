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
	
	AuthorizationRef myAuthorizationRef;
	OSStatus status = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &myAuthorizationRef);
	if (status != noErr) {
		NSLog(@"%s ERROR %d", _cmd, status);
	}
	
	// Change the current working directory so that Nu knows where to find the bundle and load NuInject.framework.
	char *cwd = getcwd(nil, 0);
	chdir([[[NSBundle mainBundle] resourcePath] fileSystemRepresentation]);
	
	char *args[3]; // arguments for the mv command
	args[0] = (char *)[[[NSBundle mainBundle] pathForResource:@"nu-anywhere" ofType:nil] fileSystemRepresentation];
	args[1] = (char *)[[app objectForKey:@"NSApplicationName"] fileSystemRepresentation];
	args[2] = NULL;
	
	status = AuthorizationExecuteWithPrivileges(myAuthorizationRef, "/usr/local/bin/nush", 0, args, NULL);
	if (status != noErr) {
		NSLog(@"%s ERROR 2: %d", _cmd, status);
	}
	
	// Change back to the previous working directory.  I don't think this is necessary, but I figure I might as well.
	chdir(cwd);
}

@end
