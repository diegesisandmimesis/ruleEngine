#charset "us-ascii"
//
// ruleEngine.t
//
//	A simple rule engine for TADS3.
//
//	The module provides four main abstract classes:
//
//		Rule
//			A rule implements a state check of some sort,
//			providing a method that returns boolean true if
//			the conditions are currently met, nil otherwise.
//
//		Rulebook
//			A rulebook is an abstract container for one or
//			more rules, providing a method that returns boolean
//			true if the rules currently satisfy some condition.
//
//			By default a rulebook "matches" when ALL of its
//			rules individually "match", but subclasses define
//			other behaviors (matching when ANY of the rules
//			match, or matching when NONE of the rules match).
//
//		RuleEngine
//			The controller that takes care of automatically
//			polling all the rules and rulebooks every turn.
//
//		RuleUser
//			A mixin class for objects that want to use
//			rulebooks.  The state of a RuleUser instance's
//			rulebooks can be checked "manually", or it can
//			be updated automatically by its rulebook(s) (for
//			example by invoking a callback method when the
//			rulebook evaluates as "matched" for the turn).
//
//
// THE Rule CLASS
//
//	In general, the "meat" of any Rule instance will be in its
//	matchRule() method.  Here's a simple Rule declaration:
//
//		// Declare an anonymous Rule instance
//		Rule
//			matchRule(data?) {
//				return(someObject.someProperty == someValue);
//			}
//		;
//
//	This will create a rule that matches when someObject.someProperty
//	is equal to someValue.
//
//	You can put anything you want into the matchRule() method, but it
//	MUST return boolean true if you want it to match--true-ish values (like
//	non-zero numeric values) will not be recognized as a match.
//
//	In general, rules will want to be declared with the +Rule syntax,
//	adding them to either a RuleUser instance or a Rulebook instance.
//
//
// The Rulebook CLASS
//
//	Each rulebook consists of a default state and a list of rules.
//
//	There are several different subclasses of rulebook with different
//	default states and rule matching behaviors:
//
//		Rulebook and RulebookMatchAll
//			The base Rulebook class is identical to the
//			RulebookMatchAll class.
//
//			The default state of these rulebooks is nil, and
//			the state becomes true only if all of their rules
//			match.
//
//		RulebookMatchAny
//			This type of rulebook has a default state of nil,
//			and the state becomes true if any of the rulebook's
//			rules match.
//
//		RulebookMatchNone
//			This type of rulebook has a default state of true,
//			and the state becomes nil if any of the rulebook's
//			rules match.
//
//	When a rulebook's state is true for a turn, its callback() method will
//	be called (by the RuleEngine._updateRulebooks()).
//
//	By default, Rulebook.callback() will call the rulebook owner's
//	rulebookMatchCallback() method with the matching rulebook's ID as
//	the argument.  If the rulebook has no owner, or if the owner is not
//	an instance of RuleUser, no action will be taken.
//
//
// The RuleUser CLASS
//
//	The RuleUser class is intended to be a mixin for other types of
//	game objects that want to use rulebooks.
//
//	In general an instance's custom rule-handling logic probably wants
//	to go into rulebookMatchAction().  It gets called automatically
//	by any rulebook belonging to this RuleUser instance whose state is
//	true for this turn.  The argument is the matching rulebook's ID:
//
//		// Custom rule handling goes in here.
//		// The argument is the matching rulebook's ID.
//		rulebookMatchAction(id) {
//			// Whatever
//		}
//
//
// THE RuleEngine CLASS
//
//	Each game using rules needs to declare a RuleEngine instance.  It
//	will automatically take care of updating rules and rulebooks.
//
//	In most cases all you'll need to do is declare the instance:
//
//		// Declare a RuleEngine instance
//		myRuleEngine: RuleEngine;
//
//
// RULE LIFECYCLE
//
//	The rule logic is updated at three points in each turn:
//
//		beforeAction()
//			The RuleEngine class subscribes to before and
//			after action notifications via the mechanism
//			provided by the beforeAfter module.  This leads
//			to RuleEngine.globalBeforeAction() to be called
//			before each action is resolved.
//
//			In this window, RuleEngine checks the state of
//			all Rule instances.  After doing this, it evaluates
//			the state of all Rulebook instances.  Doing this
//			will automatically update the RuleUser instances
//			that own Rulebooks whose state is true for this
//			turn.
//
//		afterAction()
//			RuleEngine.globalAfterAction() is called via the
//			same beforeAfter mechanism described above.
//
//			By default this does nothing, but subclasses
//			of RuleEngine (like Scene, provided by the scene
//			module) can use this as a hook for adding their
//			own logic.
//
//		Daemon update
//			RuleEngine.updateRuleEngine() is called by its
//			daemon.  This happens after the action for the
//			turn is resolved, in the same window as all other
//			daemons are fired.
//
//			By default this does nothing, but subclasses can
//			use updateRuleEngine() to implement their own
//			logic.
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

