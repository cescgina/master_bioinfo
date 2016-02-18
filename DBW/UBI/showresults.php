<?php
    session_start();
    if (!$_SESSION['ids']){
        $id='Anonymous sequence';
        $nquery=1;
     }
    else{
        $ids=$_SESSION['ids'];
        array_shift($ids);
        $nquery=count($ids);
    }
    $result=$_SESSION['output'];
?>
  <html>
        <head>
            <title>UBI</title>
    		<meta charset="UTF-8">

            <?php
                $i=0;
                while ($i<count($result)){
                     if (preg_match("/No hits found/",$result[$i])){
                        $error=1;
                        break;
                     }		
                    elseif (preg_match("/Sequences producing/",$result[$i])){
                        $resultpos=$i+2;
                        break;
                    }	
                    $i++;
                }		
                echo '<link rel="stylesheet" href="style.css">';
            ?>
        </head>
        <body>
            <div id="container">
                <header id="top">
                    <h1>UBI</h1>
                    <h2>The Ultimate Blast Interface</h2>
                </header>
            <div id="content">
		<?php
		  for ($nq=0;$nq<$nquery;$nq++){
                ?>		    
                <h4>Your Query:</h4>
                <div id="queryid">
                    <div id="ID"><span>ID</span></div>
                    <div id="dataid">
                        <span>
                        <?php 
                            if ($ids){
                                echo $ids[$nq];
                            }
                            else {
                                echo $id;
                            }
                        ?>
                        </span>
                    </div>
                </div>
		<?php 
		if ($error) {
            echo '<div id="diverror">';
            echo '<h2>Your query produced no hits</h2>';
            echo '</div>';
        }
		else{
            ?>
                <div id="tablediv">
                     <?php
                        echo '<table id="results">';
                        echo '<tr>';              
                        echo '<th>Sequences producing significant alignments:</th>';
                        echo '<th>Score(bits)</th>';
                        echo '<th>E value</th>';
                        echo '</tr>';
                        while ($resultpos<count($result)){
                            if (!trim($result[$resultpos])){
                                break;
                            }
                            $info=preg_split('/\s+/',$result[$resultpos]);
                            $n=count($info);
                            $info_update=array(implode(" ",array_slice($info,0,$n-2)));
                            array_push($info_update,$info[$n-2]);
                            array_push($info_update,$info[$n-1]); 
                            echo '<tr>';
                            foreach ($info_update as $field){
                                echo '<td>'.trim($field).'</td>';
                            }
                            echo '</tr>';
                            $resultpos++;
                        }
                        echo '</table>';
                        echo '</div>';
			             $error=0;
			             while ($resultpos<count($result)){
                             if (preg_match("/No hits found/",$result[$resultpos])){
                                 $error=1;
                                break;
                             }		
                             else if (preg_match("/Sequences producing/",$result[$resultpos])){
                                $resultpos+=2;
                                break;
                             }	
                             $resultpos++;
                        }		
        }
}
//session_unset();
                    ?>
            <div id="divlinks">
                <a href="#top" id="links">
                    <span id=home>
                        Back to top
                    </span>
                </a>
                <a href="UBI.html" id="links">
                    <span id=home>
                        Query again
                    </span>
                </a>	
                    </div> 
            </div>  
        </div>
        </body>
</html>

