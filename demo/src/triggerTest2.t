#charset "us-ascii"
//
// triggerTest2.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the ruleEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f triggerTest2.t3m
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
		"This demo that uses a trigger that matches when the
		player takes or drops either the pebble or the rock.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void. ";
+me: Person;
+pebble: Thing 'small round pebble' 'pebble' "A small, round pebble. ";
+rock: Thing 'ordinary rock' 'rock' "An ordinary rock. ";

myController: RuleEngine;

RuleUser
	rulebookMatchAction(id) {
		"<.p>Rulebook <q><<toString(id)>></q> matched
		on turn number <<toString(libGlobal.totalTurns)>>.<.p> ";
	}
;
// A trigger demonstrating the use of lists in trigger properties.
+Trigger
	dstObject = static [ pebble, rock ]
	action = static [ TakeAction, DropAction ]
;
