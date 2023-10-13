#charset "us-ascii"
//
// ruleEngineOptimized.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleEngineOptimized: RuleEngine
	syslogID = 'RuleEngineOptimized'
	syslogFlag = 'RuleEngine'

	_ruleList = nil

	initRules() {
		forEachInstance(Rule, function(o) {
			o.initializeRule();
		});
	}

	_turnSetup() {
		_updateRulebooks();
	}

	_updateRulebooks() {
		_rulebookList.forEach(function(o) {
			if(o.check() == true)
				o.callback();
		});
	}
;
