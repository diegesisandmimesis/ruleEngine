#charset "us-ascii"
//
// ruleEngineDaemon.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngineDaemon: RuleEngineObject
	// Daemon that pings us every turn.
	_ruleEngineDaemon = nil

	// Create our daemon.
	initRuleEngineDaemon() {
		_ruleEngineDaemon = new Daemon(self, &updateRuleEngine, 1);
	}

	updateRuleEngine() {}
;
