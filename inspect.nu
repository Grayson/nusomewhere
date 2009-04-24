# Taken from nu-anywhere in Nu's source
(unless $console ;; guard against multiple injection        
        (load "console")     
        (set $console ((NuConsoleWindowController alloc) init))
        (if (set appName (((NSBundle mainBundle) localizedInfoDictionary) objectForKey:"CFBundleName"))
            (($console window) setTitle:"Nu Console (#{appName})"))
        ($console toggleConsole:0))

# The following has been added for NuSomewhere to extend the console by adding some extra functions

# Attempt to get the label for a particular object in the parser's context
(function NuInspect_LabelForObject (obj)
	(set d (_parser context))
	(set label nil)
	((d allKeys) each:(do (key)
		(if (== (d objectForKey:key) obj) (set label key) ) ))
	(if (== label nil)
		(((_parser symbolTable) all) each:(do (symbol)
			(if (== (symbol value) obj) (set label symbol)) )) )

	(label stringValue))

# A function to be called in the console.  `inspect` opens the inspection window and adds the object passed to
# the list of watched objects
(function inspect (*arguments)
	(if (> (*args count) 1) 
		(_parser setValue:(eval (*args first)) forKey:(*args second)) # We've defined a label, put it into the context
		((NuInspect sharedInstance) inspectObject:(eval (*args first)) label:(*args second))
	(else
		((NuInspect sharedInstance) inspectObject:(*arguments first) label:(NuInspect_LabelForObject (*arguments first))) )))

# A function to be called in the console.  This attaches a nu file to an application (by adding it to the user defaults)
# that will then be run whenever NuSomewhere is injected into an application.
(function attach (nufile)
	((NSUserDefaults standardUserDefaults) setObject:nufile forKey:"NuInspect_AttachedFile") )

# Deletes the user default set by attach.  Also called in the console.
(function detach () ((NSUserDefaults standardUserDefaults) removeObjectForKey:"NuInspect_AttachedFile") )

# A small extension to NuInspect that writes to the console.
(class NuInspect
	(- (void) writeToConsole:(id)str is 
		(set ts ((($console valueForKey:"console") valueForKey:"textview") textStorage))
		(ts replaceCharactersInRange:(list (ts length) 0) withString:str)))

# Perform setup based on if any files are attached using `attach`
(set tmp ((NSUserDefaults standardUserDefaults) objectForKey:"NuInspect_AttachedFile"))
(if (!= tmp nil) (load tmp))