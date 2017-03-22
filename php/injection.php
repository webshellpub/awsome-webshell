<?php
$mysql_server_name = "localhost";
$mysql_username = "root";
$mysql_password = "isno";
$mysql_database = "injection";

$conn=mysql_connect( $mysql_server_name, $mysql_username, $mysql_password );
mysql_select_db($mysql_database,$conn);
mysql_query("SET NAMES 'utf8'");
$id=$_GET['id'];
$sql = "select * from test where id=$id";
$result = mysql_db_query( $mysql_database, $sql,$conn );
$row = mysql_fetch_row($result);

p('<html><head>');
p('<meta http-equiv="Content-Type" content="text/html; charset=GB2312">');
p('<title>MYSQL INJECTION TEST</title></head><body>');
p('<p><b><font size="3">MYSQL INJECTION TEST</font></b></p>');
p('<table style="border-right: medium none; border-top: medium none; border-left: medium none; border-bottom: medium none; border-collapse: collapse" cellspacing="0" cellpadding="0" border="1">');
p('<tbody>');

p1();
p('data type');
p2();
p('content');
p3();

p1();
p('INT');
p2();
p($row[0]);
p3();

p1();
p('BLOB');
p2();
p($row[1]);
p3();

p1();
p('CHAR');
p2();
p($row[2]);
p3();

p1();
p('DATE');
p2();
p($row[3]);
p3();

p1();
p('LONGBLOB');
p2();
p($row[4]);
p3();

p1();
p('TEXT');
p2();
p($row[5]);
p3();

p1();
p('TIME');
p2();
p($row[6]);
p3();

p1();
p('VARCHAR');
p2();
p($row[7]);
p3();

p('</tbody></table><td><div>&nbsp;</div></td>');
q('by：');
s();
p('<td><div>&nbsp;</div></td>');
q('blog：<a href="http://www.sai52.com" target="_blank">www.');
s();
p('.com</a></body></html>');

function p($line){
echo $line."\n";
}

function q($line1){
echo $line1;
}

function s(){
echo str_replace('.','','s.a.i.5.2');
}

function p1(){
p('<tr><td style="border-right: windowtext 1pt solid; padding-right: 5.4pt; border-top: windowtext 1pt solid; padding-left: 5.4pt; padding-bottom: 0cm; border-left: windowtext 1pt solid; padding-top: 0cm; border-bottom: windowtext 1pt solid; background-color: transparent" valign="top"><div>');
}

function p2(){
p('</div><div>&nbsp;</div></td><td style="border-right: windowtext 1pt solid; padding-right: 5.4pt; border-top: windowtext 1pt solid; padding-left: 5.4pt; border-left-color: #ebe9ed; padding-bottom: 0cm; padding-top: 0cm; border-bottom: windowtext 1pt solid; background-color: transparent" valign="top"><div>');
}

function p3(){
p('</div><div>&nbsp;</div></td></tr>');
}

?>