//
//  NuInspect.h
//  NuSomewhere
//
//  Created by Grayson Hansard on 4/23/09.
//  Copyright 2009 From Concentrate Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Nu/Nu.h>


@interface NuInspect : NSObject {
	IBOutlet NSTableView *tableView;
	IBOutlet NSTextView *textView;
	IBOutlet NSWindow *window;
	NSMutableArray *_inspectedObjects;
}

@property (retain) NSMutableArray *inspectedObjects;

+ (id)sharedInstance;

@end
