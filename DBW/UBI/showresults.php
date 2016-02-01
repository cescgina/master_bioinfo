<?php
    session_start();
    if (!$_SESSION['id']){
        $id='Anonymous sequence';
     }
    else{
        $id=$_SESSION['id'];
    }
    $sequence=$_SESSION['data'];
    $result=$_SESSION['output'];
?>
  <html>
        <head>
            <title>UBI</title>
            <?php
                if (trim($result[21]) === "***** No hits found ******"){
                    echo '<link rel="stylesheet" href="style-form.css">';
                }
                else {
                    echo '<link rel="stylesheet" href="style.css">';
                }
            ?>
        </head>
        <body>
            <div id="container">
                <header>
                    <h1>UBI</h1>
                    <h2>The Ultimate Blast Interface</h2>
                </header>
                <?php
                    if (trim($result[21]) === "***** No hits found ******"){
                        echo '<div id="diverror">';
                        echo '<h2>Your query produced no hits</h2>';
                        echo "<h4>We'll redirect you to our homepage so you can do another search</h4>";
                        echo "<br>";
                        echo "<a href='UBI.html'>If you are not redirected automatically, please click here</a>";
                        echo '</div>';
                        print "<META http-equiv='refresh' content='3;URL=UBI.html'>";
                        exit;
                    }
                ?>
                <h4>Your Query:</h4>
                <div id="queryid">
                    <div id="ID"><span>ID</span></div>
                    <div id="dataid">
                        <span>
                        <?php 
                            echo $id;
                        ?>
                        </span>
                    </div>
                </div>
                <div id="queryseq">
                    <div id="seq">
                        <span>SEQUENCE</span>
                    </div>
                    <div id="dataseq">
                        <span>
                        <?php
                            echo $sequence;
                        ?>
                        </span>
                    </div>

                </div>
                <div id="tablediv">
                     <?php
                        echo '<table id="results">';
                        echo '<tr>';              
                        echo '<th>Sequences producing significant alignments:</th>';
                        echo '<th>Score(bits)</th>';
                        echo '<th>E value</th>';
                        echo '</tr>';

                        $i=26;
                        while ($i<count($result)){
                            if (!trim($result[$i])){
                                break;
                            }
                            $info=preg_split('/\s+/',$result[$i]);
                            $n=count($info);
                            $info_update=array(implode(" ",array_slice($info,0,$n-2)));
                            array_push($info_update,$info[$n-2]);
                            array_push($info_update,$info[$n-1]); 
                            echo '<tr>';
                            foreach ($info_update as $field){
                                echo '<td>'.trim($field).'</td>';
                            }
                            echo '</tr>';
                            $i++;
                        }
                        echo '</table>'
                        ?>
                    </div>
                    <div style="height:20px;width:100%;background-color:white;"></div>
            </div>    
        </body>
</html>