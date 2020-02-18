<?php 
$var = "<div>\n</div>";
echo "Hostname is: ", gethostname();
echo $var;
echo "Server IP: ", $_SERVER['SERVER_ADDR'];
echo $var;
echo "The time is: " . date("h:i:sa");
?>
