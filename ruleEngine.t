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
//	to go into rulebookMatchCallback().  It gets called automatically
//	by any rulebook belonging to this RuleUser instance whose state is
//	true for this turn.  The argument is the matching rulebook's ID:
//
//		// Custom rule handling goes in here.
//		// The argument is the matching rulebook's ID.
//		rulebookMatchCallback(id) {
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
//	
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
;

// The engine class.  It subscribes for notifications before and after
// every action, as well as running a daemon to be polled every turn
// after action resolution.
class RuleEngine: RuleEngineObject, BeforeAfterThing, PreinitObject
	syslogID = 'RuleEngine'
	syslogFlag = 'RuleEngine'

	// List of all the Rulebook instances.
	_rulebookList = perInstance(new Vector())

	// List of all the Rule instances.
	_ruleList = perInstance(new Vector())

	// Daemon that pings us every turn.
	_ruleDaemon = nil

	// Cache of all the rules that matched in the current turn.
	//_ruleMatches = nil

	// Called at preinit.
	execute() {
		initRules();
		initRulebooks();
		initRuleEngineDaemon();
	}

	// Initialize all Rule instances and add them to our list.
	initRules() {
		forEachInstance(Rule, function(o) {
			o.initializeRule();
			_ruleList.append(o);
		});
		_syslog('initialized <<toString(_ruleList.length)>> rules');
	}

	// Initialize all Rulebook instances and add them to our list.
	initRulebooks() {
		forEachInstance(Rulebook, function(o) {
			o.initializeRulebook();
			_rulebookList.append(o);
		});
		_syslog('initialized <<toString(_rulebookList.length)>>
			rulebooks');
	}

	// Create our daemon.
	initRuleEngineDaemon() {
		_ruleDaemon = new Daemon(self, &updateRuleEngine, 1);
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

	// Called every turn in the beforeAction() window.
	globalBeforeAction() {
		_syslog('===globalBeforeAction() START===');

		_turnSetup();

		_syslog('===globalBeforeAction() END===');
	}

	// Called every turn in the afterAction() window.
	globalAfterAction() {
		_syslog('===globalAfterAction() START===');

		_syslog('===globalAfterAction() END===');
	}

	// Called every turn by our daemon, after action resolution.
	updateRuleEngine() {
		_syslog('===updateRuleEngine() START===');

		_syslog('===updateRuleEngine() END===');
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
			<<toString(i)>>', 'ruleEngineMatches');
	}

	_updateRulebooks() {
		_rulebookList.forEach(function(o) {
			if(o.check() == true)
				o.callback();
		});
	}
;
