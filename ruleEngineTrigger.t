#charset "us-ascii"
//
// ruleEngineTrigger.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

class Trigger: Rule, Tuple
	matchRule(data?) {
		if(data == nil) data = object {};
		if(data.srcActor == nil)
			data.srcActor = gActor;
		if(data.dstObject == nil)
			data.dstObject = gDobj;
		if(data.action == nil)
			data.action = gAction;
		return(matchData(data));
	}
;
