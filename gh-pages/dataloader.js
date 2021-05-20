// dataloader.js by Matt Fritz
// January 2, 2011
// Load data needed for the game

// the number of questions/locations that will be presented
// to the player during the game
var NUM_QUESTIONS = 20;

// the total number of locations to choose from
// -- set when loading locations
var NUM_LOCATIONS_TOTAL;

// the total number of questions to choose from
// -- set when loading questions
var NUM_QUESTIONS_TOTAL;

var qNumbers;
var lNumbers;

// the ID numbers of questions and locations
var questionNums;
var locationNums;

// the physical array of questions that can be asked
var questions;

// the physical array of locations that can be visited
var locations;

// the <div> element that will display status messages
var progressContainer;

// shuffle an array and return the results
// http://stackoverflow.com/questions/962802/is-it-correct-to-use-javascript-array-sort-method-for-shuffling
function shuffle(array)
{
    var tmp, current, top = array.length;

    if(top) while(--top)
    {
        current = Math.floor(Math.random() * (top + 1));
        tmp = array[current];
        array[current] = array[top];
        array[top] = tmp;
    }

    return array;
}

// load everything (called from aggregator.js)
function loadAllData()
{
     // set the progress container
     progressContainer = $("#dataDisplay");

     // load the locations and then the questions
     loadLocations();
}

// reset and rebuild the ID number arrays
function resetData()
{
     // reset all of the arrays
     qNumbers = new Array();
     lNumbers = new Array();
     questionNums = new Array();
     locationNums = new Array();

     var i;
     
     // create the array of location numbers
     for(i = 1; i < NUM_LOCATIONS_TOTAL; i++)
     {
          lNumbers.push(i);
     }

     // create the array of question numbers
     for(i = 0; i < NUM_QUESTIONS_TOTAL; i++)
     {
          qNumbers.push(i);
     }

     // shuffle the questions and locations for a random assortment
     shuffle(qNumbers);
     shuffle(lNumbers);

     // add the first location to the location numbers
     // so we will always start there
     lNumbers.unshift(0);

     // get the desired number of questions/locations and store as
     // an array (0 : NUM_QUESTIONS-1)
     questionNums = qNumbers.slice(0, NUM_QUESTIONS);
     locationNums = lNumbers.slice(0, NUM_QUESTIONS);
}

// function called when the AJAX call was unsuccessful
function myFacePalmFunction(myXMLHttpRequest,myErrorMessage,myErrorThrown)
{
     progressContainer.html("<span style='font-weight:bold'>An error has occurred during the AJAX loading sequence:</span> " + myErrorMessage + "<br />Server response: " + myXMLHttpRequest.responseText);
}

// load the locations from the places.json file
function loadLocations()
{
     progressContainer.html("Loading locations... please wait.<br /><br />");

     // perform the AJAX request and make sure the format is JSON
     $.ajax({
          url: "places.json",
          cache: false,
          dataType: "json",
          success: loadLocationsSuccess,
          error: myFacePalmFunction
     });
}

// function called when the AJAX call for locations was successful
function loadLocationsSuccess(data)
{
     // set the locations for later use
     locations = data.places;
     NUM_LOCATIONS_TOTAL = locations.length;

     // iterate through the JSON data and add each row to the table
     var i;
     for(i = 0; i < locations.length; i++)
     {
          // add the data point to the map
          addPoint(locations[i].geolat, locations[i].geolong, locations[i].name);
     }

     // we've loaded the locations, so let's load the questions now
     loadQuestions();
}

// build and display the table of locations
function displayLocationsTable()
{
     // append the data table, along with the title row, to the dataDisplay <div> on the main page
     progressContainer.html("<table id='dataTable' border='1' align='center'>\n<tr><th>Click a location to center the map</th></tr>\n");

     // add the title of the feed
     progressContainer.prepend("<h2>Disneyland Venues</h2>\n<h4>Venues around Disneyland from Foursquare</h4>");

     // iterate through the JSON data and add each row to the table
     var i;
     for(i = 0; i < locations.length; i++)
     {
          // create a JavaScript link that will center the map on this location
          var link = "javascript:centerMap(" + locations[i].geolat + "," + locations[i].geolong + ");";

          // append a new row to the data table
          $("#dataTable").append("<tr><td><a href='" + link + "'>" + locations[i].name + "</a></td></tr>");
     }

     // append the closing tag for the data table
     progressContainer.append("</table>");
}

// load the questions from the questions.json file
function loadQuestions()
{
     progressContainer.html("Loading questions... please wait.<br /><br />");

     // perform the AJAX request and make sure the format is JSON
     $.ajax({
          url: "questions.json",
          cache: false,
          dataType: "json",
          success: loadQuestionsSuccess,
          error: myFacePalmFunction
     });
}

// function called when the AJAX call for questions was successful
function loadQuestionsSuccess(data)
{
     // set the questions for later use
     questions = data.questions;
     NUM_QUESTIONS_TOTAL = questions.length;

     // clear and rebuild all of the data
     resetData();

     // display the table of locations
     displayLocationsTable();

     // show the Start Game button
     $("#startGameBtn").css("display","inline");
}

// get the next question ID
function nextQuestionID()
{
     // return -1 if there are no more questions, otherwise
     // return the question ID from the front of the array
     if(questionNums.length == 0) return -1;
     return questionNums.shift();
}

// get the next location ID
function nextLocationID()
{
     // return -1 if there are no more locations, otherwise
     // return the location ID from the front of the array
     if(locationNums.length == 0) return -1;
     return locationNums.shift();
}