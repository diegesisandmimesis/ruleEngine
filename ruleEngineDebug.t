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

class RuleEngineRRD: object
	ruleCheck = 0
	ruleFire = 0
	rulebookCheck = 0
	rulebookFire = 0
	rulesystemCheck = 0
	rulesystemFire = 0
;

ruleEngineDebugger: PreinitObject
	_rrd = perInstance(new LookupTable())
	_daemon = nil

	execute() { _daemon = new Daemon(self, &update, 1); }

	idx() { return(libGlobal.totalTurns); }
	_add(id, amt?) {
		local i, obj;

		i = idx();
		if((obj = _rrd[i]) == nil) {
			obj = new RuleEngineRRD();
			_rrd[i] = obj;
		}
		obj.(id) += ((amt == nil) ? 1 : amt);
	}

	checkRule(amt?) { _add(&ruleCheck, amt); }
	fireRule(amt?) { _add(&ruleFire, amt); }

	checkRulebook(amt?) { _add(&rulebookCheck, amt); }
	fireRulebook(amt?) { _add(&rulebookFire, amt); }

	checkRuleSystem(amt?) { _add(&rulesystemCheck, amt); }
	fireRuleSystem(amt?) { _add(&rulesystemFire, amt); }

	update() {
		local i;

		i = idx() - 10;
		if(_rrd.isKeyPresent(i))
			_rrd.removeElement(i);

		checkRule(0);
		fireRule(0);
		checkRulebook(0);
		fireRulebook(0);
		checkRuleSystem(0);
		fireRuleSystem(0);
	}
	log() {
		local l, obj;

		if(idx() == 0) {
			"\nNo debugging data yet, still turn zero.\n ";
			return;
		}
		l = _rrd.keysToList().sort();
		"\nRule engine history (values are checks : matches):\n ";
		"<.p> ";
		l.forEach(function(o) {
			obj = _rrd[o];
			"\n\tTurn <<o>>:\n ";
			"\n\t\trule = <<toString(obj.ruleCheck)>> :
				<<toString(obj.ruleFire)>>\n ";
			"\n\t\trulebook = <<toString(obj.rulebookCheck)>> :
				<<toString(obj.rulebookFire)>>\n ";
			"\n\t\trulesystem = <<toString(obj.rulesystemCheck)>> :
				<<toString(obj.rulesystemFire)>>\n ";
		});
	}
;

DefineSystemAction(DebugRuleEngine)
	execSystemAction() {
		forEachInstance(RuleEngine, function(o) {
		});
		"<.p> ";
		ruleEngineDebugger.log();
		"<.p>Done. ";
	}
;
VerbRule(DebugRuleEngine)
	'debugruleengines' : DebugRuleEngineAction
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

modify Rule
	check(type?) {
		ruleEngineDebugger.checkRule();
		return(inherited(type));
	}
	setState(v?) {
		local r = inherited(v);
		if(r) ruleEngineDebugger.fireRule();
		return(r);
	}
;

modify Rulebook
	check() {
		ruleEngineDebugger.checkRulebook();
		return(inherited());
	}
	callback() {
		ruleEngineDebugger.fireRulebook();
		inherited();
	}
	addRule(obj) {
		local r = inherited(obj);
		if(r == true)
			_debug('addRule() success', 'rule');
		else
			_debug('addRule() failed', 'rule');
		return(r);
	}
;

modify RuleSystem
	ruleSystemBeforeAction() {
		ruleEngineDebugger.checkRuleSystem();
		inherited();
	}
	rulebookMatched(id) {
		_debug('rulebook <q><<toString(id)>></q> matched', 'rulebook');
		ruleEngineDebugger.fireRuleSystem();
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
