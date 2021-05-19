<?php

  // proxy.php originally by Donald Patterson
  // Modified on October 17, 2010 by Matt Fritz to read from a suitable portion of the query string instead of taking the entire thing
  // Cleaned up the code a little bit too

  $url = "";
  if(!empty($_GET['url']))
  {
       // Get the requested url from our proxy url
       $url = $_GET['url'];

       // initialize curl with given url
       $ch = curl_init($url);

       // Tell curl to write the response to a variable
       curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

       // Tell curl to follow any redirects
       curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);

       $response = curl_exec($ch);

       $cType = curl_getinfo($ch,CURLINFO_CONTENT_TYPE);

       // Output the right mime/type
       header('Content-type: '.$cType);

       // Pass through the data 
       print $response;

       // close the cURL connection
       curl_close($ch);
  }
  else
  {
       // spit back out an error message
       echo "Please specify a URL in which to proxy";
  }

?>
