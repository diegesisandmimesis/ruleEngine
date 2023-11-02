#charset "us-ascii"
//
// ruleEngineLocation.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngineThing: Thing, RuleEngineBase, RuleEngineDaemon
	syslogID = 'RuleEngineRoom'

	_ruleEngineDaemon = nil

	beforeAction() {
		inherited();
		ruleEngineBeforeAction();
	}

	afterAction() {
		inherited();
		ruleEngineAfterAction();
	}

	initializeThing() {
		inherited();
		initRuleEngineDaemon();
	}

	updateRuleEngine() {
		inherited();
		ruleEngineAction();
	}
;
