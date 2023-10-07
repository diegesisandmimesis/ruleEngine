#charset "us-ascii"
//
// ruleEngineRulebook.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class Rulebook: Syslog
	syslogID = 'Rulebook'

	id = nil

	active = nil

	ruleList = nil
	_ruleListDirty = nil

	timestamp = nil

	owner = nil

	_checkCache = nil

	isActive() { return(active == true); }
	setActive(v) { active = ((v == true) ? true : nil); }

	isAvailable() { return(!isActive()); }

	addRule(obj) {
		if((obj == nil) || !obj.ofKind(Rule))
			return(nil);

		if(ruleList == nil)
			ruleList = new Vector();

		if(ruleList.indexOf(obj) != nil)
			return(nil);

		ruleList.append(obj);

		_ruleListDirty = true;

		return(true);
	}

	removeRule(obj) {
		if(ruleList.indexOf(obj) == nil)
			return(nil);

		ruleList.removeElement(obj);

		_ruleListDirty = true;

		return(true);
	}

	check() {
		if(timestamp == libGlobal.totalTurns)
			return(_checkCache);

		timestamp = libGlobal.totalTurns;

		return(_checkCache = _runCheck());
	}

	_runCheck() {
		local i;

		if(ruleList == nil)
			return(nil);

		for(i = 1; i <= ruleList.length; i++)
			if(ruleList[i].check() != true)
				return(nil);

		return(true);
	}

	// By default, do nothing.
	callback() {}

	initializeRulebook() {
		if((location == nil) || !location.ofKind(RuleUser))
			return;

		location.addRulebook(self);

		owner = location;
	}
;
