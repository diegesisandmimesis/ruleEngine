#charset "us-ascii"
//
// ruleEngineRule.t
//
//	A rule for our purposes is a single check against the game state.
//
//
// PROPERTIES
//
//	For reference only, the meaning of some of the properties.  You
//	shouldn't have to fiddle around with these directly.
//
//		active
//			Boolean indicating whether the rule should be
//			checked this turn.
//
//			Set via setActive(), check via isActive().
//
//		state
//			Boolean indicating whether or not our conditions were
//			satisfied as of the last check.
//
//			Set automatically by check().
//
//		timestamp
//			Turn when we last checked our condition(s).
//
//			Set automatically by setActive().
//
// CUSTOMIZING
//
//	If you want to write custom rules, most of the logic probably
//	wants to go into matchRule(), which should return boolean true
//	to indicate that the rule has been matched, nil otherwise.  Everything
//	else should more or less take care of itself.
//
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

// Generic rule class.
class Rule: RuleEngineObject
	syslogID = ((id != nil) ? id : 'Rule')

	// Is the rule active?  That is, should it be checked this turn?
	active = true

	// The rule state.  That is, is the condition we check for met?
	state = nil

	// Last time we verified the state.
	timestamp = nil

	// The rulebook we're in.
	rulebook = nil

	// Called at preinit.
	initializeRule() {
		_initializeRuleLocation();
		return(true);
	}

	_tryRulebook(obj) {
		if(obj == nil)
			return(nil);
		if(!obj.ofKind(Rulebook) && !obj.ofKind(RuleSystem))
			return(nil);
		return(obj.addRule(self));
	}

	// Figure out which rulebook we belong to.
	_initializeRuleLocation() {
		if(_tryRulebook(rulebook) == true)
			return;
		if(_tryRulebook(location) == true)
			return;
		_error('orphaned rule');
	}

	// Getter and setter for the active flag.
	isActive() { return(active == true); }
	setActive(v?) { active = ((v == true) ? true : nil); }

	// Check whatever condition we test for.  The stub method never
	// matches.
	matchRule(data?) { return(nil); }

	// Update our state.
	setState(v?) {
		// Canonicalize argument.
		v = ((v == true) ? true : nil);


		// Remember that we're current as of this turn.
		if(gActionIsNested == true)
			timestamp = nil;
		else
			timestamp = libGlobal.totalTurns;

		// If the rule state wouldn't change, bail.
		if(state == v)
			return(nil);

		// Set the state.
		state = v;

		// Report success.
		return(true);
	}

	// Return the current state, and nothing else.
	getState() { return(state == true); }

	// Return the current state, updating it if necessary.
	check(type?) {
		if((type != nil) && !ofKind(type))
			return(nil);

		// Check the timestamp, and re-check our condition(s)
		// if they haven't been checked this turn.
		if((gActionIsNested == true)
			|| (timestamp != libGlobal.totalTurns)) {
			setState(matchRule());
		}

		return(getState());
	}
;
