#charset "us-ascii"
//
// ruleEngineOptimized.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

// Alternate RuleEngine class.
// This only evaluates rules in rulebooks, and only using the rulebook's
// check() method.  This should automagically take advantage of any
// short-circuiting logic in the Rulebook's logic (that is, stopping rule
// evaluation as soon as it has evaluated enough to determine the current
// state).
class RuleEngineOptimized: RuleEngineBase
	syslogID = 'RuleEngineOptimized'
	syslogFlag = 'RuleEngine'

	// We don't need the rule list because we only care about rules
	// in rulebooks.
	_ruleList = nil

	// We still initialize the rules, because that takes care of
	// sorting out rule ownership.
	initRules() {
		forEachInstance(Rule, function(o) { o.initializeRule(); });
	}

	_turnSetup() { _updateRulebooks(); }

	_updateRulebooks() {
		_rulebookList.forEach(function(o) {
			if(o.check() == true)
				o.callback();
		});
	}
;

class RuleEngine: RuleEngineOptimized;
