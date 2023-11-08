#charset "us-ascii"
//
// rulesTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the ruleEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f rulesTest.t3m
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
		//syslog.enable('ruleEngineMatches');
		showIntro();
		runGame(true);
	}
	showIntro() {
		"This demo uses two rules, one of which matches on
		odd-numbered turns, and another which matches whenever the
		turn number is greater than two.
		<.p>
		There should be output only when both match, which should
		start on turn three and then every other turn thereafter.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void. ";
+me: Person;

// Declare a RuleEngine instance.
RuleEngine;
+RuleSystem;

// An anonymous rulebook.  The default Rulebook class matches when
// all its rules match.  One rule matches odd turns and the other matches
// turn numbers greater than two.  The rulebook will therefore match
// turn three and every other turn thereafter.
++Rulebook
	callback() {
		"<.p>All the rules in the rulebook matched on turn
		<<toString(libGlobal.totalTurns)>>.<.p> ";
	}
;
+++Rule matchRule(data?) { return(libGlobal.totalTurns > 2); };
+++Rule matchRule(data?) { return((libGlobal.totalTurns % 2) != 0); };
