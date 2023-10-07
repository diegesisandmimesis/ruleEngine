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
		syslog.enable('ruleEngineMatches');
		runGame(true);
	}
;

startRoom: Room 'Void'
	"This is a featureless void with a sign on what passes for a wall. "
;
+sign: Fixture 'sign' 'sign'
	"Reading this sign (but not examining/looking at it) matches
	the rule. "
	dobjFor(Read) {
		action() {
			"The sign says: <q>[This space intentionally
			left blank]</q>. ";
		}
	}
;
+me: Person;

Rulebook 'myRulebook';
+Rule 'myRule'
	matchRule(actor?, obj?, action?) {
		return(libGlobal.totalTurns == 2);
	}
;
