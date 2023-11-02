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
		ruleEngineBeforeAction();
	}

	roomAfterAction() {
		inherited();
		ruleEngineAfterAction();
	}

	roomDaemon() {
		inherited();
		ruleEngineAction();
	}
;
