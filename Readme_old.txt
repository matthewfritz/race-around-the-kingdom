=======================
RACE AROUND THE KINGDOM
By Matt Fritz
January 4, 2012
=======================

-----------------
TABLE OF CONTENTS
-----------------

I. INTRODUCTION
II. FILE LIST
III. DATA NOTES
IV. CHANGES

---------------
I. INTRODUCTION
---------------

RACE AROUND THE KINGDOM is a game by Matt Fritz that takes players around the Disneyland Resort by utilizing satellite imagery. Throughout the adventure the player will answer questions based on resort locations and will earn a point if he is correct.

-------------
II. FILE LIST
-------------

aggregator.js - Performs map-plotting and game-running tasks

dataloader.js - Loads and parses location and question data

index.html - The main display page for the game

jquery-1.7.1.min.js - The jQuery JavaScript library (version 1.7.1)

marker.png - The star image used for a visited location on the map

places.json - The data file containing map locations (in JSON format)

questions.json - The data file containing questions (in JSON format)

---------------
III. DATA NOTES
---------------

In questions.json, the correct answer for a question is the first entry in its "answers" section. If you would like to modify the questions file, keep this in mind when adding, removing, or modifying questions.

-----------
IV. CHANGES
-----------

January 4, 2012 - Final version deployed

December 27, 2011 - New version developed

October 28, 2010 - Original game version created