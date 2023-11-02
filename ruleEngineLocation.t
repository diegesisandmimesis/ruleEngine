#charset "us-ascii"
//
// ruleEngineLocation.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngineRoom: Room, RuleEngineBase
	syslogID = 'RuleEngineRoom'

	roomBeforeAction() {
		inherited();
		_ruleSystemBeforeAction();
	}

	roomAfterAction() {
		inherited();
		_ruleSystemAfterAction();
	}

	roomDaemon() {
		inherited();
		_ruleSystemAction();
	}
;
