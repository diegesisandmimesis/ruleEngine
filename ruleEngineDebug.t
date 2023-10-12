#charset "us-ascii"
//
// ruleEngineDebug.t
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

#ifdef SYSLOG

modify Tuple
	_debugTuple() {
		_debug('tuple:');
		_getDirectProperties(self).forEach(function(o) {
			_debug('\t<<toString(o)>>:  <<toString(self.(o))>>');
		});
	}
;

#endif // SYSLOG
