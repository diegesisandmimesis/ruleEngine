#charset "us-ascii"
//
// optimizedTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the ruleEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f optimizedTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include <bignum.h>

#include "ruleEngine.h"

versionInfo: GameID
        name = 'ruleEngine Library Demo Game'
        byline = 'Diegesis & Mimesis'
        desc = 'Demo game for the ruleEngine library. '
        version = '1.0'
        IFID = '12345'
	showAbout() {
		"This is a simple test game that demonstrates the features
		of the ruleEngine library.
		<.p>
		Consult the README.txt document distributed with the library
		source for a quick summary of how to use the library in your
		own games.
		<.p>
		The library source is also extensively commented in a way
		intended to make it as readable as possible. ";
	}
;
gameMain: GameMainDef
	initialPlayerChar = me
	newGame() {
		syslog.enable('ruleEngine');
		syslog.enable('ruleEngineMatches');
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo uses entirely too many rules.  Any rulebook
		match is vanishingly unlikely, but evaluating all the rules
		is very slow using the base RuleEngine class.
		<.p>
		By default this demo uses the RuleEngineOptimized class, which
		should be faster.  You can compare the speed by compiling
		with the -D NO_OPTIMIZATION flag, which will use RuleEngine
		instead, which should be noticeably slower.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void. ";
+me: Person;

// A rule that matches randomly 1 time in 10
class RandomRule: Rule
	matchRule(data?) { return(rand(10) == 1); }
;

// A comparatively expensive to check random rule.
class ExpensiveRule: Rule
	_iterations = 10000

	matchRule(data?) {
		local i, a, b, n, bn0, bn1;

		n = 0;
		for(i = 0; i < _iterations; i++) {
			a = rand(10);
			b = rand(10);
			if(a >= b)
				n += 1;
			bn0 = new BigNumber('<<toString(rand(65535) + 1)>>');
			bn1 = new BigNumber('<<toString(rand(65535) + 1)>>');
			bn0 *= bn1;
			bn0 -= new BigNumber('<<toString(rand(65535) + 1)>>');
			bn0 /= new BigNumber('<<toString(rand(65535) + 1)>>');
		}
		if(n >= (_iterations / 2))
			return(true);

		return(nil);
	}
;

// Declare a RuleEngine instance.
// We use RuleEngineOptimized.  You can comment that out and try with the
// base RuleEngine class to see the performance difference.
#ifdef NO_OPTIMIZATION
myController: RuleEngine;
#else // NO_OPTIMIZATION
myController: RuleEngineOptimized;
#endif // NO_OPTIMIZATION

// Declare a RuleUser instance.
// Normally this would be a mixin for something else (like a Scene),
// but here we're just testing the rulebook checking logic, so
// we use an anonymous object that's "just" a RuleUser instance.
myUser: RuleUser
	rulebookMatchAction(id) {
		"<.p>All the rules matched on turn number
		<<toString(libGlobal.totalTurns)>>.<.p> ";
	}
	initializeRuleUser() {
		inherited();
		_addTooManyRules();
	}
	_addTooManyRules() {
		local i;

		for(i = 0; i < 10; i++)
			addRule(RandomRule.createInstance());
		for(i = 0; i < 100; i++)
			addRule(ExpensiveRule.createInstance());
	}
;
+Rule matchRule(data?) { return(libGlobal.totalTurns > 2); };
