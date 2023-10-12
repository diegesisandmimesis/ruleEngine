#charset "us-ascii"
//
// tupleTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the ruleEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f tupleTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "ruleEngine.h"

pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";
alice: Person 'Alice' 'Alice'
        "She looks like the first person you'd turn to in a problem. "
        isProperName = true
        isHer = true
;
bob: Person 'Bob' 'Bob'
	"He looks like Robert, only shorter. "
	isProperName = true
	isHim = true
;

versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		tests.runTests();
	}
;

tests: Syslog
	syslogID = 'tupleTests'
	_errors = 0
	_tests = 0

	_matchTupleTest(t0, t1, v0) {
		local v;

		v = t0.matchTuple(t1);
		_debug('matchTuple():');
		t0._debugTuple();
		t1._debugTuple();
		_debug('\tmatchTuple() = <<toString(v)>>');

		_tests += 1;
		_errors += ((v0 == v) ? 0 : 1);
	}

	_matchDataTest(tpl, cfg, v0) {
		local v;

		v = tpl.matchData(cfg);
		_debug('matchDataTest():');
		tpl._debugTuple();
		_debug('\t<<toString(cfg)>>');
		_debug('\tmatchData() = <<toString(v)>>');

		_tests += 1;
		_errors += ((v0 == v) ? 0 : 1);
	}

	runTests() {
		local obj0, obj1, t0, t1;

		obj0 = pebble;
		obj1 = pebble;
		t0 = new Tuple(object { srcObject = obj0 });
		t1 = new Tuple(object { srcObject = obj1 });
		_matchTupleTest(t0, t1, true);

		_matchDataTest(t0, object { srcObject = pebble }, true);

		obj1 = rock;
		t1 = new Tuple(object { srcObject = obj1 });
		_matchTupleTest(t0, t1, nil);

		if(_errors > 0) {
			"ERROR:  Failed <<toString(_errors)>> of
			<<toString(_tests)>> tests\n ";
		} else {
			"Passed all <<toString(_tests)>> tests\n ";
		}
	}
;
