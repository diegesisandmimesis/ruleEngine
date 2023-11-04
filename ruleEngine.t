#charset "us-ascii"
//
// ruleEngine.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngine: RuleEngineObject
	syslogID = 'RuleEngine'
	syslogFlag = 'RuleEngine'

	ruleScheduler = nil

	// List of all RuleSystem instances we need to update.
	_ruleSystemList = perInstance(new Vector())

	addRuleSystem(obj) {
		if((obj == nil) || !obj.ofKind(RuleSystem))
			return(nil);

		if(_ruleSystemList.indexOf(obj) != nil)
			return(nil);

		_ruleSystemList.append(obj);

		return(true);
	}

	removeRuleSystem(obj) {
		if(obj == nil)
			return(nil);

		if(_ruleSystemList.indexOf(obj) == nil)
			return(nil);

		_ruleSystemList.removeElement(obj);

		return(true);
	}

	ruleEngineBeforeAction() {
		_ruleSystemList.forEach(function(o) {
			o.ruleSystemBeforeAction();
		});
	}

	ruleEngineAfterAction() {
		_ruleSystemList.forEach(function(o) {
			o.ruleSystemAfterAction();
		});
	}

	ruleEngineAction() {
		_ruleSystemList.forEach(function(o) { o.ruleSystemAction(); });
	}

	_tryRuleScheduler(obj) {
		if((obj == nil) || !obj.ofKind(RuleScheduler))
			return(nil);
		return(obj.addRuleEngine(self));
	}

	initializeRuleEngine() {
		if(_tryRuleScheduler(ruleScheduler) == true)
			return;
		if(_tryRuleScheduler(location) == true)
			return;
		_tryRuleScheduler(gRuleScheduler);
	}
;
