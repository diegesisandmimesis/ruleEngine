#charset "us-ascii"
//
// ruleEngineScheduler.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleSchedulerDaemon: RuleEngineObject
	_ruleSchedulerDaemon = nil

	initRuleSchedulerDaemon() {
		_ruleSchedulerDaemon = new Daemon(self,
			&updateRuleScheduler, 1);
	}

	updateRuleScheduler() {}
;

class RuleSchedulerBase: RuleEngineObject
	syslogID = 'RuleScheduler'

	_ruleEngineList = perInstance(new Vector())

	addRuleEngine(obj) {
		if((obj == nil) || !obj.ofKind(RuleEngine))
			return(nil);

		if(_ruleEngineList.indexOf(obj) != nil)
			return(nil);

		_ruleEngineList.append(obj);

		obj.ruleScheduler = self;

		return(true);
	}

	removeRuleEngine(obj) {
		if(obj == nil)
			return(nil);

		if(_ruleEngineList.indexOf(obj) == nil)
			return(nil);

		_ruleEngineList.removeElement(obj);

		return(true);
	}

	ruleSchedulerBeforeAction() {
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineBeforeAction();
		});
	}

	ruleSchedulerAfterAction() {
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineAfterAction();
		});
	}

	ruleSchedulerAction() {
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineAction();
		});
	}
;

class RuleScheduler: RuleSchedulerBase, RuleSchedulerDaemon, BeforeAfterThing, PreinitObject
	// Called at preinit.
	execute() { initRuleSchedulerDaemon(); }

	// Called every turn in the beforeAction() window.
	globalBeforeAction() { ruleSchedulerBeforeAction(); }

	// Called every turn in the afterAction() window.
	globalAfterAction() { ruleSchedulerAfterAction(); }

	// Called every turn by our daemon, after action resolution.
	updateRuleScheduler() { ruleSchedulerAction(); }
;

class RuleSchedulerRoom: Room, RuleSchedulerBase
	roomBeforeAction() {
		inherited();
		ruleSchedulerBeforeAction();
	}
	roomAfterAction() {
		inherited();
		ruleSchedulerAfterAction();
	}
	roomDaemon() {
		inherited();
		ruleSchedulerAction();
	}
;

class RuleSchedulerThing: Thing, RuleSchedulerBase, RuleSchedulerDaemon
	beforeAction() {
		inherited();
		ruleSchedulerBeforeAction();
	}
	afterAction() {
		inherited();
		ruleSchedulerAfterAction();
	}
	updateRuleScheduler() {
		inherited();
		ruleSchedulerAction();
	}
	initialzeThing() {
		inherited();
		initRuleSchedulerDaemon();
	}
;

globalRuleScheduler: RuleScheduler;
