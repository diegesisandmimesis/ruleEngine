#charset "us-ascii"
//
// ruleEngine.t
//
#include <adv3.h>
#include <en_us.h>

// Module ID for the library
ruleEngineModuleID: ModuleID {
        name = 'Rule Engine Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class RuleEngineObject: Syslog
	syslogID = 'RuleEngineObject'
	syslogFlag = 'ruleEngine'
;
