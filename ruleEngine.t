#charset "us-ascii"
//
// ruleEngine.t
//
//	A simple "business rules" engine for TADS3.
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
