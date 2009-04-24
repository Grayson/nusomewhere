# About NuSomewhere

NuSomewhere is a simple gui on top of the work done for NuAnywhere found in Nu's Example folder.  It doesn't use the command line application (although it easily could), but it certainly uses the bundles created in NuAnywhere.

To build NuSomewhere, you first need to download [Nu](http://github.com/timburks/nu/tree/master) and build NuAnywhere (found in the Examples folder, build by using `nuke`).  Then you'll need to re-target everything in the "inject" directory of the Xcode project to the stuff in your Nu folder.  It should build fairly cleanly after that.

## Contact information

Grayson Hansard  
info@fromconcentratesoftware.com  
[From Concentrate Software](http://www.fromconcentratesoftware.com/)

## Future plans

F-Script Anywhere also allows for it to be injected into apps automatically.  I'm not as interested in this, but I'd be willing to look into it if there was enough interest in the community.

## Completed (or mostly so)

I decided to avoid procmod problems by authenticating the nu-anywhere script to run as a substitute user whenever you inject Nu into an application.  This means that you'll have to do it repeatedly, but I don't want to get mired down in procmod maintenance.  Run an internet search for "F-Script procmod" and see how that went over.

There's now a nice inspector bundled with the console.  You can inspect objects fairly easily.  Simply use the `inspect` command (see below).

NuSomewhere now updates whenever applications are launched or quit.

You can now attach scripts to applications so that they are run automatically whenever NuSomewhere is injected into an application.  See the notes on the `attach` and `detach` commands below.

## Using the `inspect` command

What I loved about F-Script anywhere was the ability to graphically inspect objects.  That made hacking away at something much easier than using `class-dump`.  If you're building an input manager or other hack for an application (personally, I've added applescript support to several applications without ever looking at the source code using F-Script and `class-dump` and, now, NuSomewhere), this type of introspection is very handy.  NuSomewhere provides the `inspect` command to provide a small GUI for seeing what an object can do.  There are two flavors to `inspect` and a couple of caveats.

First, and simplest, is to simply inspect an object that you already know and love:

	(set app (NSApplication sharedApplication))
	(inspect app)

If you set an object to a variable, `inspect` will attempt to match up the object to its name in the parser context.  This will be displayed in the table on the left side of the inspection window.  Note that this could match an identical object with a different name.  If it does, it'll use that name instead.

Second, you can inspect objects a bit more directly:

	(inspect (NSApplication sharedApplication))

Now, this is a small problem.  The inspection window provides some handy introspection documentation on the object that is selected.  If you just tossed an object at the inspector that isn't set to a label, the inspector doesn't know how to reference it later if you click on one of the links in the documentation view.  Nothing will break, you just lose a little functionality when using un-labeled objects.

There is a solution for this.  You can use `inspect` and add a label at the same time:

	(inspect (NSApplication sharedApplication) "app")

The second parameter to `inspect` is a string that represents the label.  This *must* be a string.  When `inspect` works its magic, it'll insert the object into the context using that particular label.

## About the `attach` and `detach` commands

If you work with particular applications regularly with NuSomewhere, there may be a lot of boilerplate code that is tiresome to type repeatedly.  Fortunately, NuSomewhere provides a mechanism to automatically run a file when it is injected into an application.  This mechanism is called `attach`.  `attach` is a simple Console command that takes the full path to a Nu file.  Whenever NuSomehwere injects nu-anywhere into an application, it will attempt to load the file attached immediately after injection.

	(attach "/Users/username/Desktop/init.nu")

This is handy for setting up standard objects such as NSApp (`(set NSApp (NSApplication sharedApplication))`) or other common variables or functions.  If you want to include multiple files, simply load them in the attached file.  This is also useful for loading frameworks or other bundles.

If you'd like to remove the attached file, simply use the `detach` command.

	(detach)

## Thanks

Many, many thanks to Tim Burks.  NuSomewhere basically just extends nu-anywhere which is found in the Nu distribution.  All of the hard work was done for me, I just put a little sugar on top.

Also, many thanks to Jonathan "Wolf" Rentzsch for mach\_*.  mach_inject and its like make stuff like this possible.