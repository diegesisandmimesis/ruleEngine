#charset "us-ascii"
//
// ruleEngineUser.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleUser: Syslog
	rulebook = perInstance(new LookupTable())

	rulebookMatches = perInstance(new LookupTable())

	rulebookClass = Rulebook

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

		return(true);
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
		r.owner = self;

		// Add it to our rulebook table.
		addRulebook(r);

		return(r);
	}

	// Add a rule to our default rulebook.
	// Used when there's a declaration that puts the rule inside
	// a RuleUser instead of a Rulebook.
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

		_debug('rulebook <q><<toString(id)>></q> matched');

		// Note that the rulebook who called us matched this
		// turn.
		rulebookMatches[id] = libGlobal.totalTurns;
	}

	// Called by Rulebook.callback() by default when the rulebook
	// matches.
	rulebookMatchCallback(id) {
		// Mark the rulebook as matched.
		rulebookMatched(id);

		// Now check to see if all our rulebooks matched, and
		// if so call the rulebook action.
		if(checkRulebookMatches() == true)
			rulebookMatchAction();
	}

	// Returns boolean true if all active rulebooks matched this
	// turn.
	checkRulebookMatches() {
		local i, l;

		l = rulebook.keysToList();
		for(i = 1; i <= l.length(); i++) {
			if(rulebook[l[i]].isActive()
				&& !checkRulebookMatch(l[i]))
				return(nil);
		}

		return(true);
	}

	// Returns boolean true if the given rulebook matched this turn.
	checkRulebookMatch(id?) {
		return(rulebookMatches[(id ? id : 'default')]
			== libGlobal.totalTurns);
	}

	// By default, do nothing.
	rulebookMatchAction() {}
;
