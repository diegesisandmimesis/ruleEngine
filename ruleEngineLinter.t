#charset "us-ascii"
//
// ruleEngineLinter.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

#ifdef LINTER
#ifdef __DEBUG

ruleEngineLinter: Linter;
+LintClass @Rule
	lintAction(obj) {
		if((obj.rulebook == nil) || !obj.rulebook.ofKind(Rulebook)) {
			warning('rule without rulebook,
				rule id <q><<toString(obj.id)>></q>');
			return;
		}
		if(obj.rulebook.id == gDefaultRulebookID) {
			info('rule in default rulebook,
				rule id <q><<toString(id)>></q>');
			setFlag('defaultRulebook');
		}
		
	}
;
+LintClass @Rulebook
	lintAction(obj) {
		if((obj.ruleSystem == nil)
			|| !obj.ruleSystem.ofKind(RuleSystem))
			warning('rulebook without rule system,
				rulebook id <q><<toString(obj.id)>></q>');
		if((obj.ruleList == nil) || (obj.ruleList.length == 0)) {
			warning('rulebook empty,
				rulebook id <q><<toString(obj.id)>></q>');
			setFlag('emptyRulebook');
		}
	}
;
+LintClass @RuleScheduler
	lintAction(obj) {
		if(!linter.testSuperclassOrder(obj, RuleScheduler, Room))
			error('RuleScheduler after Room in superclass list,
				room <q><<toString(obj.name)>></q>');
		else if(!linter.testSuperclassOrder(obj, RuleScheduler, Thing))
			error('RuleScheduler after Thing in superclass,
				thing <q><<toString(obj.name)>></q>');
	}
;
+LintRule [ 'emptyRulebook', 'defaultRulebook' ]
	lintAction() {
		info('got both empty rulebooks and rules added to a
			empty rulebook; possible error in rule
			declaration (check the number of +s)');
	}
;

#endif // __DEBUG
#endif // LINTER
