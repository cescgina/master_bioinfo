<?php
# start Session to hold input data
session_start();
# Check if input comes from an uploaded file
if ($_FILES['uploadFile']['name']) {
    $_REQUEST['fasta']=  file_get_contents($_FILES['uploadFile']['tmp_name']);
}
?>
<html>
        <head>
            <title>UBI</title>
            <link rel="stylesheet" href="style-form.css">
        </head>
        <body>
           <div id="container">
                <header>
                    <h1>UBI</h1>
                    <h2>The Ultimate Blast Interface</h2>
                </header>
               <div id="wait">
                   <?php
                        if (!$_REQUEST['fasta']) { 
                            echo '<h2>Error: Received request was empty</h2>';
                            echo "<h4>We'll redirect you to our homepage so you can do another search</h4>";
                            echo "<br>";
                            echo "<a href='UBI.html'>If you are not redirected automatically, please click here</a>";
                            echo '</div>';
                            print "<META http-equiv='refresh' content='4;URL=UBI.html'>";
                            exit;
                        }
                        else {
                            echo "<h3>Your input is being processed, we'll show you the results as soon as possible</h3>";
                            echo "<h3>Have a cup of coffe meanwhile</h3>";
                            echo '<img src="http://www.clipartbest.com/cliparts/Kcn/ozR/KcnozR7oi.jpeg">';
                        }
                   ?>
               </div>
            </div>
    </body>
</html>

<?php
# Process input
    $_SESSION['db']=$_REQUEST['db'];
    # Check if this is a FASTA (first character ">")
    if (!isFasta($_REQUEST['fasta'])) { # Not fasta: take as raw sequence
            $_SESSION['data']=$_REQUEST['fasta'];  
            $_SESSION['id']='';
    } else {
        $fasta = parse_Fasta($_REQUEST['fasta']);
        $_SESSION['data'] = $fasta['sequence'];
        $_SESSION['id']=implode("|",array($fasta['db'],$fasta['id'],$fasta['info']));
    }
   print "<META http-equiv='refresh' content='3;URL=parseblast.php'>";
    exit;

function isFasta($f) {
    return (substr($f,0,1) == ">");
}

function parse_Fasta ($f) {
    $lines = explode("\n",$f,2);
    list($db,$id,$info) = explode("|",$lines[0]);
    list ($swp,$info) = explode(" ",$info,2);
    $db=substr($db,1);
    $data = array('db'=> $db, 'id'=> $id, 'swpid' => $swp, 'info' => $info, 'sequence' => $lines[1]);
    return $data;
}
?>