// Module ID for the library
ruleEngineModuleID: ModuleID {
        name = 'Rule Engine Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Base object class for everything in the module.
// Just a hook for the debugging stuff.
class RuleEngineObject: Syslog
	syslogID = 'RuleEngineObject'
	syslogFlag = 'ruleEngine'

	construct(cfg?) {
		if(cfg == nil) cfg = object {};
		cfg.getPropList().forEach(function(o) {
			if(!cfg.propDefined(o, PropDefDirectly))
				return;
			if(!self.propDefined(o))
				return;
			self.(o) = cfg.(o);
		});
	}
;

// The engine class.  It subscribes for notifications before and after
// every action, as well as running a daemon to be polled every turn
// after action resolution.
class RuleEngineBase: RuleEngineObject, BeforeAfterThing, PreinitObject
	syslogID = 'RuleEngine'
	syslogFlag = 'RuleEngine'

	// List of all the Rulebook instances.
	_rulebookList = perInstance(new Vector())

	// List of all the Rule instances.
	_ruleList = perInstance(new Vector())

	// List of all RuleUser instances we need to update.
	_ruleUserList = perInstance(new Vector())

	// Daemon that pings us every turn.
	_ruleDaemon = nil

	// Called at preinit.
	execute() {
		initRules();
		initRulebooks();
		initRuleUsers();
		initRuleEngineDaemon();
	}

	// Initialize all Rule instances and add them to our list.
	initRules() {
		forEachInstance(Rule, function(o) {
			o.initializeRule();
			o.ruleEngine = self;
			_ruleList.append(o);
		});
		_syslog('initialized <<toString(_ruleList.length)>> rules');
	}

	// Initialize all Rulebook instances and add them to our list.
	initRulebooks() {
		forEachInstance(Rulebook, function(o) {
			o.initializeRulebook();
			o.ruleEngine = self;
			_rulebookList.append(o);
		});
		_syslog('initialized <<toString(_rulebookList.length)>>
			rulebooks');
	}

	// Initialize all Rulebook instances and add them to our list.
	initRuleUsers() {
		forEachInstance(RuleUser, function(o) {
			o.ruleEngine = self;
			o.initializeRuleUser();
			_ruleUserList.append(o);
		});
	}

	// Create our daemon.
	initRuleEngineDaemon() {
		_ruleDaemon = new Daemon(self, &updateRuleEngine, 1);
	}

	addRule(obj) {
		if((obj == nil) || !obj.ofKind(Rule))
			return(nil);

		if(_ruleList == nil)
			return(nil);

		if(_ruleList.indexOf(obj) != nil)
			return(nil);

		_ruleList.append(obj);

		return(true);
	}

	removeRule(obj) {
		if(obj == nil)
			return(nil);

		if(_ruleList == nil)
			return(nil);

		if(_ruleList.indexOf(obj) == nil)
			return(nil);

		_ruleList.removeElement(obj);

		return(true);
	}

	addRulebook(obj) {
		if((obj == nil) || !obj.ofKind(Rulebook))
			return(nil);

		if(_rulebookList.indexOf(obj) != nil)
			return(nil);

		_rulebookList.append(obj);

		return(true);
	}

	removeRulebook(obj) {
		if(obj == nil)
			return(nil);

		if(_rulebookList.indexOf(obj) == nil)
			return(nil);

		_rulebookList.removeElement(obj);

		return(true);
	}

	addRuleUser(obj) {
		if((obj == nil) || !obj.ofKind(RuleUser))
			return(nil);

		if(_ruleUserList.indexOf(obj) != nil)
			return(nil);

		_ruleUserList.append(obj);

		return(true);
	}

	removeRuleUser(obj) {
		if(obj == nil)
			return(nil);

		if(_ruleUserList.indexOf(obj) == nil)
			return(nil);

		_ruleUserList.removeElement(obj);

		return(true);
	}

	// Called every turn in the beforeAction() window.
	globalBeforeAction() {
		_turnSetup();
		_ruleUserBeforeAction();
	}

	// Called every turn in the afterAction() window.
	globalAfterAction() {
		_ruleUserAfterAction();
	}

	// Called every turn by our daemon, after action resolution.
	updateRuleEngine() {
		_ruleUserAction();
	}

	_turnSetup() {
		_checkRuleMatches();
		_updateRulebooks();
	}

	// Poll all the rules, finding out which ones match this turn.
	_checkRuleMatches() {
		local i;

		i = 0;
		_ruleList.forEach(function(o) {
			if(o.check(gActor, gDobj, gAction) == true)
				i += 1;
		});

		_debug('rule matches, turn <<toString(libGlobal.totalTurns)>>:
			<<toString(i)>> of <<toString(_ruleList.length)>>',
			'ruleEngineMatches');
	}

	_updateRulebooks() {
		_rulebookList.forEach(function(o) {
			if(o.check() == true)
				o._callback();
		});
	}

	_ruleUserBeforeAction() {
		_ruleUserList.forEach(function(o) { o.tryBeforeAction(); });
	}

	_ruleUserAfterAction() {
		_ruleUserList.forEach(function(o) { o.tryAfterAction(); });
	}

	_ruleUserAction() {
		_ruleUserList.forEach(function(o) { o.tryAction(); });
	}
;
