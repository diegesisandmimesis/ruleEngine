#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the ruleEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
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
		"The rulebook should match on turn two, displaying
		a message.  Remember that the <q>first</q> turn is
		actually the zeroth, so the output for turn two is
		what's diplayed after the third command.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void. ";
+me: Person;

// Declare a RuleEngine instance.
RuleEngine;
+RuleSystem;
// Declare a rulebook.
// Normally we're place rulebooks "inside" some other object via the +Rulebook
// syntax, but here we're just testing the bare minimum rulebook functionality,
// so can get away with using an anonymous Rulebook instance.
++Rulebook 'myRulebook'
	callback() {
		"<.p>All the rules in the rulebook matched on turn
		<<toString(libGlobal.totalTurns)>>.<.p> ";
	}
;
// One rule, is boolean true only on turn two.
+++Rule 'myRule' matchRule(data?) { return(libGlobal.totalTurns == 2); };
