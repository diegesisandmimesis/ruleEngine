#charset "us-ascii"
//
// ruleEngineTrigger.t
//
//	A trigger is kind of rule that (may) match details of an action tuple.
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class Trigger: Rule, Tuple
	getTurnConfig(data?) {
		if(data == nil) data = object {};
		if(data.srcActor == nil)
			data.srcActor = gActor;
		if(gIobj == nil) {
			if(data.dstObject == nil)
				data.dstObject = gDobj;
		} else {
			if(data.srcObject == nil)
				data.srcObject = gDobj;
			if(data.dstObject == nil)
				data.dstObject = gIobj;
		}
		if(data.action == nil)
			data.action = gAction;
		if(data.room == nil)
			data.room = gActor.getOutermostRoom();

		return(data);
	}
	matchRule(data?) {
		return(matchData(getTurnConfig(data)));
	}
;
