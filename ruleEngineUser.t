#charset "us-ascii"
//
// ruleEngineUser.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleUser: Syslog
	rulebook = perInstance(new LookupTable())

	rulebookClass = Rulebook

	_rulebookIdx = 0

	addRulebook(obj) {
		if(obj && !obj.ofKind(rulebookClass))
			return(nil);

		if(obj.id == nil)
			obj.id = (_rulebookIdx += 1);

		rulebook[obj.id] = obj;

		return(true);
	}

	getRulebook(id?) {
		return(rulebook[(id ? id : 'default')]);
	}

	newRulebook(id?) {
		local r;

		r = rulebookClass.createInstance();
		r.id = (id ? id : 'default');
		r.owner = self;

		addRulebook(r);

		return(r);
	}

	addRule(obj) {
		local r;

		if((obj == nil) || !obj.ofKind(Rule))
			return(nil);

		if((r = getRulebook()) == nil)
			r = newRulebook();

		return(r.addRule(obj));
	}

	haveRules() { return(rulebook.keysToList().length > 0); }

	checkRulebooks() {
		local i, l;

		l = rulebook.keysToList();
		for(i = 1; i <= l.length(); i++) {
			if(rulebook[l[i]].check() != true)
				return(nil);
		}

		return(true);
	}

	checkRulebook(id?) {
		local r;

		if((r = getRulebook(id)) == nil)
			return(nil);

		return(r.check());
	}
;
