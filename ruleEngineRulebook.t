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

	rulebookType = nil

	// Property to hold our rules.
	ruleList = nil

	beforeActionRuleList = nil
	afterActionRuleList = nil

	_beforeActionFlag = nil
	_afterActionFlag = nil

	_beforeActionState = nil
	_afterActionState = nil

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
			timestamp = gTimestamp;
		state = ((v == true) ? true : nil);
	}

	// Adds a rule.
	addRule(obj) {
		local l;

		// Make sure the arg is a rule.
		if((obj == nil) || !obj.ofKind(Rule)) {
			return(nil);
		}

		if(obj.ofKind(BeforeActionRule)) {
			if(beforeActionRuleList == nil)
				beforeActionRuleList = new Vector();
			l = beforeActionRuleList;
		} else {
			if(afterActionRuleList == nil)
				afterActionRuleList = new Vector();
			l = afterActionRuleList;
		}

/*
		// Create a new vector for our rules if we don't have one.
		if(ruleList == nil)
			ruleList = new Vector();
*/

		// Avoid adding a duplicate rule.
		if(l.indexOf(obj) != nil) {
			return(nil);
		}

		// Actually add the rule.
		l.append(obj);

		obj.rulebook = self;

		// Mark the rule list as updated.
		_ruleListDirty = true;

		return(true);
	}

	// Remove the given rule from our list.
	removeRule(obj) {
		local l;

		if(obj.ofKind(AfterActionRule))
			l = afterActionRuleList;
		else
			l = beforeActionRuleList;

		// Make sure the rule is on the list.
		if(l.indexOf(obj) == nil)
			return(nil);

		// Remove the rule.
		l.removeElement(obj);

		// Make the rule list as updated.
		_ruleListDirty = true;

		return(true);
	}

	tryCheck(type?) {
		switch(type) {
			case eRuleBeforeAction:
				return(tryBeforeActionCheck() == defaultState);
			case eRuleAfterAction:
				return(tryAfterActionCheck() == defaultState);
			default:
				return(nil);
		}
	}

	_resetStates() {
		_beforeActionFlag = nil;
		_afterActionFlag = nil;
		_beforeActionState = defaultState;
		_afterActionState = defaultState;
	}

	tryBeforeActionCheck() {
		_resetStates();
		_beforeActionState = runBeforeActionCheck();

		if(afterActionRuleList == nil) {
			return(_beforeActionState);
		}

		return(nil);
	}

	tryAfterActionCheck() {
		_afterActionState = runAfterActionCheck();
		if(beforeActionRuleList == nil) {
			return(_afterActionState);
		}

		return(_afterActionState && _beforeActionState);
	}
/*
	tryCheck(type?) {
		if(type == eRuleBeforeAction) {
			return(runCheck(Trigger) != defaultState);
		}

		return(check());
	}
*/

	runBeforeActionCheck() {
		local i;

		_beforeActionFlag = true;

		if(beforeActionRuleList == nil)
			return(defaultState);

		for(i = 1; i <= beforeActionRuleList.length; i++) {
			if(beforeActionRuleList[i].check(Rule) != true)
				return(defaultState);
		}

		return(!defaultState);
	}

	runAfterActionCheck() {
		local i;

		_afterActionFlag = true;

		if(afterActionRuleList == nil)
			return(defaultState);

		for(i = 1; i <= afterActionRuleList.length; i++) {
			if(afterActionRuleList[i].check(Rule) != true)
				return(defaultState);
		}

		return(!defaultState);
	}

	isCheckNeeded(val) {
		return((gActionIsNested == true)
			|| !gCheckTimestamp(val));
			//|| (val != gTimestamp));
	}

/*
	// Method called by RuleSystem.
	// Returns the current state, computing it if it hasn't been
	// already computed this turn.
	check() {
		// Check to see if we need to compute the state.
		if(isCheckNeeded(timestamp))
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
*/

	// By default, we only run the callback once per turn.
	tryCallback(type?) {
		if(!isCheckNeeded(callbackTimestamp))
			return;
			
		if(gActionIsNested == true)
			callbackTimestamp = nil;
		else
			callbackTimestamp = gTimestamp;

		callback();
	}

	// By default, the callback notifies the rulebook's ruleSystem.
	callback(type?) {
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

/*
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
*/

	runBeforeActionCheck() {
		local i;

		if(_beforeActionFlag)
			return(_beforeActionState);

		_beforeActionFlag = true;

		if(beforeActionRuleList == nil)
			return(defaultState);

		for(i = 1; i <= beforeActionRuleList.length; i++) {
			if(beforeActionRuleList[i].check(Rule) == true)
				return(!defaultState);
		}

		return(defaultState);
	}

	runAfterActionCheck() {
		local i;

		if(_afterActionFlag)
			return(_afterActionState);

		_afterActionFlag = true;

		if(afterActionRuleList == nil)
			return(defaultState);

		for(i = 1; i <= afterActionRuleList.length; i++) {
			if(afterActionRuleList[i].check(Rule) == true)
				return(!defaultState);
		}

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
