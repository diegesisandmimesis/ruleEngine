#charset "us-ascii"
//
// ruleEngineTuple.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class Tuple: RuleEngineObject
	srcObject = nil
	srcActor = nil

	dstObject = nil
	dstActor = nil

	action = nil

	location = nil

	construct(cfg?) {
		inherited(cfg);
		canonicalizeTuple();
	}

	canonicalizeTuple() {
		local v;

		if((v = canonicalizeObject(srcObject)) != nil) {
			srcObject = v[1];
			srcActor = v[2];
		}
		if((v = canonicalizeObject(dstObject)) != nil) {
			dstObject = v[1];
			dstActor = v[2];
		}
		action = canonicalizeAction(action);
		location = canonicalizeLocation(location);
	}

	// Given an object, return an array of the object and the
	// actor carrying it.
	// If the object is nil, that's an array of nils.
	// If the object is a thing, thats any array of the object and the
	// carrying actor (if any).
	// If the object is an actor, it's an array containing nil and the
	// actor.
	canonicalizeObject(v) {
		if(v == nil)
			return(nil);

		if(!v.ofKind(Thing))
			return(nil);

		if(v.ofKind(Actor))
			return([ nil, v ]);
		else
			return([ v, v.getCarryingActor() ]);
	}

	// Placeholder.  All we do is verify the arg is an action, but we
	// don't actually canonicalize it.
	canonicalizeAction(v) {
		if((v == nil) || !v.ofKind(Action))
			return(nil);
		return(v);
	}

	canonicalizeLocation(v) {
		if((v == nil) || !v.ofKind(Thing))
			return(nil);
		return(v.getOutermostRoom());
	}

	_getDirectProperties(obj) {
		local r;

		if(obj == nil)
			return([]);

		r = new Vector();

		obj.getPropList().forEach(function(o) {
			if(!obj.propDefined(o, PropDefDirectly))
				return;
			r.append(o);
		});

		return(r);
	}

	// Returns boolean true if the passed args match our defined tuple.
	match(data?) {
		return(matchTuple(self.createInstance(data)));
	}

	// Utility method.
	// First arg is an object to test, second arg is either a value
	// or list of values to test against.
	// Return value is boolean true if the first arg is equal to
	// the second arg (or an element of it, if the second arg is a list);
	// or if the first arg is an instance of a class given in the second
	// arg.
	_matchBit(v, cls) {
		local r;

		// No criteria, always a match.
		if(cls == nil)
			return(true);

		// No arg, always a fail.
		if(v == nil)
			return(nil);

		// If our criteria is a list, check each element and succeed
		// if any element matches.
		if(cls.ofKind(List)) {
			r = nil;
			cls.forEach(function(o) {
				if((o == v) || v.ofKind(o))
					r = true;
			});
			return(r);
		}

		// Check for an exact match.
		if(v == cls)
			return(true);

		// Last resort;  are we an instance/subclass of the second arg?
		return(v.ofKind(cls));
	}

	// Convenience methods.
	matchSrcObject(v)
		{ return(_matchBit(v, srcObject)); }
	matchSrcActor(v)
		{ return(_matchBit(v, srcActor)); }
	matchDstObject(v)
		{ return(_matchBit(v, dstObject)); }
	matchDstActor(v)
		{ return(_matchBit(v, dstActor)); }
	matchActors(v0, v1)
		{ return(matchSrcActor(v0) && matchDstActor(v1)); }
	matchObjects(v0, v1)
		{ return(matchSrcObject(v0) && matchDstObject(v1)); }
	matchAction(v)
		{ return(_matchBit(v, action)); }
	matchLocation(v)
		{ return(_matchBit(v, location)); }

	// Match a passed tuple.
	matchTuple(v) {
		local i, l;

		if((v == nil) || !v.ofKind(Tuple))
			return(nil);

		l = _getDirectProperties(self);
		for(i = 1; i <= l.length(); i++) {
			if(self.(l[i]) != v.(l[i]))
				return(nil);
		}

		return(true);
	}

	_debugTuple() {
		_debug('tuple:');
		_getDirectProperties(self).forEach(function(o) {
			_debug('\t<<toString(o)>>:  <<toString(self.(o))>>');
		});
	}
;
