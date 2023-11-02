#charset "us-ascii"
//
// ruleEngine.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

enum ruleEngineBeforeAction, ruleEngineAfterAction;

// Base object class for everything in the module.
// Just a hook for the debugging stuff.
class RuleEngineObject: Syslog
	syslogID = 'RuleEngineObject'
	syslogFlag = 'ruleEngine'

	ruleEngine = nil

	//_ruleEngineInitFlag = nil

	construct(cfg?) {
		if(cfg == nil) cfg = object {};
		cfg.getPropList().forEach(function(o) {
			if(!cfg.propDefined(o, PropDefDirectly))
				return;
			if(!self.propDefined(o))
				return;
			self.(o) = cfg.(o);
		});
	}

/*
	getRuleEngineFlag() { return(_ruleEngineInitFlag == true); }
	setRuleEngineFlag() { _ruleEngineInitFlag = true; }
*/

	// Test two args for equal-ish-ness.
	// Returns boolean true if:
	//	0)	ref is nil
	//	1)	v is identically ref
	//	2)	v is an instance of ref
	//	3)	ref is a list and 1) or 2) apply to an element in it
	testArgs(v, ref) {
		local i;

		// No criteria, always matches.
		if(ref == nil)
			return(true);

		// Non-nil criteria with a nil value always fails.
		if(v == nil)
			return(nil);

		// If ref is a list, check its elements against v
		if(ref.ofKind(List)) {
			for(i = 1; i <= ref.length; i++) {
				if((ref[i] == v) || v.ofKind(ref[i]))
					return(true);
			}

			return(nil);
		}

		// Not a list, check v against ref directly.
		if((v == ref) || v.ofKind(ref))
			return(true);

		// Nope, fail.
		return(nil);
	}
;
