#charset "us-ascii"
//
// ruleEngine.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

// The engine class.  It subscribes for notifications before and after
// every action, as well as running a daemon to be polled every turn
// after action resolution.
class RuleEngine: RuleEngineBase, RuleEngineDaemon, BeforeAfterThing, PreinitObject
	syslogID = 'RuleEngine'

	// Called at preinit.
	execute() {
		initRuleEngineDaemon();
	}

	// Called every turn in the beforeAction() window.
	globalBeforeAction() { _ruleSystemBeforeAction(); }

	// Called every turn in the afterAction() window.
	globalAfterAction() { _ruleSystemAfterAction(); }

	// Called every turn by our daemon, after action resolution.
	updateRuleEngine() { _ruleSystemAction(); }
;
