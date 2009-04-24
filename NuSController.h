//
//  NuSController.h
//  NuSomewhere
//
//  Created by Grayson Hansard on 4/23/09.
//  Copyright 2009 From Concentrate Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface NuSController : NSObject {
	IBOutlet NSTableView *tableView;
	NSArray *_runningApplications;
}
@property (retain) NSArray *runningApplications;

- (IBAction)inject:(id)sender;
- (void)updateRunningApplications;

@end
