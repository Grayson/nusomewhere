//
//  NuInspect.m
//  NuSomewhere
//
//  Created by Grayson Hansard on 4/23/09.
//  Copyright 2009 From Concentrate Software. All rights reserved.
//

#import "NuInspect.h"
#import "NSObject+Inspect.h"

@implementation NuInspect
@synthesize inspectedObjects = _inspectedObjects;

+ (id)sharedInstance
{
	static id instance = nil;
	if (!instance) instance = [[self class] new];
	return instance;
}

- (id)init
{
	self = [super init];
	if (!self) return nil;
	
	[NSBundle loadNibNamed:@"NuInspect" owner:self];
	
	return self;
}

- (void)awakeFromNib
{
	[tableView setTarget:self];
	[tableView setAction:@selector(updateInfo:)];
}

-(void)inject {
	NSString *src = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"inspect" ofType:@"nu"]];
	if (src) [[Nu parser] parseEval:src];
}

- (void)updateInfo:(id)sender
{
	NSIndexSet *set = [tableView selectedRowIndexes];
	if (!set) return;
	
	int idx = [set lastIndex];
	if (idx > self.inspectedObjects.count || idx < 0) return;
	
	id obj = [self.inspectedObjects objectAtIndex:idx];
	if (!obj) return;
	
	NSArray *ivars = [obj ivars];
	NSArray *classMethods = [[obj class] performSelector:@selector(classMethodNames)]; // From Nu.
	NSArray *instanceMethods = [[obj class] performSelector:@selector(instanceMethodNames)]; // From Nu.
	
	NSMutableString *string = [NSMutableString string];
	[string appendFormat:@"<h1>%@</h1>", NSStringFromClass([obj class])];
	
	[string appendString:@"<h2>Ivars:</h2><ul>"];
	for (NSString *ivar in ivars) { [string appendFormat:@"<li>%@</li>", ivar]; }
	
	[string appendString:@"</ul><h2>Class methods:</h2><ul>"];
	for (NSString *method in classMethods) { [string appendFormat:@"<li>+ %@</li>", method]; }
	
	[string appendString:@"</ul><h2>Instance methods:</h2><ul>"];
	for (NSString *method in instanceMethods) { [string appendFormat:@"<li>- %@</li>", method]; }
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithHTML:[string dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil];
	[textView.textStorage setAttributedString: as];
	[as release];
}

- (void)inspectObject:(id)obj
{
	[window makeKeyAndOrderFront:self];
	if (!obj) return;
	
	NSMutableArray *objs = self.inspectedObjects;
	if (!objs) objs = [NSMutableArray array];
	
	[objs addObject:obj];
	
	self.inspectedObjects = objs;
	
	unsigned int idx = [objs indexOfObject:obj];
	[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];

	[self updateInfo:self];
}

@end

__attribute__((constructor)) static void
InjectBundleInit (void)
{
	NuInspect *inspect = [NuInspect sharedInstance];
    [inspect performSelectorOnMainThread:@selector(inject) withObject:nil waitUntilDone:NO];
}
