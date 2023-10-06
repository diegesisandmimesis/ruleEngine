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
class RuleEngineRuleBase: Syslog
	syslogID = 'Rule'

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
		_initializeSceneRuleLocation();
	}

	// Figure out which rulebook we belong to.
	_initializeRuleLocation() {
		if((location == nil) || !location.ofKind(RuleEngineRulebook))
			return;

		// Add ourselves to our parent's rule list.
		location.addRule(self);

		rulebook = location;
	}

	// Getter and setter for the active flag.
	isActive() { return(active == true); }
	setActive(v?) { active = ((v == true) ? true : nil); }

	// Check whatever condition we test for.  The stub method always
	// matches.
	matchRule(actor?, obj?, action?) { return(true); }

	// Update our state.
	setState(v?) {
		// Canonicalize argument.
		v = ((v == true) ? true : nil);

		// Remember that we're current as of this turn.
		timestamp = libGlobal.totalTurns;

		// If the rule state wouldn't change, bail.
		if(ruleState == v)
			return(nil);

		// Set the state.
		ruleState = v;

		// Report success.
		return(true);
	}

	// Return the current state, and nothing else.
	getState() { return(ruleState == true); }

	// Return the current state, updating it if necessary.
	check() {
		// Check the timestamp, and re-check our condition(s)
		// if they haven't been checked this turn.
		if(timestamp != libGlobal.totalTurns)
			setState(matchRule(actor, obj, action));

		return(getState());
	}
;

// Rule class containing utility methods for triggers.
class RuleEngineRule: RuleEngineRuleBase
	// A list of sense actions.
	_senseActions = static [ ExamineAction, LookAction, SmellAction,
		ListenToAction, TasteAction, FeelAction, SenseImplicitAction ]

	// A list of travel actions.
	_travelActions = static [ TravelAction, TravelViaAction ]

	// Flag we set before doing a try{} finally{} test on the current
	// action, to prevent recursion.
	_testCurrentActionLock = nil

	// Make sure the argument is an Action.
	// If it's nil, we try gAction.
	_canonicalizeAction(action?) {
		// If no action is specified, use the current turn action.
		if(action == nil)
			action = gAction;

		// Make sure we have a valid action
		if((action == nil) || !action.ofKind(Action))
			return(nil);

		return(action);
	}

	// Make sure the argument is a List.
	_canonicalizeList(l) {
		if(l == nil) return(nil);
		if(l.ofKind(Vector)) return(l.toList());
		if(!l.ofKind(List)) return([ l ]);
		return(l);
	}

	// Check a list for the action.
	_checkListFor(action, lst) {
		if((action == nil) || ((lst = _canonicalizeList(lst)) == nil))
			return(nil);
		return(lst.valWhich({ x: action.ofKind(x) || action == x })
			!= nil);
	}

	isSenseAction(action?) {
		return(_checkListFor(_canonicalizeAction(action),
			_senseActions));
	}

	isTravelAction(action?) {
		return(_checkListFor(_canonicalizeAction(action),
			_travelActions));
	}

	// Should return boolean true if we permit the current action
	// to happen (instead of handling/blocking it ourselves).
	// Does nothing by default, can be overwritten by instances/subclasses
	isActionAllowed(action?) {
		return(true);
	}

	// Returns boolean true if the current action will succeed if we
	// do nothing.
	// This is to allow scenes to defer to the "normal" failure messages.
	// For example, if we're writing a scene where Bob is blocking the
	// player's movements, we probably don't want to display a
	// "Bob moves to block your path." message if the player is trying
	// to move in a direction without an exit.
	willCurrentActionSucceed() {
		local t;

		// Make sure we're not recursing.
		if(_testCurrentActionLock == true)
			return(nil);
		_testCurrentActionLock = true;

		// Save the "real" transcript.
		t = gTranscript;

		try {
			// Save the current game state.
			savepoint();

			// Create a new transcript and execute the
			// current command.
			gTranscript = new CommandTranscript();
			executeCommand(gActor, gActor,
				gAction.getOrigTokenList(), true);

			// Return true if the command succeeded, nil
			// otherwise.
			return(!gTranscript.isFailure);
		}
		finally {
			// Revert to the old game state.
			undo();

			// Clear our lock.
			_testCurrentActionLock = nil;

			// Restore the old transcript.
			gTranscript = t;
		}
	}

	// Utility methods for figuring out what other actors the
	// passed actor can sense, excluding any in the optional second
	// arg.  If a sense isn't specified via the third argument, sight
	// is used.
	getSpectator(actor, excludeList?, sense?) {
		local l;

		l = getSpectatorList(actor, excludeList, sense);
		if(l.length() < 1)
			return(nil);
		return(l[1]);
	}

	getSpectatorList(actor, excludeList?, sense?) {
		if(!actor || !actor.roomLocation || !actor.ofKind(Actor))
			return([]);

		return(actor.getVisibleActors(excludeList, sense));
	}
;
