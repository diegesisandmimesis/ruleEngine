#charset "us-ascii"
//
// ruleEngineDebug.t
//
//	Debugging stuff.
//
//	For readibility all the logging stuff is tagged.  The tags are:
//
//		rule		Rule instances
//		rulebook	Rulebook instances
//		rulesystem	RuleSystem instances
//
//	To enable debugging output for a tag, use syslog.enable() with
//	the tag as the argument.  For example:
//
//		syslog.enable('rulebook');
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

#ifdef SYSLOG

DefineSystemAction(DebugRuleEngine)
	execSystemAction() {
	}
;
VerbRule(DebugRuleEngine)
	'debugruleengine' : DebugRuleEngineAction
	verbPhrase = 'debug/debugging'
;

modify RuleEngine
	execute() {
		inherited();
		_debug('rule systems:  <<toString(_ruleSystemList.length)>>',
			'rulesystem');
	}
	addRuleSystem(obj) {
		local r = inherited(obj);
		_debug('addRuleSystem():  <<toString(_ruleSystemList.length)>>',
			'rulesystem');
		return(r);
	}
	removeRuleSystem(obj) {
		local r = inherited(obj);
		_debug('removeRuleSystem():
			<<toString(_ruleSystemList.length)>>', 'rulesystem');
		return(r);
	}
;

modify Rulebook
	addRule(obj) {
		local r = inherited(obj);
		if(r == true)
			_debug('addRule() success', 'rule');
		else
			_debug('addRule() failed', 'rule');
	}
;

modify RuleSystem
	rulebookMatched(id) {
		_debug('rulebook <q><<toString(id)>></q> matched', 'rulebook');
		inherited(id);
	}
;

modify Tuple
	_debugTuple() {
		_debug('tuple:');
		_getDirectProperties(self).forEach(function(o) {
			_debug('\t<<toString(o)>>:  <<toString(self.(o))>>');
		});
	}
;

#endif // SYSLOG
