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

class RuleScheduler: RuleEngineObject, PreinitObject
	syslogID = 'RuleScheduler'

	// Boolean flag.  If true, the scheduler won't run on
	// turns where the action is a SystemAction.
	// Default is true.
	//skipSystemActions = true
	skipSystemActions = nil

	// A list of all the rule engines we're managing.
	_ruleEngineList = perInstance(new Vector())

	// Our daemon instance, if any.
	_ruleSchedulerDaemon = nil

	// Create a once-per turn daemon.
	initRuleSchedulerDaemon() {
		_ruleSchedulerDaemon = new Daemon(self,
			&updateRuleScheduler, 1);
	}

	// Called at preinit.
	execute() {
		// Rooms don't need daemons and Things don't start theirs here.
		if(ofKind(Room) || ofKind(Thing))
			return;

		// Set up the daemon.
		initRuleSchedulerDaemon();

		// Subscribe to before/after notifications.
		gSubscribeBeforeAfter(self);
	}

	initializeThing() {
		inherited();
		if(ofKind(Room))
			return;
		initRuleSchedulerDaemon();
	}

	// For Rooms.
	roomBeforeAction() { inherited(); ruleSchedulerBeforeAction(); }
	roomAfterAction() { inherited(); ruleSchedulerAfterAction(); }
	roomDaemon() { inherited(); ruleSchedulerAction(); }

	// For Things.
	beforeAction() { inherited(); ruleSchedulerBeforeAction(); }
	afterAction() { inherited(); ruleSchedulerAfterAction(); }

	// For global schedulers.
	globalBeforeAction() { ruleSchedulerBeforeAction(); }
	globalAfterAction() { ruleSchedulerAfterAction(); }

	// For Things and global schedulers.
	updateRuleScheduler() { inherited(); ruleSchedulerAction(); }

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

	// Returns boolean true if we're configured to skip system actions
	// and the current gAction is a system action.
	_skipSystemAction() {
		return((skipSystemActions == true) && (gAction != nil)
			&& gAction.ofKind(SystemAction));
	}

	_skipEventAction() {
		//return((gAction != nil) && gAction.ofKind(EventAction));
		return(nil);
	}

	// Method called in the beforeAction() window.
	ruleSchedulerBeforeAction() {
		if(_skipEventAction() || _skipSystemAction())
			return;
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineBeforeAction();
		});
	}

	// Method called in the afterAction() window.
	ruleSchedulerAfterAction() {
		if(_skipEventAction() || _skipSystemAction())
			return;
		_ruleEngineList.forEach(function(o) {
			o.ruleEngineAfterAction();
		});
	}

	// Method called after action resolution.
	ruleSchedulerAction() {
		if(_skipEventAction() || _skipSystemAction())
			return;

		_ruleEngineList.forEach(function(o) {
			o.ruleEngineAction();
		});
	}
;

// We define a global singleton to handle "default global" rule engines.
globalRuleScheduler: RuleScheduler;
