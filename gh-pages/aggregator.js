// aggregator.js by Matt Fritz
// October 28, 2010
// Handles plotting the venues on the map and handles the running
// of the game based around the map and Disneyland.

// function called when the document is ready for modification			
function myReadyFunction()
{
        // load game data from dataloader.js
        loadAllData();

        // associate click events with questions
        $('#submitAnswer').click(function() {
             checkAnswer($('#questionNum').attr('value'), $('input:checked').attr('value'));
        });

        // initialize the map
        initializeMap();
}

// ===========================================
// MAP CONTROL
// ===========================================

var mapObj; // reference to the map object
var enableCentering = true; // boolean controlling whether to center the map in the centerMap() function

var infoWindow; // handle to an InfoWindow class that will be re-used

var gameEnabled = false; // boolean controlling whether the game is active
var gameMarkerArray = Array(); // array of markers used by the game (and is a copy of the original because we'll be popping from it)
var questionActive = false; // boolean controlling whether a question is active

var score = 0; // score during the game
var secondsElapsed = 0; // time elapsed during the game (in seconds)
var gameTimeout = 0; // handle to the timeout function for the timer

var markers = Array(); // array of map markers
var currentMarkerIndex = 0; // index of the currently-active marker
var currentQuestionIndex = 0; // index of the currently-active question

var placesVisited = 0; // the number of locations visited

// initialize the map interface
function initializeMap()
{
     // use the coordinates of the "Disneyland" marker initially
     var latlng = new google.maps.LatLng(33.81156583304336, -117.91897416114807);

     // set the options (zoom level, map center, and the map type)
     var myOptions = {
       zoom: 20,
       center: latlng,
       streetViewControl: false,
       mapTypeId: google.maps.MapTypeId.SATELLITE
     };

     // create the map
     mapObj = new google.maps.Map(document.getElementById("mapDisplay"),
        myOptions);

     // create the InfoWindow
     infoWindow = new google.maps.InfoWindow({content: "Derp.", maxWidth: 400});
}

// center the map at the specified coordinates
function centerMap(lat,long)
{
     // check to make sure centering is enabled
     if(enableCentering)
     {
          // create a LatLng object to represent the coordinates
          var latlng = new google.maps.LatLng(lat, long);

          // center the map at the specified latitude and longitude
          mapObj.setCenter(latlng);
     }
}

// automatically center the map for the game
function gameCenterMap()
{
     // center the map at the specified latitude and longitude for this marker
     if(currentMarkerIndex != -1)
     {
          mapObj.setCenter(gameMarkerArray[currentMarkerIndex].getPosition());
     }
}

// add a point to the map
function addPoint(lat,long,name)
{
     // create a LatLng object to represent the coordinates
     var latlng = new google.maps.LatLng(lat, long);

     // create the marker
     var marker = new google.maps.Marker({position: latlng, title: name, map: mapObj, visible: true});

     // add the "Click" event handler for the marker and make it show the InfoWindow object
     google.maps.event.addListener(marker, 'click', function() {
         showInfoWindow(marker);
     });

     // push the marker into the array
     markers.push(marker);
}

// show the InfoWindow and do some stuff with it
function showInfoWindow(marker)
{
     // check to see if the game is enabled
     if(!gameEnabled)
     {
          // display the title of the location and its coordinates in the InfoWindow
          infoWindow.setContent("<span style='font-weight:bold'>" + marker.getTitle() + "</span><br /><br />Latitude: " + marker.getPosition().lat() + "<br />Longitude: " + marker.getPosition().lng());
     }
     else
     {
          // check to see if a question is active
          if(!questionActive)
          {
              // get a random question from the external web service
              infoWindow.setContent("Loading next question...");

              // indicate that there is currently an active question
              questionActive = true;

              // build the HTML for the question and answers
              var html = "<span style=\"color:blue\">" + questions[currentQuestionIndex].question + "</span><br /><br />";
              html += "<form>";
              html += "<div style=\"text-align:left\">";
     
              // shuffle the array to make sure the answers appear in a random order
              var numAnswers = questions[currentQuestionIndex].answers.length;
              var answers = shuffle(questions[currentQuestionIndex].answers.slice(0, numAnswers));

              // iterate through the question and get all possible answers
              var i;
              for(i = 0; i < answers.length; i++)
              {
                   html += "<input type=\"radio\" name=\"answer\" id=\"answer" + i + "\" value=\"" + answers[i] + "\" />" + answers[i] + "<br />";
              }

              html += "</div>";

              // add the question number
              html += "<input type=\"hidden\" id=\"questionNum\" value=\"" + currentQuestionIndex + "\" />";

              // add the submission button
              html += "<br /><input type=\"button\" id=\"submitAnswer\" value=\"Submit\" onClick=\"checkAnswer($('#questionNum').attr('value'), $('input:checked').attr('value'));\" />";

              html += "</form>";

              // set the content of the InfoWindow to be the returned data
              infoWindow.setContent("<span style=\"font-weight:bold\">" + gameMarkerArray[currentMarkerIndex].getTitle() + " (" + (placesVisited) + "/" + NUM_QUESTIONS + ")</span><br /><br />" + html);
          } 
     }

     // open the InfoWindow at the marker
     infoWindow.open(mapObj,marker);
}

