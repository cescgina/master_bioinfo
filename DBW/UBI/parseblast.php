<?php
/* 
 * Settings pointing to BLAST installation details (adapted to mmb.pcb.ub.es server)
 */
$GLOBALS['blastHome'] = "/home/dbw00/blast";
$GLOBALS['blastDbsDir'] = $GLOBALS['blastHome']."/dbs/";
$GLOBALS['blastExe'] = $GLOBALS['blastHome']."/bin/blastall";
$GLOBALS['blastDbs'] = array ("SwissProt" => "sprot", "PDB" => "pdb_seqres.txt");
$GLOBALS['blastCmdLine'] = $GLOBALS['blastExe'].' -p blastp -e 0.001 -v 100 -b 0 -d ';
/* Blast command line, check blastall --help for usage
* -p  Program Name [String]
* -d  Database [String]
* -i  Query File [File In]
* -o  BLAST report Output File [File Out] 
* -e  Expectation value (E) 
* -m  alignment view options:
*   0 = pairwise, 
*   1 = query-anchored showing identities, 
*   2 = query-anchored no identities,
*   3 = flat query-anchored, show identities, 
*   4 = flat query-anchored, no identities,
*   5 = query-anchored no identities and blunt ends, 
*   6 = flat query-anchored, no identities and blunt ends,
*   7 = XML Blast output, 
*   8 = tabular, 
*   9 = tabular with comment lines
* 10 ASN, text
* 11 ASN, binary [Integer]  default = 0 range from 0 to 11
* -v  Number of database sequences to show one-line descriptions for (V) default = 500
* -b  Number of database sequence to show alignments for (B) default = 250
* -M  Matrix [String] default = BLOSUM62
* -T  Produce HTML output [T/F] default = F
*/
    session_start();
    $filename="tmp/".uniqid().".txt";
    file_put_contents($filename, $_SESSION['data']);
    $results=exec($GLOBALS['blastCmdLine'].$GLOBALS['blastDbsDir'].$GLOBALS['blastDbs'][$_SESSION['db']].' -i '.escapeshellarg($filename),$output);
    unlink($filename);
    $_SESSION['output']=$output;
    print "<META http-equiv='refresh' content='0;URL=showresults.php'>";
    exit;
?>
