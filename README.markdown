# About NuSomewhere

NuSomewhere is a simple gui on top of the work done for NuAnywhere found in Nu's Example folder.  It doesn't use the command line application (although it easily could), but it certainly uses the bundles created in NuAnywhere.

To build NuSomewhere, you first need to download [Nu](http://github.com/timburks/nu/tree/master) and build NuAnywhere (found in the Examples folder, build by using `nuke`).  Then you'll need to re-target everything in the "inject" directory of the Xcode project to the stuff in your Nu folder.  It should build fairly cleanly after that.

## Contact information

Grayson Hansard  
info@fromconcentratesoftware.com  
[From Concentrate Software](http://www.fromconcentratesoftware.com/)

## Future plans

Ideally, I'd like to extend the console portion of this.  I'd like to have F-Script-like introspection of objects (listing methods and class properties).  I have a few ideas on doing this, but the current build is a nice GUI.

F-Script Anywhere also allows for it to be injected into apps automatically.  I'm not as interested in this, but I'd be willing to look into it if there was enough interest in the community.

I'm also considering extending the console in such as way as to make it easy to run Nu files from the console and even automatically whenever it is injected into certain apps.  This is a low-lying priority after extending the console section, but I can see it being useful across multiple sessions.