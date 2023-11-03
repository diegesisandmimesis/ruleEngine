//
// ruleEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_RULE_ENGINE

#include "syslog.h"
#ifndef SYSLOG_H
#error "This module requires the syslog module."
#error "https://github.com/diegesisandmimesis/syslog"
#error "It should be in the same parent directory as this module.  So if"
#error "ruleEngine is in /home/user/tads/ruleEngine, then"
#error "syslog should be in /home/user/tads/syslog ."
#endif // SYSLOG_H

#include "beforeAfter.h"
#ifndef BEFORE_AFTER_H
#error "This module requires the beforeAfter module."
#error "https://github.com/diegesisandmimesis/beforeAfter"
#error "It should be in the same parent directory as this module.  So if"
#error "ruleEngine is in /home/user/tads/ruleEngine, then"
#error "beforeAfter should be in /home/user/tads/beforeAfter ."
#endif // BEFORE_AFTER_H

#include "senseGrep.h"
#ifndef SENSE_GREP_H
#error "This module requires the senseGrep module."
#error "https://github.com/diegesisandmimesis/senseGrep"
#error "It should be in the same parent directory as this module.  So if"
#error "ruleEngine is in /home/user/tads/ruleEngine, then"
#error "senseGrep should be in /home/user/tads/senseGrep ."
#endif // SENSE_GREP_H

#ifndef gActionIsNested
#define gActionIsNested (gAction.parentAction != nil)
#endif // gActionIsNested

Rulebook template 'id'? +priority?;
Rule template 'id'?;

#define gRuleScheduler globalRuleScheduler

#define RULE_ENGINE_H
