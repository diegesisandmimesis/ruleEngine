#charset "us-ascii"
//
// ruleEngineLocation.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngineThing: Thing, RuleEngineBase
	syslogID = 'RuleEngineRoom'

	_ruleEngineDaemon = nil

	beforeAction() {
		inherited();
		_ruleSystemBeforeAction();
	}

	afterAction() {
		inherited();
		_ruleSystemAfterAction();
	}

	initializeThing() {
		inherited();
		initRuleEngineDaemon();
	}

	updateRuleEngine() {
		inherited();
		_ruleSystemAction();
	}
;