// check the player's answer for a question
function checkAnswer(questionNum,answer)
{
     // check to see if a question is active and that an answer was selected
     if(questionActive && answer != "" && answer != null)
     {
          // get a random question from the external web service
          infoWindow.setContent("Checking your answer...");

          // set the content of the InfoWindow to be the returned data
          if(escape(answer) == escape(questions[currentQuestionIndex].answers[0]))
          {
               // increment the user's score
               incrementScore();

               // show the user a congratulations message
               infoWindow.setContent("<span style=\"font-weight:bold\">" + gameMarkerArray[currentMarkerIndex].getTitle() + "</span><br /><br />" + "<span style='color:green'>Correct!</span><br /><br /><form><input type=\"button\" id=\"findNextPointButton\" value=\"Go to Next Location\" onClick=\"findNextMarker()\" /></form>");
          }
          else
          {
               // show the user a failure message
               infoWindow.setContent("<span style=\"font-weight:bold\">" + gameMarkerArray[currentMarkerIndex].getTitle() + "</span><br /><br />" + "<span style='color:red'>That answer was incorrect.</span><br /><br /><form><input type=\"button\" id=\"findNextPointButton\" value=\"Go to Next Location\" onClick=\"findNextMarker()\" /></form>");
          }

          // indicate that there is currently an active answer
          questionActive = true;
     } 
}

// increment the user's score
function incrementScore()
{
     score += 1;

     // display his score so far
     $("#scoreDisplay").html("Score: " + score + "/" + NUM_QUESTIONS + " points");
}

// get the next marker from the array
function findNextMarker()
{
     // check to make sure we aren't going out-of-bounds
     if(currentMarkerIndex < gameMarkerArray.length)
     {
          // check to make sure the game is enabled
          if(gameEnabled)
          {
               // disable the question
               questionActive = false;

               // make sure we don't go out-of-bounds with a negative number
               if(currentMarkerIndex >= 0)
               {
                    // hide the previous marker
                    gameMarkerArray[currentMarkerIndex].setVisible(false);
               }

               // set the currently-selected marker ID
               currentMarkerIndex = nextLocationID();

               // make sure we don't go out-of-bounds
               if(currentMarkerIndex != -1)
               {
                    // we will be at a new place
                    placesVisited++;

                    // choose the next question too
                    currentQuestionIndex = nextQuestionID();

                    // hide the InfoWindow
                    infoWindow.close();

                    // change the icon
                    gameMarkerArray[currentMarkerIndex].setIcon(new google.maps.MarkerImage("marker.png",new google.maps.Size(63,59),new google.maps.Point(0,0),new google.maps.Point(32,29)));

                    // set the visibility of the new maker
                    gameMarkerArray[currentMarkerIndex].setVisible(true);

                    // center the map on the next location
                    gameCenterMap();
               }
          }
     }

     // check to make sure we don't go out-of-bounds by seeing if all
     // markers have been consumed
     if(currentMarkerIndex == -1)
     {
          var scoreMsg = "";

          // figure out a message based upon the user's score
          if(score < (NUM_QUESTIONS / 5))
          {
               scoreMsg = "Jeez, you really suck.";
          }
          else if(score < (NUM_QUESTIONS / 4))
          {
               scoreMsg = "Not the worst but still pretty bad.";
          }
          else if(score < (NUM_QUESTIONS / 3))
          {
               scoreMsg = "You can probably do better.";
          }
          else if(score < (NUM_QUESTIONS / 2))
          {
               scoreMsg = "Not the best but also not the worst.";
          }
          else if(score < NUM_QUESTIONS - (NUM_QUESTIONS / 3))
          {
               scoreMsg = "You're getting there!";
          }
          else if(score < NUM_QUESTIONS - (NUM_QUESTIONS / 4))
          {
               scoreMsg = "Not bad!";
          }
          else if(score < NUM_QUESTIONS - (NUM_QUESTIONS / 5))
          {
               scoreMsg = "You did pretty well!";
          }
          else if(score == NUM_QUESTIONS)
          {
               scoreMsg = "Wow, you must have a real hard-on for the resort!";
          }

          // let the user know he has completed the game
          infoWindow.setContent("<span style='color:blue'>Congratulations!</span><br /><br />You have completed Race Around the Kingdom.<br /><br />Your final score is " + score + " points.<br /><br /><span style=\"color:red\">" + scoreMsg + "</span><br /><br /><form><input type=\"button\" id=\"finishGame\" onClick=\"endGame();\" value=\"Finish\" /></form>");
     }
}

// set the ability to enable map centering
function setEnableCentering(enabled)
{
     enableCentering = enabled;
}

// set whether the game is enabled
function setGameEnabled(enabled)
{
     gameEnabled = enabled;
}

