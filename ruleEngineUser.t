#charset "us-ascii"
//
// ruleEngineUser.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class RuleUser: Syslog
	rulebook = perInstance(new LookupTable())

	_rulebookIdx = 0

	addRulebook(obj) {
		if(obj && !obj.ofKind(Rulebook))
			return(nil);

		if(obj.id == nil)
			obj.id = (_rulebookIdx += 1);

		rulebook[obj.id] = obj;

		return(true);
	}

	getRulebook(id?) {
		return(rulebook[(id ? id : 'default')]);
	}

	initRulebook(id?) {
		local r;

		if(rulebook != nil)
			return(nil);

		r = new Rulebook();
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
			r = initRulebook();

		return(r.addRule(obj));
	}
;
