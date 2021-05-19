<?php

// gameService.php by Matt Fritz
// October 28, 2010
// Handles requests for new questions and validation of answers from
// the main system and is used as a web service.

// set up all the locations
$locations = array();
$locations[0] = "Disneyland";
$locations[1] = "Disney California Adventure";
$locations[2] = "Big Thunder Mountain Railroad";
$locations[3] = "Main Street USA";
$locations[4] = "Indiana Jones Adventure: The Temple Of The Forbidden Eye";
$locations[5] = "Matterhorn Bobsleds";
$locations[6] = "Buzz Lightyear Astro Blasters";
$locations[7] = "It's a Small World";
$locations[8] = "Finding Nemo Submarine Voyage";
$locations[9] = "Tomorrowland";
$locations[10] = "Mickey's Toontown";
$locations[11] = "Star Tours";
$locations[12] = "Autopia";
$locations[13] = "Fantasyland";
$locations[14] = "Peter Pan's Flight";
$locations[15] = "Mad Tea Party";
$locations[16] = "Hilton Anaheim";
$locations[17] = "Innoventions";
$locations[18] = "Alice in Wonderland";
$locations[19] = "Disneyland Railroad - Main Street Station";
$locations[20] = "Disneyland Railroad - Toontown Station";
$locations[21] = "Mickey's House and Meet Mickey";
$locations[22] = "Disneyland Monorail";
$locations[23] = "Snow White's Scary Adventures";
$locations[24] = "Pinocchio's Daring Journey";
$locations[25] = "Disneyland Monorail";
$locations[26] = "Redd Rockett's Pizza Port";
$locations[27] = "Storybook Land Canal Boats";
$locations[28] = "Disneyland Railroad - New Orleans Station";
$locations[29] = "Roger Rabbit's Car Toon Spin";
$locations[30] = "Disneyland Railroad - Tomorrowland Station";
$locations[31] = "King Arthur Carousel";
$locations[32] = "Casey Jr. Circus Train";
$locations[33] = "Rancho del Zocalo Restaurante";
$locations[34] = "Central Plaza (The Hub)";
$locations[35] = "Mark Twain Riverboat";
$locations[36] = "Animation Academy";
$locations[37] = "Tomorrowland Terrace";
$locations[38] = "Penny Arcade";
$locations[39] = "Princess Fantasy Faire";
$locations[40] = "Chip 'n Dale Treehouse";
$locations[41] = "Village Haus Restaurant";
$locations[42] = "Frontierland Shootin' Exposition";
$locations[43] = "Pooh Corner";
$locations[44] = "Adventureland Bazaar";
$locations[45] = "Anaheim Plaza Hotel &amp; Suites";
$locations[46] = "Heimlich's Chew Chew Train";
$locations[47] = "Best Western Anaheim Inn";
$locations[48] = "South Seas Traders";
$locations[49] = "Toontown Five &amp; Dime";

// set up the questions array
$questions = array();

// add the questions
$questions[0] = array("Question"=>"What year was Disneyland opened?", "Answers"=>"1955@1962@1965@1975","CorrectAnswer"=>"1955");

$questions[1] = array("Question"=>"Before it opened, something else occupied the space of California Adventures.  What was it?", "Answers"=>"Eeyore Parking Area@Bounty Interactive Paper Towel Experience@Dirt@More bathrooms than you have ever seen","CorrectAnswer"=>"Eeyore Parking Area");

$questions[2] = array("Question"=>"The story of Big Thunder Mountain is based around what?", "Answers"=>"Old Mining Town@Hovel@Colonial Williamsburg@What's with this history crap?","CorrectAnswer"=>"Old Mining Town");

$questions[3] = array("Question"=>"Walt based Main Street USA on which city?", "Answers"=>"Marcelene, Missouri@Buttsville, Pennsylvania@Death Valley, California@Current, Confusion","CorrectAnswer"=>"Marcelene, Missouri");

$questions[4] = array("Question"=>"When the Imagineers were creating The Indiana Jones Adventure, they had to wait for what?", "Answers"=>"Technology to catch up@A conference room@Michael Eisner to tell them they were wrong@Harrison Ford to disable the traps in the Temple of the Forbidden Eye","CorrectAnswer"=>"Technology to catch up");

$questions[5] = array("Question"=>"In the Matterhorn, the \\\"Wells Expedition\\\" crate references what?", "Answers"=>"Disney executive who died in a helicopter accident@A second attempt at the Bads Expedition@It's just a crate@The Yeti trying to find food","CorrectAnswer"=>"Disney executive who died in a helicopter accident");

