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
		initRuleEngines();
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

	initRuleEngines() {
		forEachInstance(RuleEngine, function(o) {
			o.initializeRuleEngine();
		});
	}
;
