<?php
# start Session to hold input data
session_start();
unset($_SESSION['ids']);
# Check if input comes from an uploaded file
if ($_FILES['uploadFile']['name']) {
    $_REQUEST['fasta']=  file_get_contents($_FILES['uploadFile']['tmp_name']);
}
?>
<html>
        <head>
            <title>UBI</title>
            <link rel="stylesheet" href="style-form.css">
            <meta charset="UTF-8">

        </head>
        <body>
           <div id="container" style="overflow: auto">
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
    $_SESSION['data']=$_REQUEST['fasta'];  
    # Check if this is a FASTA (first character ">")
/*
    if (!isFasta($_REQUEST['fasta'])) { # Not fasta: take as raw sequence
            $_SESSION['data']=$_REQUEST['fasta'];  
            $_SESSION['id']='';
    } else {
        $fasta = parse_Fasta($_REQUEST['fasta']);
        //$_session['data'] = $fasta['sequence'];
        $_session['data'] = $fasta;
    //    $_SESSION['id']=implode("|",array($fasta['db'],$fasta['id'],$fasta['info']));
    }
*/
   if (isfasta($_REQUEST['fasta'])){
      $data=parse_Fasta($_REQUEST['fasta']);
      $_SESSION['nquery']=count($data['id']);	
      $_SESSION['ids']=$data['id'];
   }
   print "<META http-equiv='refresh' content='3;URL=parseblast.php'>";
    exit;

function isFasta($f) {
    return (substr($f,0,1) == ">");
}

function parse_Fasta ($f) {
    $data=array('db'=>array(),'id'=>array(),'swp'=>array(),'info'=> array(), 'sequence'=> array());
    $seqs = explode(">",$f);
    foreach ($seqs as $seq){
	    $lines = explode("\n",$seq,2);
  	    if (preg_match("/\|/",$lines[0])){
	    list($db,$id,$info) = explode("|",$lines[0]);
	    list ($swp,$info) = explode(" ",$info,2);
	    }
	    else {
		$id=$lines[0];
                $db="NA";
		$info="NA";
		$swp="NA";
	    }
	    $db=substr($db,1);
	    array_push($data['db'],$db);
	    array_push($data['id'],$id);
	    array_push($data['swp'],$swp);
	    array_push($data['info'],$info);
	    array_push($data['sequence'],$lines[1]);
    }
    return $data;
}
?>