// increment the timer
function incrementTimer()
{
     var startingZero = "";

     // check to make sure the game is enabled
     if(gameEnabled)
     {
          // increment the timer
          secondsElapsed += 1;

          // check to see if we need to add a leading 0 to the seconds
          if((secondsElapsed % 60) < 10)
          {
               startingZero = "0";
          }
          else
          {
               startingZero = "";
          }

          // update the time display for minutes and seconds
          $("#timeDisplay").html("Time: " + Math.floor(secondsElapsed / 60) + ":" + startingZero + (secondsElapsed % 60));

          // set the timeout again
          gameTimeout = setTimeout("incrementTimer()",1000);
     }
}

// start the game
function startGame()
{
     // re-configure the map to hide the default UI controls
     var options = {zoom: 20,
       mapTypeControl: false,
       navigationControl: false,
       scaleControl: false,
       scrollwheel: false,
       disableDoubleClickZoom: true,
       mapTypeId: google.maps.MapTypeId.SATELLITE};

     // set the options
     mapObj.setOptions(options);

     // close the InfoWindow
     infoWindow.close();

     // hide the table of links and show the game rules
     $("#dataDisplay").css("display","none");
     $("#gameRules").css("display","block");     

     // hide the Show/Hide All Markers buttons
     $("#showAllBtn").css("display","none");
     $("#hideAllBtn").css("display","none");

     // hide the Start Game button
     $("#startGameBtn").css("display","none");

     // show the End Game button and the score display
     $("#endGameBtn").css("display","inline");
     $("#centerMapBtn").css("display","inline");
     $("#scoreDisplay").css("display","inline");
     $("#timeDisplay").css("display","inline");
     $("#gameRulesBtn").css("display","none");      

     // hide all the markers so the player doesn't cheat
     hideAllMarkers();

     // disable any active question
     questionActive = false;

     // reset the score and the display
     score = 0;
     secondsElapsed = 0;
     $("#scoreDisplay").html("Score: 0/" + NUM_QUESTIONS + " points");
     $("#timeDisplay").html("Time: 0:00");

     // reset the data so we can get a new random set of locations
     resetData();

     // enable the game
     setGameEnabled(true);

     // disable the user's ability to click a link and center the map
     setEnableCentering(false);

     // reset the array of game markers
     gameMarkerArray = markers;

     // reset the current selection index
     currentMarkerIndex = -1;

     // we haven't visited anything yet
     placesVisited = 0;

     // center the map at the Disneyland marker
     findNextMarker();

     // start the timer
     gameTimeout = setTimeout("incrementTimer()",1000);
}

// end the game
function endGame()
{
     // clear the game timeout
     clearTimeout(gameTimeout);

     // re-configure the map to show the default UI controls
     var options = {zoom: 20,
       mapTypeControl: true,
       navigationControl: true,
       scaleControl: true,
       scrollwheel: true,
       disableDoubleClickZoom: false,
       mapTypeId: google.maps.MapTypeId.SATELLITE};

     // set the options
     mapObj.setOptions(options);

     // close the InfoWindow
     infoWindow.close();

     // show the table of links and hide the game rules
     $("#dataDisplay").css("display","block");
     $("#gameRules").css("display","none"); 

     // show the Show/Hide All Markers buttons
     $("#showAllBtn").css("display","inline");
     $("#hideAllBtn").css("display","inline");

     // show the Start Game button
     $("#startGameBtn").css("display","inline");

     // hide the End Game button and the score display
     $("#endGameBtn").css("display","none");
     $("#centerMapBtn").css("display","none");
     $("#scoreDisplay").css("display","none");
     $("#timeDisplay").css("display","none");
     $("#gameRulesBtn").css("display","inline");    

     // disable the game
     setGameEnabled(false);

     // enable the user's ability to click a link and center the map
     setEnableCentering(true);

     // show all the markers
     showAllMarkers();  
}

// show all the markers
function showAllMarkers()
{
     // make sure the game is not enabled
     if(!gameEnabled)
     {
          // define an index variable and iterate through all the markers
          var m = 0;
          for(m in markers)
          {
               // show the marker
               markers[m].setVisible(true);
          }
     }
}

// hide all the markers
function hideAllMarkers()
{
     // make sure the game is not enabled
     if(!gameEnabled)
     {
          // define an index variable and iterate through all the markers
          var m = 0;
          for(m in markers)
          {
               // hide the marker
               markers[m].setVisible(false);
          }
     }
}

// toggle the Game Rules display
function toggleRules()
{
     // check to see if the Rules area is already hidden
     if($("#gameRules").css("display") == "none")
     {
          // hide the data display
          $("#dataDisplay").css("display","none");

          // make the Rules area visible with a "block" format
          $("#gameRules").css("display","block");
     }
     else
     {
          // hide the Rules area
          $("#gameRules").css("display","none");

          // show the data display
          $("#dataDisplay").css("display","block");
     }
}

// ==================================
// MISCELLANEOUS STUFF
// ==================================

// assign the "ready" function so the AJAX loading can begin
$(document).ready
(
	myReadyFunction
);