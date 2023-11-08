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
class Rulebook: RuleEngineObject
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

	// RuleSystem that owns this rulebook, if any.
	ruleSystem = nil

	// Getter and setter for the active property.
	isActive() { return(active == true); }
	setActive(v) { active = ((v == true) ? true : nil); }

	// Getter and setter for the state.
	getState() { return(state == true); }
	setState(v?) {
		if(gActionIsNested == true)
			timestamp = nil;
		else
			timestamp = libGlobal.totalTurns;
		state = ((v == true) ? true : nil);
	}

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

		obj.rulebook = self;

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

		// Make the rule list as updated.
		_ruleListDirty = true;

		return(true);
	}

	tryCheck(type?) {
		if(type == eRuleBeforeAction)
			return(runCheck(Trigger) != defaultState);

		return(check());
	}

	// Method called by RuleSystem.
	// Returns the current state, computing it if it hasn't been
	// already computed this turn.
	check() {
		// Check to see if we need to compute the state.
		if((gActionIsNested == true)
			|| (timestamp != libGlobal.totalTurns))
			setState(runCheck());

		// Return the saved state.
		return(getState());
	}

	// Actually evaluate the current state (by checking the individual
	// rules).  Doesn't store the value.
	runCheck(type?) {
		local i;

		// Make sure we have rules to check.
		if(ruleList == nil)
			return(defaultState);

		// Go through the rules, returning immediately if
		// any of them aren't matches.
		for(i = 1; i <= ruleList.length; i++)
			if(ruleList[i].check(type) != true)
				return(defaultState);

		// All the rules matches, so we return the negation of
		// our default.
		return(!defaultState);
	}

	// By default, we only run the callback once per turn.
	tryCallback() {
		if((gActionIsNested != true)
			&& (callbackTimestamp == libGlobal.totalTurns))
			return;
			
		if(gActionIsNested == true)
			callbackTimestamp = nil;
		else
			callbackTimestamp = libGlobal.totalTurns;

		callback();
	}

	// By default, the callback notifies the rulebook's ruleSystem.
	callback() {
		if(ruleSystem == nil)
			return;
		ruleSystem.rulebookMatchCallback(self.id);
	}

	// Called at preinit.
	initializeRulebook() {
		_initializeRulebookLocation();
		return(true);
	}

	_tryRuleSystem(obj) {
		if((obj == nil) || !obj.ofKind(RuleSystem))
			return(nil);
		return(obj.addRulebook(self));
	}

	_initializeRulebookLocation() {
		if(_tryRuleSystem(ruleSystem) == true)
			return;
		if(_tryRuleSystem(location) == true)
			return;
		_error('orphaned rulebook');
	}

	validateRulebook() {
		return((ruleSystem != nil) && ruleSystem.ofKind(RuleSystem));
	}
;

// A rulebook whose default state is nil, and becomes true if ANY of
// its rules match (their check() method returns true).
class RulebookMatchAny: Rulebook
	defaultState = nil

	runCheck(type?) {
		local i;

		if(ruleList == nil)
			return(defaultState);

		// Go through the rule list and if any rules match,
		// return the negation of the default state.
		for(i = 1; i <= ruleList.length; i++)
			if(ruleList[i].check(type) == true)
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
