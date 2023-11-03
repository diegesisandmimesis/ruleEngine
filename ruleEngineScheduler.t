#charset "us-ascii"
//
// ruleEngineScheduler.t
//
//	Classes that handle pinging rule engine instances at the
//	appropriate times in the turn lifecycle.
//
//	Each rule engine gets notified during the beforeAction() window,
//	the afterAction() window, and after action resolution when
//	Daemons are updated.  There are several different ways all of this
//	can happen, depending on what scope(s) the rule engines want to
//	recieve notifications in.
//
//	The RuleScheduler class notifies all subscribed rule engines
//	every turn, independent of scope.  The RuleSchedulerRoom is a
//	mixin for rooms, and only appies to the room's native scope.
//	The RuleSchedulerThing is a mixin for Thing, and applies to the
//	Thing's scope.
//
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleSchedulerBase: RuleEngineObject
	syslogID = 'RuleScheduler'

	// A list of all the rule engines we're managing.
	_ruleEngineList = perInstance(new Vector())

	// Add a rule engine.
	addRuleEngine(obj) {
		// Make sure the arg is a valid rule engine.
		if((obj == nil) || !obj.ofKind(RuleEngine))
			return(nil);

		// Make sure it isn't already on the list.
		if(_ruleEngineList.indexOf(obj) != nil)
			return(nil);

		// Add the engine.
		_ruleEngineList.append(obj);

		// Have the engine remember we're its scheduler.
		obj.ruleScheduler = self;

		return(true);
	}

	// Remove a rule engine from our list.
	removeRuleEngine(obj) {
		if(obj == nil)
			return(nil);

		if(_ruleEngineList.indexOf(obj) == nil)
			return(nil);

		_ruleEngineList.removeElement(obj);

		return(true);
	}

	// Method called in the beforeAction() window.
	ruleSchedulerBeforeAction() {
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineBeforeAction();
		});
	}

	// Method called in the afterAction() window.
	ruleSchedulerAfterAction() {
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineAfterAction();
		});
	}

	// Method called after action resolution.
	ruleSchedulerAction() {
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineAction();
		});
	}
;

// Mixin class for schedulers that need a daemon.
class RuleSchedulerDaemon: RuleEngineObject
	_ruleSchedulerDaemon = nil

	initRuleSchedulerDaemon() {
		_ruleSchedulerDaemon = new Daemon(self,
			&updateRuleScheduler, 1);
	}

	updateRuleScheduler() {}
;

// Scheduler that has global scope.
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

// Scheduler for a single room scope.
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

// Scheduler for the scope of an in-game object.
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

// We define a global singleton to handle "default global" rule engines.
globalRuleScheduler: RuleScheduler;
