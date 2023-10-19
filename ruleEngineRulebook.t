#charset "us-ascii"
//
// ruleEngineRulebook.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

// Rulebook Base class.
// By default, a rulebook's check() method will return true if all of
// the rules in the rulebook are matched (that is, their individual
// check() methods will all return true).
class Rulebook: Syslog
	syslogID = 'Rulebook'

	// Unique ID for this rulebook
	id = nil

	// By default, rulebooks start active.
	active = true

	// Default value of the rulebook.  By default Rulebook.check()
	// will return nil unless all of its rules match.  Setting
	// default to true will reverse this.
	defaultState = nil

	// Computed state.  This is the cached value of Rulebook.check().
	state = nil

	// Turn number of last time the state was computed.
	timestamp = nil

	callbackTimestamp = nil

	// Property to hold our rules.
	ruleList = nil

	// Flag to indicate rule list has been updated.
	_ruleListDirty = nil

	// RuleUser that owns this rulebook, if any.
	owner = nil

	ruleEngine = nil

	// Getter and setter for the active property.
	isActive() { return(active == true); }
	setActive(v) { active = ((v == true) ? true : nil); }

	// Getter and setter for the state.
	getState() { return(state == true); }
	setState(v?) { state = ((v == true) ? true : nil); }

	// Adds a rule.
	addRule(obj) {
		// Make sure the arg is a rule.
		if((obj == nil) || !obj.ofKind(Rule))
			return(nil);

		// Create a new vector for our rules if we don't have one.
		if(ruleList == nil)
			ruleList = new Vector();

		// Avoid adding a duplicate rule.
		if(ruleList.indexOf(obj) != nil)
			return(nil);

		// Actually add the rule.
		ruleList.append(obj);

		if(ruleEngine != nil)
			ruleEngine.addRule(obj);

		// Mark the rule list as updated.
		_ruleListDirty = true;

		return(true);
	}

	// Remove the given rule from our list.
	removeRule(obj) {
		// Make sure the rule is on the list.
		if(ruleList.indexOf(obj) == nil)
			return(nil);

		// Remove the rule.
		ruleList.removeElement(obj);

		if(ruleEngine != nil)
			ruleEngine.removeRule(obj);

		// Make the rule list as updated.
		_ruleListDirty = true;

		return(true);
	}

	// Method called by RuleUser.
	// Returns the current state, computing it if it hasn't been
	// already computed this turn.
	check() {
		// Check to see if we need to compute the state.
		if(timestamp != libGlobal.totalTurns) {
			// Remember that we computed the state this turn.
			if(gActionIsNested == true)
				timestamp = nil;
			else
				timestamp = libGlobal.totalTurns;

			// Save the current state.
			setState(runCheck());
		}

		// Return the saved state.
		return(getState());
	}

	// Actually evaluate the current state (by checking the individual
	// rules).  Doesn't store the value.
	runCheck() {
		local i;

		// Make sure we have rules to check.
		if(ruleList == nil)
			return(defaultState);

		// Go through the rules, returning immediately if
		// any of them aren't matches.
		for(i = 1; i <= ruleList.length; i++)
			if(ruleList[i].check() != true)
				return(defaultState);

		// All the rules matches, so we return the negation of
		// our default.
		return(!defaultState);
	}

	_callback() {
		if(callbackTimestamp == libGlobal.totalTurns)
			return;
		if(gActionIsNested == true)
			callbackTimestamp == nil;
		else
			callbackTimestamp = libGlobal.totalTurns;
		callback();
	}

	// By default, the callback notifies the rulebook's owner.
	callback() {
		if(owner == nil)
			return;
		owner.rulebookMatchCallback(self.id);
	}

	// Called at preinit.
	initializeRulebook() {
		if((location == nil) || !location.ofKind(RuleUser))
			return;

		location.addRulebook(self);

		owner = location;
	}
;

// A rulebook whose default state is nil, and becomes true if ANY of
// its rules match (their check() method returns true).
class RulebookMatchAny: Rulebook
	defaultState = nil

	runCheck() {
		local i;

		if(ruleList == nil)
			return(defaultState);

		// Go through the rule list and if any rules match,
		// return the negation of the default state.
		for(i = 1; i <= ruleList.length; i++)
			if(ruleList[i].check() == true)
				return(!defaultState);

		// None of the rules matched, return the default state.
		return(defaultState);
	}
;

// A rulebook whose default state is nil, and becomes true if all of
// the rules are matched.  This is identical to the base class, but the
// more verbosely-named subclass is provided for completeness.
class RulebookMatchAll: Rulebook;

// A rulebook whose default state is true, and becomes nil if ANY of
// its rules are matched.
class RulebookMatchNone: RulebookMatchAny
	defaultState = true
;

// A rulebook that "locks" the first time its state changes from the default.
class RulebookPermanent: Rulebook
	// Is the state locked?
	locked = nil

	// Updated check() method.
	check() {
		local v;

		// If the state is locked, we just return the existing state.
		if(locked == true)
			return(getState());

		// We're not locked, so we check the current state, using
		// the inherited check() logic.
		// If the current state is the default state, we just return
		// it.
		if((v = inherited()) == defaultState)
			return(v);

		// If we reach here, the current state is no longer the
		// default state, so we lock the state.
		lockState();

		// Return the state (which will always be !defaultState).
		return(v);
	}

	// Finialize our state.
	lockState() {
		// Set the locked flag.
		locked = true;

		// If we're owned by a 
		if(owner != nil)
			owner.disableRulebook(self);
	}
;
