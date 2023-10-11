#charset "us-ascii"
//
// matchNoneTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the ruleEngine library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f matchNoneTest.t3m
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
		"This demo uses two RulebookMatchNone rulebooks, which will
		match when none of their rules match.
		<.p>
		We give the first, <q>foo</q>, two rules:  one that's true on
		odd-numbered turns, and one that's true on even-numbered
		turns.  This rulebook should therefore never match.
		<.p>
		The second rulebook, <q>bar</q>, has a set of rules matching
		each turn numbers zero through three.  This rulebook
		should therefore not match for the first several turns, then
		match every turn thereafter.
		<.p> ";
	}
;

startRoom: Room 'Void' "This is a featureless void. ";
+me: Person;

// Declare a RuleEngine instance.
myController: RuleEngine;

class DemoRulebook: RulebookMatchNone
	callback() {
		"<.p>All the rules in rulebook <q><<id>></q> matched on turn
		<<toString(libGlobal.totalTurns)>>.<.p> ";
	}
;

DemoRulebook 'foo';
+Rule matchRule(data?) { return((libGlobal.totalTurns % 2) == 0); };
+Rule matchRule(data?) { return((libGlobal.totalTurns % 2) != 0); };

DemoRulebook 'bar';
+Rule matchRule(data?) { return(libGlobal.totalTurns == 0); };
+Rule matchRule(data?) { return(libGlobal.totalTurns == 1); };
+Rule matchRule(data?) { return(libGlobal.totalTurns == 2); };
+Rule matchRule(data?) { return(libGlobal.totalTurns == 3); };
