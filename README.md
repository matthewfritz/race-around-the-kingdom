# Race Around the Kingdom

Race Around the Kingdom is a game by Matthew Fritz that takes players around the Disneyland Resort by utilizing satellite imagery. Throughout the adventure the player will answer questions based on resort locations and will earn a point if he is correct.

The initial version was released on October 28, 2010.

In order to view the project in your browser, please open the `index.html` file in this repository.

## Table of Contents

* [File List](#file-list)
* [Data Notes](#data-notes)
* [Change Log](#change-log)

## File List

`aggregator.js` - Performs map-plotting and game-running tasks

`dataloader.js` - Loads and parses location and question data

`index.html` - The main display page for the game

`jquery-1.7.1.min.js` - The jQuery JavaScript library (version 1.7.1)

`marker.png` - The star image used for a visited location on the map

`places.json` - The data file containing map locations (in JSON format)

`questions.json` - The data file containing questions (in JSON format)

## Data Notes

In `questions.json`, the correct answer for a question is the first entry in its `answers` section. If you would like to modify the questions file, keep this in mind when adding, removing, or modifying questions.

## Change Log

2012-01-04 - Final updates to 2011-12-27 version deployed (tagged as `1.0.0`)

2011-12-27 - New version developed

2010-10-28 - Original game version created