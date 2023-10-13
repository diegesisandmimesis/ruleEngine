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
	matchRule(data?) {
		if(data == nil) data = object {};
		if(data.srcActor == nil)
			data.srcActor = gActor;
		if(data.srcObject == nil)
			data.srcObject = gIobj;
		if(data.dstObject == nil)
			data.dstObject = gDobj;
		if(data.action == nil)
			data.action = gAction;
		if(data.room == nil)
			data.room = gActor.getOutermostRoom();
		return(matchData(data));
	}
;