$questions[6] = array("Question"=>"In Buzz Lightyear Astro Blasters, the Little Green Men are trying to collect what?", "Answers"=>"Batteries@Cheese@Hot chocolate@Taxes","CorrectAnswer"=>"Batteries");

$questions[7] = array("Question"=>"Near It's a Small World, you can find a bush shaped like what?", "Answers"=>"Sea serpent@Michael Eisner@Mickey Mouse@Mickey Mouse's son","CorrectAnswer"=>"Sea serpent");

$questions[8] = array("Question"=>"Before Pixar crapped it up, the Finding Nemo Submarine Voyage used to be what?", "Answers"=>"A decent submarine ride with Captain Nemo@The Sardine Experience@Interactive Canned Tuna Experience@American Mental Health Association's Tribute to Claustrophobia","CorrectAnswer"=>"A decent submarine ride with Captain Nemo");

$questions[9] = array("Question"=>"Tomorrowland used to have a classic ride that used a track above the land.  What was it?", "Answers"=>"Peoplemover@People Remover@The Goodyear Publicity Deluxe@Something else that isn't there any more","CorrectAnswer"=>"Peoplemover");

$questions[10] = array("Question"=>"Mickey's Toontown...", "Answers"=>"Sucks@Sucks@Sucks@Sucks","CorrectAnswer"=>"Sucks");

$questions[11] = array("Question"=>"Star Tours...", "Answers"=>"Sucks@Sucks@Sucks@Sucks","CorrectAnswer"=>"Sucks");

$questions[12] = array("Question"=>"Autopia was sponsored by what company in 2000?", "Answers"=>"Chevron@BF Goodrich@Jack Daniel's@Texaco","CorrectAnswer"=>"Chevron");

$questions[13] = array("Question"=>"Fantasyland includes what classic ride that was a 1955 Original?", "Answers"=>"Mister Toad's Wild Ride@Flying Saucers@Splash Mountain@The Haunted Mansion","CorrectAnswer"=>"Mister Toad's Wild Ride");

$questions[14] = array("Question"=>"Peter Pan's Flight has...", "Answers"=>"Wait times that are unjustifiably long@The ability to seat 12 people comfortably@Poor safety precautions@Wait, isn't that in Tomorrowland?","CorrectAnswer"=>"Wait times that are unjustifiably long");

$questions[15] = array("Question"=>"After a big lunch, Mad Tea Party may make you...", "Answers"=>"Vomit@Vomit@Vomit@Vomit","CorrectAnswer"=>"Vomit");

$questions[16] = array("Question"=>"The Hilton Anaheim...", "Answers"=>"Is not in Disneyland@Is not actually in Anaheim@Is in Fullerton@Doesn't actually exist","CorrectAnswer"=>"Is not in Disneyland");

$questions[17] = array("Question"=>"Currently, (2010), the lower floor of Innoventions contains...", "Answers"=>"Too much publicity for Microsoft@Not enough publicity for Microsoft@The entirety of Cal State Fullerton@There's actually a lower floor?","CorrectAnswer"=>"Too much publicity for Microsoft");

$questions[17] = array("Question"=>"In August 2010, OSHA forever ruined which classic attraction in the name of safety?", "Answers"=>"Alice in Wonderland@Mad Hatter@Star Traders@The OSHA Experience, sponsored by Tacoma Narrows LLC","CorrectAnswer"=>"Alice in Wonderland");

$questions[18] = array("Question"=>"The Disneyland Railroad includes what?", "Answers"=>"A Grand Canyon diorama@The Jeffrey Dahmer Cargo Train@A hovercraft containing multiple eels@A wicker basket with wheels","CorrectAnswer"=>"A Grand Canyon diorama");

$questions[19] = array("Question"=>"The Tomorrowland Station of the Disneyland Railroad is...", "Answers"=>"By Autopia@By Autopia@By Autopia@By Autopia","CorrectAnswer"=>"By Autopia");

$questions[20] = array("Question"=>"At Mickey's House, you get to...", "Answers"=>"Meet Mickey@Destroy cherished childhood memories@Meet Donald@Meet Zombie Walt Disney","CorrectAnswer"=>"Meet Mickey");

$questions[21] = array("Question"=>"The Disneyland Monorail is...", "Answers"=>"The first consistently operating monorail of its kind@Transportation for zombies@Transportation for raptors@Transportation for zombie raptors","CorrectAnswer"=>"The first consistently operating monorail of its kind");

$questions[22] = array("Question"=>"What ride was originally considered too damn scary that it had to be re-designed?", "Answers"=>"Snow White's Scary Adventures@Peter Pan's Flight@Peter Pan's Downward Tail Spin@Zombies and You: K - 5 Edition","CorrectAnswer"=>"Snow White's Scary Adventures");

