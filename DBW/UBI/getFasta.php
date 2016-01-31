<?php
session_start();
header("Content-type:text/plain");
if (!isset($_REQUEST['id']) or !isset($_SESSION['data']) or !isset($_SESSION['data'][$_REQUEST['id']])) {
    print "<h2>Error: </h2>";
} else {
    header("Content-type:text/plain");
    print ">".$_SESSION['data'][$_REQUEST['id']]['db']."|".
            $_SESSION['data'][$_REQUEST['id']]['id']."|".
            $_SESSION['data'][$_REQUEST['id']]['info']."\n".
            $_SESSION['data'][$_REQUEST['id']]['sequence']."\n";
}
