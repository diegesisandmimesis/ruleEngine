#charset "us-ascii"
//
// ruleEngineRuleSystem.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleSystem: RuleEngineObject
	syslogID =  'RuleSystem'

	// Hash table of our rulebooks, keyed by rulebook ID.
	rulebook = perInstance(new LookupTable())

	// Hash table of rulebooks that are disabled.  These are
	// rulebooks whose state we wish to preserve but no longer update.
	disabledRulebook = perInstance(new LookupTable())

	// Hash table of rulebook matches, keyed by rulebook ID, values
	// are the turn number of the last turn the rulebook matched.
	rulebookMatches = perInstance(new LookupTable())

	// Class to use for rulebook instances.
	rulebookClass = Rulebook

	// Arbitrary index for rulebooks.  Used to create a rulebook ID
	// if one isn't declared in the rulebook definition.
	_rulebookIdx = 0

	// Add the argument to our list of rulebooks.
	addRulebook(obj) {
		// Make sure the arg is a rulebook.
		if(!obj || !obj.ofKind(rulebookClass))
			return(nil);

		// If the rulebook has no ID defined, create one for it.
		if(obj.id == nil)
			obj.id = (_rulebookIdx += 1);

		// Add it to our rulebook table.
		rulebook[obj.id] = obj;

		if(ruleEngine != nil)
			ruleEngine.addRulebook(obj);

		return(true);
	}

	removeRulebook(obj) {
		if(obj == nil)
			return(nil);
		if(rulebook[obj.id] == nil)
			return(nil);

		rulebook.removeElement(obj.id);

		if(ruleEngine != nil)
			ruleEngine.removeRulebook(obj);

		return(true);
	}

	// Disable a rulebook.  This removes it from our rulebook list
	// (and the RuleEngine's rulebook list), which means it will no
	// longer be updated.  But we keep a reference to it, so it won't
	// be garbage collected, allowing us to refer to the state later.
	disableRulebook(obj) {
		if(obj == nil) return(nil);
		disabledRulebook[obj.id] = obj;
		return(removeRulebook(obj));
	}

	enableRulebook(obj) {
		if(obj == nil) return(nil);
		disabledRulebook.removeElement(obj.id);
		return(addRulebook(obj));
	}

	disableRulebookByID(id) {
		local obj;

		if((obj = rulebook[id]) == nil)
			return(nil);

		return(disableRulebook(obj));
	}

	enableRulebookByID(id) {
		local obj;

		if((obj = disabledRulebook[id]) == nil)
			return(nil);

		return(enableRulebook(obj));
	}

	// Disable all our rulebooks.
	disableAllRulebooks() {
		local l;

		l = rulebook.keysToList();
		l.forEach(function(o) {
			disableRulebook(rulebook[o]);
		});
	}

	// Enable all our disabled rulebooks.
	enableAllRulebooks() {
		local l;

		l = disabledRulebook.keysToList();
		l.forEach(function(o) {
			enableRulebook(disabledRulebook[o]);
		});
	}

	// Returns the given rulebook.
	getRulebook(id?) { return(rulebook[(id ? id : 'default')]); }

	// Creates a new rulebook.  In practice this is probably never used
	// for anything other than creating a default rulebook if one isn't
	// explicitly declared.
	newRulebook(id?) {
		local r;

		// Create the instance.
		r = rulebookClass.createInstance();

		// Make sure it has an ID.
		r.id = (id ? id : 'default');

		// Make us the owner.
		r.ruleSystem = self;

		// Add it to our rulebook table.
		addRulebook(r);

		return(r);
	}

	// Add a rule to our default rulebook.
	// Used when there's a declaration that puts the rule inside
	// a RuleSystem instead of a Rulebook.
	addRule(obj) {
		local r;

		// Make sure the arg is a rule.
		if((obj == nil) || !obj.ofKind(Rule))
			return(nil);

		// Get the default rulebook, creating it if necessary.
		if((r = getRulebook()) == nil)
			r = newRulebook();

		// Add the rule.
		return(r.addRule(obj));
	}

	removeRule(obj) {
		local r;

		if(obj == nil)
			return(nil);

		if((r = getRulebook()) == nil)
			return(nil);

		return(r.removeRule(obj));
	}

	// Boolean true if we have more than zero rulebooks.
	haveRules() { return(rulebook.keysToList().length > 0); }

	// Returns boolean true if all the rulebooks are matched this
	// turn.
	matchAllRulebooks() {
		local i, l;

		l = rulebook.keysToList();
		for(i = 1; i <= l.length(); i++) {
			if(rulebook[l[i]].isActive
				&& (rulebook[l[i]].check() != true))
				return(nil);
		}

		return(true);
	}

	// Returns boolean true if the given rulebook is active and
	// matched this turn.
	checkRulebook(id?) {
		local r;

		if((r = getRulebook(id)) == nil)
			return(nil);

		return(r.isActive() && r.check());
	}

	// Remember that the rulebook with the given ID matched this turn.
	rulebookMatched(id) {
		// Make sure we have an ID.
		if(id == nil)
			return;

		// Note that the rulebook who called us matched this
		// turn.
		rulebookMatches[id] = libGlobal.totalTurns;
	}

	// Called by Rulebook.callback() by default when the rulebook
	// matches.
	rulebookMatchCallback(id) {
		// Mark the rulebook as matched.
		rulebookMatched(id);

		rulebookMatchAction(id);
	}

	// Returns boolean true if all active rulebooks matched this
	// turn.
	allRulebooksMatched() {
		local i, l;

		l = rulebook.keysToList();
		for(i = 1; i <= l.length(); i++) {
			if(rulebook[l[i]].isActive()
				&& !checkRulebookMatch(l[i]))
				return(nil);
		}

		return(true);
	}

	anyRulebookMatched() {
		local i, l;

		l = rulebook.keysToList();
		for(i = 1; i <= l.length(); i++) {
			if(rulebook[l[i]].isActive()
				&& checkRulebookMatch(l[i]))
				return(true);
		}

		return(nil);
	}

	noRulebooksMatched() {
		local i, l;

		l = rulebook.keysToList();
		for(i = 1; i <= l.length(); i++) {
			if(rulebook[l[i]].isActive()
				&& checkRulebookMatch(l[i]))
				return(nil);
		}

		return(true);
	}

	// Returns boolean true if the given rulebook matched this turn.
	checkRulebookMatch(id?) {
		return(rulebookMatches[(id ? id : 'default')]
			== libGlobal.totalTurns);
	}

	enableRuleSystem() {
		enableAllRulebooks();
		if(ruleEngine != nil)
			return(ruleEngine.addRuleSystem(self));
		return(true);
	}

	disableRuleSystem() {
		disableAllRulebooks();
		if(ruleEngine != nil)
			return(ruleEngine.removeRuleSystem(self));
		return(true);
	}


	// By default, do nothing.
	rulebookMatchAction(id) {}

	// Called at prinit.  By default, do nothing.
	initializeRuleSystem() {
/*
		if(getRuleEngineFlag() == true)
			return(nil);
		setRuleEngineFlag();
*/
		_initializeRuleSystemLocation();
		return(true);
	}

	_initializeRuleSystemLocation() {
		if((location == nil) || !location.ofKind(RuleEngine))
			return(nil);
		location.addRuleSystem(self);
		return(true);
	}

	_updateRulebooks(type?) {
		rulebook.forEachAssoc(function(key, val) {
			if(val.tryCheck(type) == true)
				val.tryCallback();
		});
	}

	_rulebookBeforeAction() { _updateRulebooks(eRuleBeforeAction); }
	_rulebookAfterAction() { _updateRulebooks(eRuleAfterAction); }

	ruleSystemBeforeAction() {
		_rulebookBeforeAction();
		tryBeforeAction();
	}

	ruleSystemAfterAction() {
		_rulebookAfterAction();
		tryAfterAction();
	}

	ruleSystemAction() {
		tryAction();
	}

	tryBeforeAction() {}
	tryAfterAction() {}
	tryAction() {}
;
