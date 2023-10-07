#charset "us-ascii"
//
// ruleEngineController.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngineController: RuleEngineObject, BeforeAfterThing, PreinitObject
	syslogID = 'ruleEngineController'
	syslogFlag = 'ruleEngineController'

	_rulebookList = perInstance(new Vector())
	_ruleList = perInstance(new Vector())

	_ruleDaemon = nil

	_ruleMatches = nil

	execute() {
		initRules();
		initRulebooks();
		initRuleEngineDaemon();
	}

	initRules() {
		forEachInstance(Rule, function(o) {
			o.initializeRule();
			_ruleList.append(o);
		});
		_syslog('initialized <<toString(_ruleList.length)>> rules');
	}

	initRulebooks() {
		forEachInstance(Rulebook, function(o) {
			o.initializeRulebook();
			_rulebookList.append(o);
		});
		_syslog('initialized <<toString(_rulebookList.length)>>
			rulebooks');
	}

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

	globalBeforeAction() {
		_syslog('===globalBeforeAction() START===');

		_turnSetup();

		_syslog('===globalBeforeAction() END===');
	}

	globalAfterAction() {
		_syslog('===globalAfterAction() START===');

		_syslog('===globalAfterAction() END===');
	}

	updateRuleEngine() {
		_syslog('===updateRuleEngine() START===');

		_turnCleanup();

		_syslog('===updateRuleEngine() END===');
	}

	_turnSetup() {
		_setRuleMatches();
		_updateRulebooks();
	}

	_turnCleanup() {
		_clearRuleMatches();
	}

	_setRuleMatches() {
		_ruleMatches = new Vector(_ruleList.length);
		_ruleList.forEach(function(o) {
			if(o.check(gActor, gDobj, gAction) == true)
				_ruleMatches.append(o);
		});

		_debug('rule matches, turn <<toString(libGlobal.totalTurns)>>:
			<<toString(_ruleMatches.length)>>',
			'ruleEngineMatches');
	}

	_clearRuleMatches() {
		_syslog('clearing rule matches');
		_ruleMatches = nil;
	}

	_updateRulebooks() {
		_rulebookList.forEach(function(o) {
			if(o.check() == true)
				o.callback();
		});
	}
;