// check the input from the user
function checkInput($input)
{
     if($input == "getNextQuestion")
     {
          // get the next question from the structure
          getNextQuestion();
     }
     elseif($input == "checkAnswer")
     {
          // check the answer that the player gave
          checkAnswer($_GET['question'],html_entity_decode($_GET['answer'], ENT_QUOTES));
     }
     elseif($input == "qToJson")
     {
          // convert the questions to JSON
          questionsToJSON();
     }
     elseif($input == "pToJson")
     {
          // convert the places.xml file to JSON
          placesToJSON();
     }
}

// get the next question from the structure
function getNextQuestion()
{
     global $questions;

     // get a random question index
     $randomIndex = rand(0, sizeof($questions) - 1);

     // get the question specified by the index
     $question = $questions[$randomIndex];

     // get all possible answers as an array
     $answers = explode("@", $question["Answers"]);

     // create an HTML submission form
     $form = "<span style=\"color:blue\">" . $question["Question"] . "</span><br /><br />";
     $form .= "<form>";
     $form .= "<div style=\"text-align:left\">";
     
     // shuffle the array to make sure the answers appear in a random order
     shuffle($answers);

     // iterate through the question and get all possible answers
     for($i = 0; $i < sizeof($answers); $i++)
     {
          $form .= "<input type=\"radio\" name=\"answer\" id=\"answer" . $i . "\" value=\"" . $answers[$i] . "\" />" . $answers[$i] . "<br />";
     }

     $form .= "</div>";

     // add the question number
     $form .= "<input type=\"hidden\" id=\"questionNum\" value=\"" . $randomIndex . "\" />";

     // add the submission button
     $form .= "<br /><input type=\"button\" id=\"submitAnswer\" value=\"Submit\" onClick=\"checkAnswer($('#questionNum').attr('value'), $('input:checked').attr('value'));\" />";

     $form .= "</form>";

     // spit out the generated form
     echo $form;
}

// convert the questions to JSON
function questionsToJSON()
{
     global $questions;

     echo "<pre>";
     echo "{\n";
     echo "   \"questions\":\n";
     echo "   [\n";

     // iterate through the questions and convert them to JSON objects
     $qSize = sizeof($questions);
     for($i = 0; $i < $qSize; $i++)
     {
          echo "      {\n";

          // add the question text
          echo "         \"question\": \"" . $questions[$i]['Question'] . "\",\n";

          // add the answers
          echo "         \"answers\":\n";
          echo "         [\n";

          // iterate through the answers
          $aArray = split("@", $questions[$i]['Answers']);
          $aSize = sizeof($aArray);
          for($j = 0; $j < $aSize; $j++)
          {
             echo "                \"" . $aArray[$j] . "\"";

             // add a comma if we're not the last item
             if($j < $aSize - 1)
             {
                echo ",";
             }

             echo "\n";
          }

          echo "         ]\n";

          // question object ending
          echo "      }";

          // only add a comma if we're not the last item
          if($i < $qSize - 1)
          {
               echo ",";
          }

          // add the new line before the next object
          echo "\n";
     }

     echo "   ]\n";
     echo "}";
     echo "</pre>";
}

// convert the places.xml file to JSON
function placesToJSON()
{
     $xml = simplexml_load_file("places.xml");

     echo "<pre>";
     echo "{\n";
     echo "   \"places\":\n";
     echo "   [\n";

     // how many places do we have?
     $pCount = $xml->children()->count();
     $i = 0;

     // get each SimpleXMLElement object (<place> tag)
     foreach($xml->children() as $c)
     {
        // get the children tags of the <place> tag
        $place = $c->children();

        echo "      {\n";
        echo "         \"name\": \"" . $place->name . "\",\n";
        echo "         \"geolat\": " . $place->geolat . ",\n";
        echo "         \"geolong\": " . $place->geolong . "\n";
        echo "      }";

        $i++;

        // only apply the comma if we're not the last element
        if($i < $pCount)
        {
             echo ",";
        }

        // apply the new-line
        echo "\n";
     }

     echo "   ]\n";
     echo "}";
     echo "</pre>";
}

// check the answer that the user provided
function checkAnswer($theQuestionNum,$theAnswer)
{
     global $questions;

     // check to see if the player got the question correct
     if(stripslashes($theAnswer) == $questions[$theQuestionNum]["CorrectAnswer"])
     {
          // return a value of "correct"
          echo "correct";
     }
     else
     {
          // return a value of "wrong"
          echo "wrong";
     }
}

if(!empty($_GET['command']))
{
     checkInput($_GET['command']);
}

?>