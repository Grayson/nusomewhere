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
	
	[textView setDelegate:self];
}

-(void)inject {
	NSString *src = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"inspect" ofType:@"nu"]];
	if (src) [[Nu parser] parseEval:src];
}

- (void)updateInfo:(id)sender
{
	[self createInfoForObject:[[self selection] objectForKey:@"object"]];
}

- (void)createInfoForObject:(id)obj {
	if (!obj) return;
	
	NSArray *ivars = [obj ivars];
	NSArray *classMethods = [[obj class] performSelector:@selector(classMethodNames)]; // From Nu.
	NSArray *instanceMethods = [[obj class] performSelector:@selector(instanceMethodNames)]; // From Nu.
	
	NSMutableString *string = [NSMutableString string];
	[string appendFormat:@"<h1>%@</h1>", NSStringFromClass([obj class])];

	NSString *superclass = NSStringFromClass([obj superclass]);
	if (superclass) [string appendFormat:@"<h3>Inherits from: <a href=\"class/%@\">%@</a></h3>", superclass, superclass];
	
	if (ivars && ivars.count > 0) {
		[string appendString:@"<h2>Ivars:</h2><ul>"];
		for (NSString *ivar in ivars) { [string appendFormat:@"<li><a href=\"ivar/%@\">%@</a></li>", ivar, ivar]; }
	}
	
	if (classMethods && classMethods.count > 0) {
		[string appendString:@"</ul><h2>Class methods:</h2><ul>"];
		for (NSString *method in classMethods) { [string appendFormat:@"<li><a href=\"cmethod/%@\">+ %@</a></li>", method, method]; }
	}
	
	if (instanceMethods && instanceMethods.count > 0) {
		[string appendString:@"</ul><h2>Instance methods:</h2><ul>"];
		for (NSString *method in instanceMethods) { [string appendFormat:@"<li><a href=\"imethod/%@\">- %@</a></li>", method, method]; }
	}
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithHTML:[string dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil];
	[textView.textStorage setAttributedString: as];
	[as release];
}

- (id)selection {
	NSIndexSet *set = [tableView selectedRowIndexes];
	if (!set) return nil;
	
	int idx = [set lastIndex];
	if (idx > self.inspectedObjects.count || idx < 0) return nil;
	
	return [self.inspectedObjects objectAtIndex:idx];
}

- (void)inspectObject:(id)obj label:(NSString *)label
{	
	[window makeKeyAndOrderFront:self];
	if (!obj) return;
	
	NSMutableArray *objs = self.inspectedObjects;
	if (!objs) objs = [NSMutableArray array];
	
	if (!label) label = [obj description];
	
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:obj, @"object", label, @"label", nil];
	[objs addObject:d];
	
	self.inspectedObjects = objs;
	
	unsigned int idx = [objs indexOfObject:d];
	[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];

	[self updateInfo:self];
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link {
	NSString *url = [link absoluteString];
	NSString *text = [url lastPathComponent];
	NSString *type = [[url stringByDeletingLastPathComponent] lastPathComponent];
	
	// If we've clicked on the "inherited from" link, simply update the view
	if ([type isEqualToString:@"class"]) {
		Class c = NSClassFromString(text);
		[self createInfoForObject:c];
	}
	else {
		// Get the selection and see if there's a label attached.  If there is a label, then we can work with it.
		NSDictionary *d = [self selection];
		NSString *label = [d objectForKey:@"label"];
		if ([label isEqualToString:[[d objectForKey:@"object"] description]]) {
			// Throw some kind of error here, no label that we can work with.
			return YES;
		}
		
		NSString *outString = nil;
		// In case of an ivar, simply try to reference it using valueForKey:
		if ([type isEqualToString:@"ivar"]) outString = [NSString stringWithFormat:@"(%@ valueForKey:\"%@\")", label, text];
		else if ([type isEqualToString:@"cmethod"]) {
			// For class methods, first check to see if the object is a class.  If so, simply run with it.
			// Otherwise, call the class method by calling `class` on the object.
			if (NSClassFromString(label)) outString = [NSString stringWithFormat:@"(%@ %@)", label, text];
			else outString = [NSString stringWithFormat:@"((%@ class) %@)", label, text];
		}
		else if ([type isEqualToString:@"imethod"]) {
			// For instance methods, bail if we're trying to call them on a class.  Otherwise, insert the call into
			// the console.
			if (NSClassFromString(label)) return YES; // Throw some kind of warning here
			else outString = [NSString stringWithFormat:@"(%@ %@)", label, text];
		}
		[self performSelector:@selector(writeToConsole:) withObject:outString];
	}
	
	return YES;
}

@end

__attribute__((constructor)) static void
InjectBundleInit (void)
{
	NuInspect *inspect = [NuInspect sharedInstance];
    [inspect performSelectorOnMainThread:@selector(inject) withObject:nil waitUntilDone:NO];
}
