(unless $console ;; guard against multiple injection        
        (load "console")     
        (set $console ((NuConsoleWindowController alloc) init))
        (if (set appName (((NSBundle mainBundle) localizedInfoDictionary) objectForKey:"CFBundleName"))
            (($console window) setTitle:"Nu Console (#{appName})"))
        ($console toggleConsole:0))

(function NuInspect_LabelForObject (obj)
	(set d (_parser context))
	(set label nil)
	((d allKeys) each:(do (key)
		(if (== (d objectForKey:key) obj) (set label key) ) ))
	(if (== label nil)
		(((_parser symbolTable) all) each:(do (symbol)
			(if (== (symbol value) obj) (set label symbol)) )) )

	(label stringValue))

(function inspect (*arguments)
	(if (> (*args count) 1) 
		(_parser setValue:(*args first) forKey:(*args second)) # We've defined a label, put it into the context
		((NuInspect sharedInstance) inspectObject:(*args first) label:(*args second))
	(else
		((NuInspect sharedInstance) inspectObject:obj label:(NuInspect_LabelForObject obj)) )))

(class NuInspect
	(- (void) writeToConsole:(id)str is 
		(set ts ((($console valueForKey:"console") valueForKey:"textview") textStorage))
		(ts replaceCharactersInRange:(list (ts length) 0) withString:str)))
