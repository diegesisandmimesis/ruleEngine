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
//		ruleuser	RuleUser instances
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

modify RuleEngine
	execute() {
		inherited();
		_debug('rulebooks:  <<toString(_rulebookList.length)>>',
			'rulebook');
		_debug('rule users:  <<toString(_ruleUserList.length)>>',
			'ruleuser');
	}
	initRules() {
		local r = inherited();
		_debug('initialized <<toString(r)>> rules', 'rule');
	}
	initRulebooks() {
		inherited();
		_debug('initialized <<toString(_rulebookList.length)>>
			rulebooks', 'rulebook');
	}
	addRulebook(obj) {
		local r = inherited(obj);
		_debug('addRulebook():  <<toString(_rulebookList.length)>>',
			'rulebook');
		return(r);
	}
	removeRulebook(obj) {
		local r = inherited(obj);
		_debug('removeRulebook():  <<toString(_rulebookList.length)>>',
			'rulebook');
		return(r);
	}
	addRuleUser(obj) {
		local r = inherited(obj);
		_debug('addRuleUser():  <<toString(_ruleUserList.length)>>',
			'ruleuser');
		return(r);
	}
	removeRuleUser(obj) {
		local r = inherited(obj);
		_debug('removeRuleUser():  <<toString(_ruleUserList.length)>>',
			'ruleuser');
		return(r);
	}
	_updateRulebooks(type?) {
		_debug('_updateRulebooks: evaluating
			<<toString(_rulebookList.length)>> rulebooks',
			'rulebook');
		inherited(type);
	}
	_ruleUserBeforeAction() {
		_debug('_ruleUserBeforeAction: evaluating
			<<toString(_ruleUserList.length)>> rule users',
			'rulebook');
		inherited();
	}
	_ruleUserAfterAction() {
		_debug('_ruleUserAfterAction: evaluating
			<<toString(_ruleUserList.length)>> rule users',
			'rulebook');
		inherited();
	}
	_ruleUserAction() {
		_debug('_ruleUserAction: evaluating
			<<toString(_ruleUserList.length)>> rule users',
			'rulebook');
		inherited();
	}
;

modify RuleUser
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
