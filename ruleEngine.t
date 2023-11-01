#charset "us-ascii"
//
// ruleEngine.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

ruleEnginePreinit: PreinitObject
	syslogID = 'ruleEnginePreinit'

	// Called at preinit.
	execute() {
		initRules();
		initRulebooks();
		initRuleSystems();
	}

	// Initialize all Rule instances and add them to our list.
	initRules() {
		forEachInstance(Rule, function(o) {
			o.initializeRule();
		});
	}

	// Initialize all Rulebook instances and add them to our list.
	initRulebooks() {
		forEachInstance(Rulebook, function(o) {
			o.initializeRulebook();
		});
	}

	// Initialize all Rulebook instances and add them to our list.
	initRuleSystems() {
		forEachInstance(RuleSystem, function(o) {
			o.initializeRuleSystem();
		});
	}

;

// The engine class.  It subscribes for notifications before and after
// every action, as well as running a daemon to be polled every turn
// after action resolution.
class RuleEngine: RuleEngineObject, BeforeAfterThing, PreinitObject
	syslogID = 'RuleEngine'
	syslogFlag = 'RuleEngine'

	// List of all RuleSystem instances we need to update.
	_ruleSystemList = perInstance(new Vector())

	// Daemon that pings us every turn.
	_ruleDaemon = nil

	// Called at preinit.
	execute() {
		initRuleEngineDaemon();
	}

	// Create our daemon.
	initRuleEngineDaemon() {
		_ruleDaemon = new Daemon(self, &updateRuleEngine, 1);
	}

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

	// Called every turn in the beforeAction() window.
	globalBeforeAction() { _ruleSystemBeforeAction(); }

	// Called every turn in the afterAction() window.
	globalAfterAction() { _ruleSystemAfterAction(); }

	// Called every turn by our daemon, after action resolution.
	updateRuleEngine() { _ruleSystemAction(); }

	_ruleSystemBeforeAction() {
		_ruleSystemList.forEach(function(o) {
			o.ruleSystemBeforeAction();
		});
	}

	_ruleSystemAfterAction() {
		_ruleSystemList.forEach(function(o) {
			o.ruleSystemAfterAction();
		});
	}

	_ruleSystemAction() {
		_ruleSystemList.forEach(function(o) { o.ruleSystemAction(); });
	}
;
