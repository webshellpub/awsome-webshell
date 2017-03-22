<%
'*******************************************************
'空间文件管理助手 For Asp 2.0		-- 2007.2.28
'微网网络	www.vwen.com
'ASP技术QQ交流群	19535106
'原创作品 没有最好 只有更好
'*******************************************************

Option Explicit				'强制定义
'On error resume Next		'运行错误机制,忽略错误继续执行 
dim MainPath,sPath,FullsPath
dim FileLoginName,FileLoginPwd,loginname,loginpwd
FileLoginName="e6de8ba0d5492e441"	'登陆用户名md5+"1"dirof
FileLoginPwd="e6de8ba0d5492e442"	'登陆密码md5+"2"
MainPath = "./"						'设置此系统管理的主文件夹目录,必须以/结束.

Dim fs, sAction, sFile, sFolder, sFileType, scriptname, dbfile, ReadStream, WriteStream, WriteFile, fileobject,filename
Dim filecollection, file, startpath, lineid, bgcolor, bgcolor_on, bgcolor_off, foldercollection, folder, errornum, errorcode
errornum = 0
errorcode = ""
scriptname=Request.ServerVariables("Script_Name")		'URL名称
sAction = Request.Querystring("action")					'动作类型

'*******************************************************
'MD5加密函数
	Private Const BITS_TO_A_BYTE = 8
	Private Const BYTES_TO_A_WORD = 4
	Private Const BITS_TO_A_WORD = 32

	Private m_lOnBits(30)
	Private m_l2Power(30)
	 
	Private Function LShift(lValue, iShiftBits)
		If iShiftBits = 0 Then
			LShift = lValue
			Exit Function
		ElseIf iShiftBits = 31 Then
			If lValue And 1 Then
				LShift = &H80000000
			Else
				LShift = 0
			End If
			Exit Function
		ElseIf iShiftBits < 0 Or iShiftBits > 31 Then
			Err.Raise 6
		End If

		If (lValue And m_l2Power(31 - iShiftBits)) Then
			LShift = ((lValue And m_lOnBits(31 - (iShiftBits + 1))) * m_l2Power(iShiftBits)) Or &H80000000
		Else
			LShift = ((lValue And m_lOnBits(31 - iShiftBits)) * m_l2Power(iShiftBits))
		End If
	End Function

	Private Function RShift(lValue, iShiftBits)
		If iShiftBits = 0 Then
			RShift = lValue
			Exit Function
		ElseIf iShiftBits = 31 Then
			If lValue And &H80000000 Then
				RShift = 1
			Else
				RShift = 0
			End If
			Exit Function
		ElseIf iShiftBits < 0 Or iShiftBits > 31 Then
			Err.Raise 6
		End If
		
		RShift = (lValue And &H7FFFFFFE) \ m_l2Power(iShiftBits)

		If (lValue And &H80000000) Then
			RShift = (RShift Or (&H40000000 \ m_l2Power(iShiftBits - 1)))
		End If
	End Function

	Private Function RotateLeft(lValue, iShiftBits)
		RotateLeft = LShift(lValue, iShiftBits) Or RShift(lValue, (32 - iShiftBits))
	End Function

	Private Function AddUnsigned(lX, lY)
		Dim lX4
		Dim lY4
		Dim lX8
		Dim lY8
		Dim lResult
	 
		lX8 = lX And &H80000000
		lY8 = lY And &H80000000
		lX4 = lX And &H40000000
		lY4 = lY And &H40000000
	 
		lResult = (lX And &H3FFFFFFF) + (lY And &H3FFFFFFF)
	 
		If lX4 And lY4 Then
			lResult = lResult Xor &H80000000 Xor lX8 Xor lY8
		ElseIf lX4 Or lY4 Then
			If lResult And &H40000000 Then
				lResult = lResult Xor &HC0000000 Xor lX8 Xor lY8
			Else
				lResult = lResult Xor &H40000000 Xor lX8 Xor lY8
			End If
		Else
			lResult = lResult Xor lX8 Xor lY8
		End If
	 
		AddUnsigned = lResult
	End Function

	Private Function md5_F(x, y, z)
		md5_F = (x And y) Or ((Not x) And z)
	End Function

	Private Function md5_G(x, y, z)
		md5_G = (x And z) Or (y And (Not z))
	End Function

	Private Function md5_H(x, y, z)
		md5_H = (x Xor y Xor z)
	End Function

	Private Function md5_I(x, y, z)
		md5_I = (y Xor (x Or (Not z)))
	End Function

	Private Sub md5_FF(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_F(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	End Sub

	Private Sub md5_GG(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_G(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	End Sub

	Private Sub md5_HH(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_H(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	End Sub

	Private Sub md5_II(a, b, c, d, x, s, ac)
		a = AddUnsigned(a, AddUnsigned(AddUnsigned(md5_I(b, c, d), x), ac))
		a = RotateLeft(a, s)
		a = AddUnsigned(a, b)
	End Sub

	Private Function ConvertToWordArray(sMessage)
		Dim lMessageLength
		Dim lNumberOfWords
		Dim lWordArray()
		Dim lBytePosition
		Dim lByteCount
		Dim lWordCount
		
		Const MODULUS_BITS = 512
		Const CONGRUENT_BITS = 448
		
		lMessageLength = Len(sMessage)
		
		lNumberOfWords = (((lMessageLength + ((MODULUS_BITS - CONGRUENT_BITS) \ BITS_TO_A_BYTE)) \ (MODULUS_BITS \ BITS_TO_A_BYTE)) + 1) * (MODULUS_BITS \ BITS_TO_A_WORD)
		ReDim lWordArray(lNumberOfWords - 1)
		
		lBytePosition = 0
		lByteCount = 0
		Do Until lByteCount >= lMessageLength
			lWordCount = lByteCount \ BYTES_TO_A_WORD
			lBytePosition = (lByteCount Mod BYTES_TO_A_WORD) * BITS_TO_A_BYTE
			lWordArray(lWordCount) = lWordArray(lWordCount) Or LShift(Asc(Mid(sMessage, lByteCount + 1, 1)), lBytePosition)
			lByteCount = lByteCount + 1
		Loop

		lWordCount = lByteCount \ BYTES_TO_A_WORD
		lBytePosition = (lByteCount Mod BYTES_TO_A_WORD) * BITS_TO_A_BYTE

		lWordArray(lWordCount) = lWordArray(lWordCount) Or LShift(&H80, lBytePosition)

		lWordArray(lNumberOfWords - 2) = LShift(lMessageLength, 3)
		lWordArray(lNumberOfWords - 1) = RShift(lMessageLength, 29)
		
		ConvertToWordArray = lWordArray
	End Function

	Private Function WordToHex(lValue)
		Dim lByte
		Dim lCount
		
		For lCount = 0 To 3
			lByte = RShift(lValue, lCount * BITS_TO_A_BYTE) And m_lOnBits(BITS_TO_A_BYTE - 1)
			WordToHex = WordToHex & Right("0" & Hex(lByte), 2)
		Next
	End Function

	Public Function MD5(sMessage)
		m_lOnBits(0) = CLng(1)
		m_lOnBits(1) = CLng(3)
		m_lOnBits(2) = CLng(7)
		m_lOnBits(3) = CLng(15)
		m_lOnBits(4) = CLng(31)
		m_lOnBits(5) = CLng(63)
		m_lOnBits(6) = CLng(127)
		m_lOnBits(7) = CLng(255)
		m_lOnBits(8) = CLng(511)
		m_lOnBits(9) = CLng(1023)
		m_lOnBits(10) = CLng(2047)
		m_lOnBits(11) = CLng(4095)
		m_lOnBits(12) = CLng(8191)
		m_lOnBits(13) = CLng(16383)
		m_lOnBits(14) = CLng(32767)
		m_lOnBits(15) = CLng(65535)
		m_lOnBits(16) = CLng(131071)
		m_lOnBits(17) = CLng(262143)
		m_lOnBits(18) = CLng(524287)
		m_lOnBits(19) = CLng(1048575)
		m_lOnBits(20) = CLng(2097151)
		m_lOnBits(21) = CLng(4194303)
		m_lOnBits(22) = CLng(8388607)
		m_lOnBits(23) = CLng(16777215)
		m_lOnBits(24) = CLng(33554431)
		m_lOnBits(25) = CLng(67108863)
		m_lOnBits(26) = CLng(134217727)
		m_lOnBits(27) = CLng(268435455)
		m_lOnBits(28) = CLng(536870911)
		m_lOnBits(29) = CLng(1073741823)
		m_lOnBits(30) = CLng(2147483647)
		
		m_l2Power(0) = CLng(1)
		m_l2Power(1) = CLng(2)
		m_l2Power(2) = CLng(4)
		m_l2Power(3) = CLng(8)
		m_l2Power(4) = CLng(16)
		m_l2Power(5) = CLng(32)
		m_l2Power(6) = CLng(64)
		m_l2Power(7) = CLng(128)
		m_l2Power(8) = CLng(256)
		m_l2Power(9) = CLng(512)
		m_l2Power(10) = CLng(1024)
		m_l2Power(11) = CLng(2048)
		m_l2Power(12) = CLng(4096)
		m_l2Power(13) = CLng(8192)
		m_l2Power(14) = CLng(16384)
		m_l2Power(15) = CLng(32768)
		m_l2Power(16) = CLng(65536)
		m_l2Power(17) = CLng(131072)
		m_l2Power(18) = CLng(262144)
		m_l2Power(19) = CLng(524288)
		m_l2Power(20) = CLng(1048576)
		m_l2Power(21) = CLng(2097152)
		m_l2Power(22) = CLng(4194304)
		m_l2Power(23) = CLng(8388608)
		m_l2Power(24) = CLng(16777216)
		m_l2Power(25) = CLng(33554432)
		m_l2Power(26) = CLng(67108864)
		m_l2Power(27) = CLng(134217728)
		m_l2Power(28) = CLng(268435456)
		m_l2Power(29) = CLng(536870912)
		m_l2Power(30) = CLng(1073741824)


		Dim x
		Dim k
		Dim AA
		Dim BB
		Dim CC
		Dim DD
		Dim a
		Dim b
		Dim c
		Dim d
		
		Const S11 = 7
		Const S12 = 12
		Const S13 = 17
		Const S14 = 22
		Const S21 = 5
		Const S22 = 9
		Const S23 = 14
		Const S24 = 20
		Const S31 = 4
		Const S32 = 11
		Const S33 = 16
		Const S34 = 23
		Const S41 = 6
		Const S42 = 10
		Const S43 = 15
		Const S44 = 21

		x = ConvertToWordArray(sMessage)
		
		a = &H67452301
		b = &HEFCDAB89
		c = &H98BADCFE
		d = &H10325476

		For k = 0 To UBound(x) Step 16
			AA = a
			BB = b
			CC = c
			DD = d
		
			md5_FF a, b, c, d, x(k + 0), S11, &HD76AA478
			md5_FF d, a, b, c, x(k + 1), S12, &HE8C7B756
			md5_FF c, d, a, b, x(k + 2), S13, &H242070DB
			md5_FF b, c, d, a, x(k + 3), S14, &HC1BDCEEE
			md5_FF a, b, c, d, x(k + 4), S11, &HF57C0FAF
			md5_FF d, a, b, c, x(k + 5), S12, &H4787C62A
			md5_FF c, d, a, b, x(k + 6), S13, &HA8304613
			md5_FF b, c, d, a, x(k + 7), S14, &HFD469501
			md5_FF a, b, c, d, x(k + 8), S11, &H698098D8
			md5_FF d, a, b, c, x(k + 9), S12, &H8B44F7AF
			md5_FF c, d, a, b, x(k + 10), S13, &HFFFF5BB1
			md5_FF b, c, d, a, x(k + 11), S14, &H895CD7BE
			md5_FF a, b, c, d, x(k + 12), S11, &H6B901122
			md5_FF d, a, b, c, x(k + 13), S12, &HFD987193
			md5_FF c, d, a, b, x(k + 14), S13, &HA679438E
			md5_FF b, c, d, a, x(k + 15), S14, &H49B40821
		
			md5_GG a, b, c, d, x(k + 1), S21, &HF61E2562
			md5_GG d, a, b, c, x(k + 6), S22, &HC040B340
			md5_GG c, d, a, b, x(k + 11), S23, &H265E5A51
			md5_GG b, c, d, a, x(k + 0), S24, &HE9B6C7AA
			md5_GG a, b, c, d, x(k + 5), S21, &HD62F105D
			md5_GG d, a, b, c, x(k + 10), S22, &H2441453
			md5_GG c, d, a, b, x(k + 15), S23, &HD8A1E681
			md5_GG b, c, d, a, x(k + 4), S24, &HE7D3FBC8
			md5_GG a, b, c, d, x(k + 9), S21, &H21E1CDE6
			md5_GG d, a, b, c, x(k + 14), S22, &HC33707D6
			md5_GG c, d, a, b, x(k + 3), S23, &HF4D50D87
			md5_GG b, c, d, a, x(k + 8), S24, &H455A14ED
			md5_GG a, b, c, d, x(k + 13), S21, &HA9E3E905
			md5_GG d, a, b, c, x(k + 2), S22, &HFCEFA3F8
			md5_GG c, d, a, b, x(k + 7), S23, &H676F02D9
			md5_GG b, c, d, a, x(k + 12), S24, &H8D2A4C8A
				
			md5_HH a, b, c, d, x(k + 5), S31, &HFFFA3942
			md5_HH d, a, b, c, x(k + 8), S32, &H8771F681
			md5_HH c, d, a, b, x(k + 11), S33, &H6D9D6122
			md5_HH b, c, d, a, x(k + 14), S34, &HFDE5380C
			md5_HH a, b, c, d, x(k + 1), S31, &HA4BEEA44
			md5_HH d, a, b, c, x(k + 4), S32, &H4BDECFA9
			md5_HH c, d, a, b, x(k + 7), S33, &HF6BB4B60
			md5_HH b, c, d, a, x(k + 10), S34, &HBEBFBC70
			md5_HH a, b, c, d, x(k + 13), S31, &H289B7EC6
			md5_HH d, a, b, c, x(k + 0), S32, &HEAA127FA
			md5_HH c, d, a, b, x(k + 3), S33, &HD4EF3085
			md5_HH b, c, d, a, x(k + 6), S34, &H4881D05
			md5_HH a, b, c, d, x(k + 9), S31, &HD9D4D039
			md5_HH d, a, b, c, x(k + 12), S32, &HE6DB99E5
			md5_HH c, d, a, b, x(k + 15), S33, &H1FA27CF8
			md5_HH b, c, d, a, x(k + 2), S34, &HC4AC5665
		
			md5_II a, b, c, d, x(k + 0), S41, &HF4292244
			md5_II d, a, b, c, x(k + 7), S42, &H432AFF97
			md5_II c, d, a, b, x(k + 14), S43, &HAB9423A7
			md5_II b, c, d, a, x(k + 5), S44, &HFC93A039
			md5_II a, b, c, d, x(k + 12), S41, &H655B59C3
			md5_II d, a, b, c, x(k + 3), S42, &H8F0CCC92
			md5_II c, d, a, b, x(k + 10), S43, &HFFEFF47D
			md5_II b, c, d, a, x(k + 1), S44, &H85845DD1
			md5_II a, b, c, d, x(k + 8), S41, &H6FA87E4F
			md5_II d, a, b, c, x(k + 15), S42, &HFE2CE6E0
			md5_II c, d, a, b, x(k + 6), S43, &HA3014314
			md5_II b, c, d, a, x(k + 13), S44, &H4E0811A1
			md5_II a, b, c, d, x(k + 4), S41, &HF7537E82
			md5_II d, a, b, c, x(k + 11), S42, &HBD3AF235
			md5_II c, d, a, b, x(k + 2), S43, &H2AD7D2BB
			md5_II b, c, d, a, x(k + 9), S44, &HEB86D391
		
			a = AddUnsigned(a, AA)
			b = AddUnsigned(b, BB)
			c = AddUnsigned(c, CC)
			d = AddUnsigned(d, DD)
		Next
		
		'MD5 = LCase(WordToHex(a) & WordToHex(b) & WordToHex(c) & WordToHex(d))
		MD5=LCase(WordToHex(b) & WordToHex(c))  'I crop this to fit 16byte database password :D
	End Function
'md5加密函数结束
'*******************************************************
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<title>空间文件管理助手 For Asp</title>
<style type="text/css">
body{font-family: Verdana, Arial, Helvetica, sans-serif;font-size: 12px; text-align:center; margin:0px; padding:0px;} 
a{ color:#000000; text-decoration:none;}
a:link{ color:#000000; text-decoration:none;}
a:hover{ color:#000000; background-color:#cccccc; text-decoration:underline;}

#PageBody{font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 12px; width:700px; text-align:left; border:1px solid #000000;margin:10px auto;}
#index_head{color:#FFFFFF; background-color:#000000; font-weight:bold; height:24px; line-height:24px;width:100%; margin:0px;}
.head_right{color:#FFFF00; float:right; width:50px; text-decoration:underline;}

#index_head a{ color:#FFFF00; text-decoration:none;}
#index_head a:link{ color:#FFFF00; text-decoration:underline;}
#index_head a:hover{ color:#FFFF00; background-color:#999999; text-decoration:none;}

#index_body{line-height:22px;width:100%; background-color:#CCCCCC;vertical-align:top;}
#body_left{width:120px; float:left;}
#body_right{padding:10px; background-color:#FFFFFF;border-left:1px solid #000000; width:555px;height:420px;}
#body_left ul{padding-top:10px;}
#body_left ul li{ list-style:square;}
#body_left ul li a{ color:#000000; text-decoration:underline;}
#body_left ul li a:link{ color:#000000; text-decoration:underline;}
#body_left ul li a:hover{ color:#000000; background-color:#999999; text-decoration:underline;}


#body_title{color:#000000; padding-left:20px; width:500px;}
#body_content{color:#000000; padding-left:20px; padding-top:10px; width:500px; height:80px;}
#body_content ul{ margin:0px;}
#body_content ul li{ list-style:none; height:30px;}

#body_login{color:#000000; font-weight:bold; padding-top:80px; text-align:center;}
#body_login ul li{ list-style:none; height:30px;}
.login_input{width:140px; border:1px solid #666666;}
.input_button{border:1px solid #666666; background-color:#FFFFFF;}

#body_rename{color:#000000; font-weight:bold; padding-top:40px; text-align:left;}
#body_rename ul li{ list-style:none; height:30px;}
.input{border:1px solid #666666;}
.button{border:1px solid #666666; background-color:#FFFFFF;}

#errorstr{list-style:armenian; width:400px; margin-top:20px;padding-left:10px;}
#errorstr ul li{list-style:decimal;}

#filelist_t1{width:555px; font-weight:bold; text-align:center;}
#filelist_t1 ul{width:555px; margin:0px;}
#filelist_t1 ul li{list-style:none; float:left;}

.filelist_t2 ul{width:555px; margin:0px;}
.filelist_t2{width:555px;text-align:left;}
.filelist_t2 ul li{list-style:none; float:left; margin:0px; padding:0px;}

.filelist_t3 ul{width:555px; margin:0px;}
.filelist_t3{width:555px;background-color:#F2F2F2;}
.filelist_t3 ul li{list-style:none; float:left; margin:0px;}

.filelist_width1{width:190px;}
.filelist_width2{width:55px; text-align:center;}
.filelist_width3{width:90px;text-align:right;}
.filelist_width4{width:155px;text-align:center;}
.filelist_width5{ width:65px;text-align:center;}
#index_bottom{color:#FFFFFF; background-color:#000000; font-weight:bold; height:24px; line-height:24px; width:100%;text-align:center;}
#index_bottom a{ color:#FFFFFF; text-decoration:none;}
#index_bottom a:link{ color:#FFFFFF; text-decoration:none;}
#index_bottom a:hover{ color:#FFFFFF; background-color:#333333; text-decoration:none;}
</style>
</head>
<body>
<%	sPath=""
	sFileType = Request.Querystring("filetype")

	If Request.Querystring("path") <> "" Then	'由URL传递过来的路径
		sPath = Request.Querystring("path")
		If InStr(sPath,"../") or InStr(sPath,"..\") Then
	 		errornum = errornum+1
	 		errorcode = errorcode & "<li><b>错误参数 ""../""</b>. 你只能管理主目录下的文件和文件夹.</li>"
 		End If
	End If
	
	FullsPath=MainPath & sPath
	
	If FullsPath=MainPath Then
			sFile = FullsPath & Request.Querystring("file")
			sFolder = FullsPath & Request.Querystring("folder")
	Else
			sFile = FullsPath & "/" & Request.Querystring("file")
			sFolder = FullsPath & "/" & Request.Querystring("folder")
	End If
	session("foldername")=sPath
%>
<div id="PageBody">
<div id="index_head"><div class="head_right"><A href="<%=scriptname%>?path=<%=GotoUpFolder(sPath)%>">上一层</A></div> &nbsp; 当前目录：<%=ShowCurrentFolder(sPath)%></div>
<div id="index_body">
	<div id="body_left">
		<ul>
			<li><A href="<%=scriptname%>?">返回首页</A></li>
			<li><A href="<%=scriptname%>?action=newfile&path=<%=request.querystring("path")%>">新建文件</A></li>
			<li><A href="<%=scriptname%>?action=CreateNewFolder&path=<%=request.querystring("path")%>">新文件夹</A></li>
			<li><A href="<%=scriptname%>?action=UploadFiles&path=<%=request.querystring("path")%>">上传文件</A></li>
			<li><A href="<%=scriptname%>?action=LoginConfig&path=<%=request.querystring("path")%>">登陆设置</A></li>
			<li><A href="<%=scriptname%>?action=LoginOut">退出登陆</A></li>
		</ul>
	</div>
	<div id="body_right">
		<%
'*******************************************************
'按条件执行某过程
	If errornum < 1 Then
		Set fs = Server.CreateObject("Scripting.FileSystemObject")
		if Session("FileUserSession")=FileLoginName then
		
			Select Case sAction
			Case "editfile"
				Select Case sFileType
				Case "htm", "asp", "txt", "inc", "html", "shtml", "shtm", "js", "css", "asa", "aspx"
					EditFile
'				Case "mdb", "dat"
'					EditDb
				Case else
					FileTypeUnsupported
				End Select
			Case "savefile"
				SaveFile
			Case "viewfolder"
				Showlist
			Case "newfile"
				CreateFile
			Case "newfolder"
				CreateFolder
			Case "deletefile"
				DeleteFile
			Case "deletefolder"
				DeleteFolder
			Case "CreateNewFolder"
				CreateNewFolder
			Case "UploadFiles"
				UploadFiles
			Case "SaveUpFiles"
				SaveUpFiles
			Case "RenameFolder"
				RenameFolder
			Case "RenameFile"
				RenameFile
			Case "downloadfile"
				HitDownFile
			Case "LoginConfig"
				LoginConfig
			Case "LoginOut"
				LoginOut
			Case Else
				Showlist 
			End Select
		elseif sAction="LoginCheck" then
		LoginCheck
		else
			call UserLogin
		end if
		  
		Set fs = Nothing
	End If
	if errornum>0 then DisplayErrors	
'*******************************************************
'按条件执行某过程结束	
		%>
	</div>
</div>
<div id="index_bottom"><A href="http://www.vwen.com" target=""_blank"">微网网络</a> 版权所有</div>
</div>
</body>
</html>
<%
'*******************************************************
'显示当前目录
function ShowCurrentFolder(Path)
	dim FullPath
	FullPath = MainPath & Path
	if FullPath = MainPath then
		ShowCurrentFolder="主目录/"
	else
		ShowCurrentFolder="主目录/"&Path&"/"
	end if
end function

'*******************************************************
'显示上一层目录
function GotoUpFolder(Path)
	dim TempPath,FullPath
	FullPath = MainPath & Path
	if FullPath = MainPath then
		GotoUpFolder=""
	else
		if instr(Path,"/")>0 then
			TempPath=left(Path,instrrev(Path,"/"))
			if TempPath="./" or TempPath="/" then GotoUpFolder=TempPath else GotoUpFolder=left(Path,instrrev(Path,"/")-1)
		else
			GotoUpFolder=""
		end if
	end if
end function

'*******************************************************
'退出登陆
Sub LoginOut
	Session("FileUserSession")=""
	response.Redirect(scriptname&"?")
End Sub 

'*******************************************************
'输出错误
Sub DisplayErrors
	Response.Write("<div id=""body_title""><strong>错误: 发生" & errornum & " 项错误，如下：</strong></div>")
	Response.Write "<div id=""errorstr""><ul>" & errorcode & "</ul></div>" & vbCrlf
	Response.Write "<div> &nbsp;  &nbsp;  &nbsp; <A href=""javascript:window.history.go(-1);"">返回上一页</a> &nbsp; <A href="""& scriptname &"?"">返回首页</a></div>" & vbCrlf
End Sub

'*******************************************************
'管理登陆
sub UserLogin
	response.Write("<div id=""body_title""><strong>管理登陆</strong></div>")
	response.Write("<div id=""body_login"">")
	response.Write("<form name=""loginform"" action="""& scriptname &"?action=LoginCheck"" method=""post"">")
	response.Write("<ul><li>登陆名：<input class=""login_input"" type=""text"" name=""loginname""></li><li>密　码：<input class=""login_input"" type=""password"" name=""loginpwd""></li><li><input type=""submit"" value=""登 陆"" class=""input_button""> &nbsp; <input type=""reset"" value=""重 置"" class=""input_button""></li></ul></form>")
	response.write("</div>")
end sub

'*******************************************************
'登陆验证
sub LoginCheck()
	if session("FileLoginErrStr")="" then session("FileLoginErrStr")=0
	loginname=request.Form("loginname")
	loginpwd=request.Form("loginpwd")

	if loginname="" or loginpwd="" then	
		errornum = errornum+1
		errorcode = errorcode & "<li>登陆名或密码没有输入。</li>"
		exit sub
	end if
	if session("FileLoginErrStr")>3 then
		errornum = errornum+1
		errorcode = errorcode & "<li>登陆名或密码不正确。</li>"
		exit sub
	end if
	if (md5(loginname)&"1")<>FileLoginName or (md5(loginpwd)&"2")<>FileLoginPwd then
		session("FileLoginErrStr")=session("FileLoginErrStr")+1
		errornum = errornum+1
		errorcode = errorcode & "<li>登陆名或密码不正确。</li>"
		exit sub
	end if
	Session("FileUserSession")=FileLoginName
	response.Redirect(scriptname&"?")
end sub

Sub LoginConfig
	If Request.Querystring("commit") <> "yes" Then
		response.Write("<div id=""body_title""><strong>登陆设置</strong></div>")
		response.Write("<div id=""body_login"">")
		response.Write("<form name=""loginform"" action="""& scriptname &"?action=LoginConfig&path="& spath &"&commit=yes"" method=""post""><ul>")
		If Request.Querystring("commits")="yes" Then
			response.Write("<li><font color=""red"">修改保存成功</font></li>")
		End if
		response.Write("<li>登陆名：<input class=""login_input"" type=""text"" name=""loginname""></li><li>密　码：<input class=""login_input"" type=""password"" name=""loginpwd""></li><li><input type=""submit"" value=""保 存"" class=""input_button""> &nbsp; <input type=""reset"" value=""重 置"" class=""input_button""></li></ul></form>")
		response.write("</div>")
	Else
		loginname=request.Form("loginname")
		loginpwd=request.Form("loginpwd")
		if loginname="" or loginpwd="" then	
			errornum = errornum+1
			errorcode = errorcode & "<li>登陆名或密码没有输入。</li>"
			exit sub
		end If
		loginname=md5(loginname)
		loginpwd=md5(loginpwd)
		Session("FileUserSession")=loginname&"1"
		Set ReadStream = fs.OpenTextFile(server.mappath(scriptname))
		Dim ReadTxt
		ReadTxt=ReadStream.ReadAll
		ReadStream.Close
		ReadTxt=Replace(ReadTxt,FileLoginName,loginname&"1")
		ReadTxt=Replace(ReadTxt,FileLoginPwd,loginpwd&"2")
		Set WriteFile = fs.CreateTextFile(server.mappath(scriptname), true)
		WriteFile.Write ReadTxt
		WriteFile.Close
		response.redirect(scriptname&"?action=LoginConfig&path="&spath&"&commits=yes")
	End if
End Sub

'*******************************************************
'文件列表
Sub ShowList
	Response.Write("<div>")
	Response.Write("<div id=""filelist_t1""><ul><li class=""filelist_width1"">名称</li><li class=""filelist_width2"">类型</li><li class=""filelist_width3"">大小</li><li class=""filelist_width4"">修改时间</li><li  class=""filelist_width5"">操作</li></ul></div>")
	Set fileobject = fs.GetFolder(server.mappath(FullsPath))
	Set foldercollection = fileobject.SubFolders 
	lineid=0
	bgcolor = ""
	bgcolor_off = ""
	bgcolor_on = "#f0f0f0"
	'文件夹循环开始
	For Each folder in foldercollection
		If lineid = 0 Then
			bgcolor = "filelist_t2"
			lineid = 1
		Else
			bgcolor = "filelist_t3"
			lineid = 0
		End if
		Response.Write("<div class="""& bgcolor &"""><ul>")
		Response.Write("<li class=""filelist_width1"">")
		if sPath="" then
			response.Write("<a href=""" & scriptname & "?action=viewfolder&path=" & sPath & folder.name & """>" & folder.name & "</a>")
		else		
			response.Write("<a href=""" & scriptname & "?action=viewfolder&path=" & sPath & "/" & folder.name & """><font color=""#944007"">" & folder.name & "</font></a>")
		end if
		Response.Write("</li>")
		Response.Write("<li class=""filelist_width2""><font color=""#944007"">文件夹</font></li>")
		Response.Write("<li class=""filelist_width3"">"& Size(folder.size) &"</li>")
		Response.Write("<li class=""filelist_width4"">"& folder.datelastmodified &"</li>")
		Response.Write("<li class=""filelist_width5""><a href=""" & scriptname & "?action=RenameFolder&path=" & sPath & "&folder=" & folder.name & """>修</a> <a href=""" & scriptname & "?action=deletefolder&path=" & sPath & "&folder=" & folder.name & """>删</a></li>")
		response.Write("</ul></div>")
	Next
	Set foldercollection=nothing
	'文件夹循环结束

	Set filecollection = fileobject.Files
  
	For Each file in filecollection 
		If lineid = 0 Then
		  bgcolor = "filelist_t2"
		  lineid = 1
		Else
		  bgcolor = "filelist_t3"
		  lineid = 0
		End if	

		'if fs.GetExtensionName(file.name)="gif" then image="gif.gif"
		Response.Write("<div class="""& bgcolor &"""><ul>")
		Response.Write("<li class=""filelist_width1""><a href=""" & scriptname & "?action=editfile&path=" & sPath & "&file=" & server.URLEncode(file.name) & "&filetype=" & Lcase(fs.GetExtensionName(file.name)) & """>" & file.name & "</a></li>")
		Response.Write("<li class=""filelist_width2"">"& fs.GetExtensionName(file.name) &"</li>")
		Response.Write("<li class=""filelist_width3"">"& Size(file.size) &"</li>")
		Response.Write("<li class=""filelist_width4"">"& file.datelastmodified &"</li>")
		Response.Write("<li class=""filelist_width5""><a href=""" & scriptname & "?action=RenameFile&path=" & sPath & "&file=" & file.name & "&filetype=" & Lcase(fs.GetExtensionName(file.name)) & """>修</a> <a href=""" & scriptname & "?action=deletefile&path=" & sPath & "&file=" & file.name & "&filetype=" & Lcase(fs.GetExtensionName(file.name)) & """>删</a></li>")
		response.Write("</ul></div>")
  Next
  Response.Write("</div>")
End Sub

'*******************************************************
'格式化数字-文件大小
function Size(itemsize)
  Select case Len(itemsize)
  Case "1", "2", "3" 
    Size=itemsize & " Byte"
  Case "4", "5", "6"
    Size = Round(itemsize/1000) & " Kb"
  Case "7", "8", "9"
    Size = Round(itemsize/1000000) & " Mb"
  End Select
  Response.Write "</td>" &vbCrLf
End function

'*******************************************************
'重命名文件夹
Sub RenameFolder
	response.Write("<div id=""body_title""><strong>文件夹重命名</strong></div>")
	If Request.querystring("commit") <> "yes" Then 
		Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
		Response.Write "<div id=""body_title"">将重命名的文件夹: <strong>" & request.querystring("folder") & "</strong></div>" 
	
		response.Write("<div id=""body_rename"">")
		response.Write("<form name=""form1"" action="""& scriptname &"?action=RenameFolder&path="& spath &"&folder="& request.querystring("folder") &"&commit=yes"" method=""post"">")
		response.Write("<ul><li>新名称：<input class=""input"" type=""text"" name=""NewFolderName"" size=""20""></li><li><input type=""submit"" value=""保存命名"" class=""button""> &nbsp; <input type=""reset"" value=""重新填写"" class=""input_button""><input type=""hidden"" value="""& request.querystring("folder") &""" name=""folder""></li></ul></form>")
		response.write("</div>")
	Else
		Dim NewFolderName,slashvalue,folderObject
		NewFolderName=request.form("NewFolderName")
		sFolder=request.form("folder")
		if right(FullsPath,1)="/" then slashvalue="" else slashvalue="/"
		Set folderObject = fs.GetFolder(Server.MapPath(FullsPath&slashvalue&sFolder))
		FolderObject.Name=NewFolderName
		Set folderObject = Nothing
		Response.Redirect("" & Session("lastpage") & "") 
	End If
End Sub

'*******************************************************
'重命名文件
Sub RenameFile
	response.Write("<div id=""body_title""><strong>文件重命名</strong></div>")
	If Request("commit") <> "yes" Then 
		Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
		Response.Write "<div id=""body_title"">将重命名的文件: <strong>" & request.querystring("file") & "</strong></div>"
		
		response.Write("<div id=""body_rename"">")
		response.Write("<form name=""form1"" action="""& scriptname &"?action=RenameFile&path="& spath &"&folder="& request.querystring("folder") &"&commit=yes"" method=""post"">")
		response.Write("<ul><li>新名称：<input class=""input"" type=""text"" name=""NewFileName"" size=""20""></li><li><input type=""submit"" value=""保存命名"" class=""button""> &nbsp; <input type=""reset"" value=""重新填写"" class=""input_button""><input type=""hidden"" value="""& request.querystring("file") &""" name=""filename""></li></ul></form>")
		response.write("</div>")
	Else
		Dim NewFileName,Sfile,slashvalue,FileObject
		NewFileName=request.form("NewFileName")
		Sfile=request.form("filename")
		if right(FullsPath,1)="/" then slashvalue="" else slashvalue="/"
		Set FileObject = fs.GetFile(Server.MapPath(FullsPath&slashvalue&sfile))
		FileObject.Name = NewFileName
		Set FileObject = Nothing
		Response.Redirect("" & Session("lastpage") & "")  
	End If
End Sub

'*******************************************************
'显示文件
Sub FileTypeUnsupported
	Dim path
	Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
	filename=request.querystring("file")
	response.Write("<div id=""body_title""><strong>显示文件</strong></div>")
	If sFileType = "jpg" OR sFileType = "gif" OR sFileType = "GIF" OR sFileType = "JPG" Then
		Response.Write "<div id=""body_content""><img src="""&  path & sfile & """ border=""1""></div>"
	else
		Response.Write "<div id=""body_content"">此文件不能在浏览器显示. <br /><A href="""& scriptname &"?action=downloadfile&path="& spath &"&file=" & server.URLEncode(Request.Querystring("File")) &""" target=""_blank""><font color=""#0066CC"">下载此文件</font></a></div>"
	End If
	Response.Write "<div id=""body_title""><a href=" & Session("lastpage") & ">返回</a></div>"
End Sub

'*******************************************************
'创建文件夹
Sub CreateNewFolder
	response.Write("<div id=""body_title""><strong>创建文件夹</strong></div>")
	response.Write("<div id=""body_title"">当前文件夹：<strong>"& spath &"</strong></div>")

	response.Write("<div id=""body_content"">")
	response.Write("<form name=""form1"" action="""& scriptname &"?action=newfolder&path="& spath &""" method=""post"">")
	response.Write("<ul><li><input class=""input"" type=""text"" value=""文件夹名"" name=""folder"" size=""25""></li><li><input type=""submit"" value=""创建文件夹"" class=""button""> &nbsp; <input type=""button"" value=""重新填写"" class=""input_button"" onclick=""javascript:folder.value='';""><input type=""hidden"" value="""& request.querystring("file") &""" name=""filename""></li></ul></form>")
	response.write("</div>")
End Sub

'*******************************************************
'保存创建文件夹
Sub CreateFolder
	If FullsPath="/" or FullsPath="./" Then
			sFile = FullsPath & Request.Form("file")
			sFolder = FullsPath & Request.Form("folder")
	Else
			sFile = FullsPath & "/" & Request.Form("file")
			sFolder = FullsPath & "/" & Request.Form("folder")
	End If
	session("foldername")=sPath
	Session("lastpage") = request.querystring("path")
	If fs.FolderExists(server.mappath(sFolder)) Then 
		response.write "文件夹<b>" & sFolder & "</b>存在，创建失败。<br>"  
	Else
		fs.CreateFolder(server.mappath(sFolder))
		response.redirect(scriptname&"?action=viewfolder&path="&session("lastpage")&"")
	End If
End Sub

'*******************************************************
'建立文件
Sub CreateFile
	response.Write("<div id=""body_title""><strong>新建文件</strong></div>")
	Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
  
	response.Write("<div id=""body_content"">")
	response.Write("<form name=""form1"" action="""& scriptname &"?action=savefile&path="& spath &""" method=""post"">")
		response.Write("<ul><li>文 件 名：<br /><input class=""input"" type=""text"" value="""" name=""file"" size=""30"">(含扩展名)</li>")
	response.Write("<li>文件内容：<br /><textarea rows=""20"" cols=""70"" name=""newfilestuff"" class=""input""></textarea><br /><br /></li>")
	response.Write("<li><input type=""submit"" value=""创建文件"" class=""button""> &nbsp; <input type=""reset"" value=""重新填写"" class=""input_button""><input type=""hidden"" value="""& request.querystring("file") &""" name=""filename""></li></ul></form>")
	response.write("</div>")
End Sub

'*******************************************************
'编辑文件
Sub EditFile
	Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
	Set ReadStream = fs.OpenTextFile(server.mappath(sFile))
	filename=request.querystring("file")
	response.Write("<div id=""body_title""><strong>编辑文件</strong></div>")
	response.Write("<div id=""body_title"">当前文件：<strong>"& filename &"</strong></div>")

	response.Write("<div id=""body_content"">")
	response.Write("<form name=""form1"" action="""& scriptname &"?action=savefile&path="& spath &"&file=" & Request.Querystring("File") & "&overwrite=yes"" method=""post"">")
	response.Write("<ul><li>文件的内容：<br /><textarea rows=""20"" cols=""70"" name=""filestuff"" class=""input"">" & Server.HTMLEncode(ReadStream.ReadAll) & "</textarea></li>")
	response.Write("<li>文件另存为：<br /><input class=""input"" type=""text"" value="""" name=""NewFileName"" size=""25""><br /><br /></li><li><input type=""submit"" value=""保存编辑"" class=""button""> &nbsp; <input type=""reset"" value=""重新填写"" class=""input_button""><input type=""hidden"" value="""& request.querystring("file") &""" name=""filename""></li></ul></form>")
	response.write("</div>")
End Sub

'*******************************************************
'保存编辑文件和新建的文件
Sub SaveFile
	If right(FullsPath,1)="/" Then
		If Request.Querystring("file") = "" Then
			sFile = FullsPath & Request.Form("file")
		End If
		If Request.Querystring("folder") = "" Then
			sFolder = FullsPath & Request.Form("folder")
		End if
	Else
		If Request.Querystring("file") = "" Then
			sFile = FullsPath & "/" & Request.Form("file")
		End If
		If Request.Querystring("folder") = "" Then
			sFolder = FullsPath & "/" & Request.Form("folder")
		End if
	End If
	session("foldername")=sPath
	'保存为新的文件
	if request.form("NewFileName")<>"" Then
		Dim NewFileName,slashvalue,textStreamObject,filestuff,NewPathFileName
		NewFileName=request.form("NewFileName")
		spath=request("path")
		if right(FullsPath,1)="/" then slashvalue="" else slashvalue="/"
		filestuff=request.form("filestuff")
		NewPathFileName= FullsPath&slashvalue&newfilename
		Set textStreamObject = fs.CreateTextFile(server.mappath(NewPathFileName),true,false)
		textStreamObject.write filestuff
		textStreamObject.close
		Response.Redirect("" & Session("lastpage") & "")
	else
		
		If Request.Querystring("overwrite") = "yes" Then
			Set WriteFile = fs.CreateTextFile(server.mappath(sFile), true)
			WriteFile.Write Request.Form("filestuff")
			WriteFile.Close
			Response.Redirect("" & Session("lastpage") & "")
			
		Else
			Session("lastpage") = Request.ServerVariables("HTTP_Referer")
			If fs.FileExists(server.mappath(sFile)) Then
				Session("sFile") = sFile
				spath=request.querystring("path")
				response.Write("<div id=""body_title""><strong>保存文件</strong></div>")
				response.Write("<div id=""body_title"">存在文件：<strong>"& sFile &"</strong></div>")
				response.Write("<div id=""body_content"">")
				response.Write("<form name=""reform1"" action="""& scriptname &"?action=savefile&overwrite=yes&path="& spath &"&file=" & Request.Form("File") & """ method=""post""><ul>")
				Response.Write "<LI><strong>替换现有的文件吗?</strong></a>"
				Response.Write "<LI><a href=""javascript:reform1.submit();"">覆盖此文件</a> &nbsp; <a href=""javascript:history.back()"">返回上一步</a><input type=""hidden"" value="""& Request.Form("newfilestuff") &""" name=""filestuff""></LI>"
				Response.Write "</ul></form></div>"
				Session("lastpage") = scriptname&"?action=viewfolder&path="&spath&""
			Else 
				Set WriteFile = fs.CreateTextFile(server.mappath(sFile), false)
				WriteFile.Write Request.Form("newfilestuff")
				WriteFile.Close
				Response.Redirect(scriptname&"?action=viewfolder&path="&spath&"")
			End If
		End If
	end if
End Sub

'*******************************************************
'删除文件夹
Sub DeleteFolder
	response.Write("<div id=""body_title""><strong>删除文件夹</strong></div>")
	If Request.Querystring("commit") <> "yes" Then 
		Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
		Session("sFolder") = sFolder
		response.Write("<div id=""body_title"">将要删除文件夹：<strong>"& sFolder &"</strong></div>")

		response.Write("<div id=""body_content"">")
		response.Write("<ul>")
		Response.Write "<LI><strong>删除此文件夹吗?</strong></a>"
		Response.Write "<LI><a href=""" & scriptname & "?action=deletefolder&path=" & sPath & "&folder=" & sFolder &  "&commit=yes"">删除文件夹</a> &nbsp; <a href=" & Session("lastpage") & ">返回上一步</a></LI>"
		Response.Write "</ul></div>"

	Else
		Response.Write sPath & "<br>"
		Response.Write sFile & "<br>"
		fs.DeleteFolder(server.mappath(Session("sFolder")))
		Response.Redirect("" & Session("lastpage") & "")
	End If
End Sub

'*******************************************************
'删除文件
Sub DeleteFile
	response.Write("<div id=""body_title""><strong>删除文件</strong></div>")
	If Request.Querystring("commit") <> "yes" Then
		Session("lastpage") = Request.ServerVariables("HTTP_REFERER")
		Session("sFile") = sFile
		response.Write("<div id=""body_title"">将要删除文件：<strong>"& sFile &"</strong></div>")

		response.Write("<div id=""body_content"">")
		response.Write("<ul>")
		If sFileType = "jpg" OR sFileType = "gif" Then
			Response.Write "<LI><img src="""& sfile & """ border=""1""></LI>"
		End If
		Response.Write "<LI><strong>删除此文件吗? 注意：删除后将不可恢复！</strong></a>"
		Response.Write "<LI><a href=""" & scriptname & "?action=deletefile&path=" & sPath & "&file=" & sFile & "&commit=yes"">删除此文件</a> &nbsp; <a href=" & Session("lastpage") & ">返回上一步</a></LI>"
		Response.Write "</ul></div>"
	Else
		fs.DeleteFile(server.mappath(Session("sFile")))
		Response.Redirect("" & Session("lastpage") & "")
	End If
End Sub

'*******************************************************
'上传文件
Sub UploadFiles
	response.Write("<div id=""body_title""><strong>上传文件</strong></div>")
	response.Write("<div id=""body_title"">当前文件夹：<strong>"& ShowCurrentFolder(sPath) &"</strong></div>")
	
	response.Write("<div id=""body_content"">")
	response.Write("<form name=""form1"" action="""& scriptname &"?action=SaveUpFiles&path="& sPath &""" method=""post"" enctype=""multipart/form-data"">")
	response.Write("<ul>")
	response.Write("<li>文件01：<input class=""input"" type=""FILE"" value="""" name=""FILE1"" size=""30""></li>")
	response.Write("<li>文件02：<input class=""input"" type=""FILE"" value="""" name=""FILE2"" size=""30""></li>")
	response.Write("<li>文件03：<input class=""input"" type=""FILE"" value="""" name=""FILE3"" size=""30""></li>")
	response.Write("<li>文件04：<input class=""input"" type=""FILE"" value="""" name=""FILE4"" size=""30""></li>")
	response.Write("<li>文件05：<input class=""input"" type=""FILE"" value="""" name=""FILE5"" size=""30""></li>")
	response.Write("<li>文件06：<input class=""input"" type=""FILE"" value="""" name=""FILE6"" size=""30""></li>")
	response.Write("<li>文件07：<input class=""input"" type=""FILE"" value="""" name=""FILE7"" size=""30""></li>")
	response.Write("<li>文件08：<input class=""input"" type=""FILE"" value="""" name=""FILE8"" size=""30""></li>")
	response.Write("<li>文件09：<input class=""input"" type=""FILE"" value="""" name=""FILE9"" size=""30""></li>")
	response.Write("<li>文件10：<input class=""input"" type=""FILE"" value="""" name=""FILE10"" size=""30""></li>")
	response.Write("<li><input type=""submit"" value=""保存上传到此文件夹"" class=""button""><br /><br /></li></ul></form>")
	response.write("</div>")
End Sub

'*******************************************************
'上传处理
Sub SaveUpFiles
	Dim foldername,upfile_empty,intTemp,formName,UpSavePath
	foldername=session("foldername")
	if foldername="/" or foldername="./" then UpSavePath="./" Else UpSavePath=foldername&"/"
	Dim Uploader, File
	upfile_empty=true
	Set Uploader = New UpLoadClass
	Uploader.FileType="*.*"
	Uploader.MaxSize=104857600	'100M
	Uploader.SavePath=UpSavePath
	Uploader.AutoSave = 2
	Uploader.open() 

'response.write(Ubound(Uploader.FileItem))
'response.End
	for intTemp=1 to Ubound(Uploader.FileItem)
		formName=Uploader.FileItem(intTemp)
		Call Uploader.Save(formName,1)
		If Uploader.form(formName&"_Err")<>-1 Then upfile_empty=false
	next

	If upfile_empty Then
		errornum = errornum+1
		errorcode = errorcode & "<li>还没有选择任何上传的文件</li>"
		Exit Sub
	End If
	Response.redirect(scriptname&"?Action=viewfolder&path="& foldername &"")
End Sub 

sub HitDownFile()
	Response.Buffer = true
	Response.Clear()
	dim downfilepath,downfilename,slashvalue
	if right(FullsPath,1)="/" then slashvalue="" else slashvalue="/"
	downfilepath=FullsPath & slashvalue & trim(request.QueryString("file"))
	downfilename=trim(request.QueryString("file"))
	'response.Write(downfilepath)
	set fs = Server.CreateObject("Scripting.FileSystemObject")
	dim nFileLength,ass
	nFileLength = fs.GetFile(Server.MapPath(downfilepath)).Size
	set ass = Server.CreateObject("ADODB.Stream")
	ass.Open()
	ass.Type=1
	ass.LoadFromFile(Server.MapPath(downfilepath))
	Response.AddHeader "Content-Disposition", "attachment; filename=" + downfilename
	Response.AddHeader "Content-Length", nFileLength
	Response.CharSet = "gb2312"
	Response.ContentType = "application/octet-stream"
	Response.BinaryWrite(ass.Read())
	Response.Flush()
	ass.Close()
end sub
%>



<%
'*******************************************************
'上传组件
Class UpLoadClass

	Private p_MaxSize,p_FileType,p_SavePath,p_AutoSave,p_Error
	Private objForm,binForm,binItem,strDate,lngTime
	Public	FormItem,FileItem

	Public Property Get Version
		Version="Rumor UpLoadClass Version 2.0"
	End Property

	Public Property Get Error
		Error=p_Error
	End Property

	Public Property Get MaxSize
		MaxSize=p_MaxSize
	End Property
	Public Property Let MaxSize(lngSize)
		if isNumeric(lngSize) then
			p_MaxSize=clng(lngSize)
		end if
	End Property

	Public Property Get FileType
		FileType=p_FileType
	End Property
	Public Property Let FileType(strType)
		p_FileType=strType
	End Property

	Public Property Get SavePath
		SavePath=p_SavePath
	End Property
	Public Property Let SavePath(strPath)
		p_SavePath=replace(strPath,chr(0),"")
	End Property

	Public Property Get AutoSave
		AutoSave=p_AutoSave
	End Property
	Public Property Let AutoSave(byVal Flag)
		select case Flag
			case 0:
			case 1:
			case 2:
			case false:Flag=2
			case else:Flag=0
		end select
		p_AutoSave=Flag
	End Property

	Private Sub Class_Initialize
		p_Error	   = -1
		p_MaxSize  = 153600
		p_FileType = "jpg/gif"
		p_SavePath = ""
		p_AutoSave = 0
		strDate	   = replace(cstr(Date()),"-","")
		lngTime	   = clng(timer()*1000)
		Set binForm = Server.CreateObject("ADODB.Stream")
		Set binItem = Server.CreateObject("ADODB.Stream")
		Set objForm = Server.CreateObject("Scripting.Dictionary")
		objForm.CompareMode = 1
	End Sub

	Private Sub Class_Terminate
		objForm.RemoveAll
		Set objForm = nothing
		Set binItem = nothing
		binForm.Close()
		Set binForm = nothing
	End Sub

	Public Sub Open()
		if p_Error=-1 then
			p_Error=0
		else
			Exit Sub
		end if
		Dim lngRequestSize,binRequestData,strFormItem,strFileItem
		Const strSplit="'"">"
		lngRequestSize=Request.TotalBytes
		if lngRequestSize<1 then
			p_Error=4
			Exit Sub
		end if
		binRequestData=Request.BinaryRead(lngRequestSize)
		binForm.Type = 1
		binForm.Open
		binForm.Write binRequestData

		Dim bCrLf,strSeparator,intSeparator
		bCrLf=ChrB(13)&ChrB(10)

		intSeparator=InstrB(1,binRequestData,bCrLf)-1
		strSeparator=LeftB(binRequestData,intSeparator)

		Dim p_start,p_end,strItem,strInam,intTemp,strTemp
		Dim strFtyp,strFnam,strFext,lngFsiz
		p_start=intSeparator+2
		Do
			p_end  =InStrB(p_start,binRequestData,bCrLf&bCrLf)+3
			binItem.Type=1
			binItem.Open
			binForm.Position=p_start
			binForm.CopyTo binItem,p_end-p_start
			binItem.Position=0
			binItem.Type=2
			binItem.Charset="gb2312"
			strItem=binItem.ReadText
			binItem.Close()

			p_start=p_end
			p_end  =InStrB(p_start,binRequestData,strSeparator)-1
			binItem.Type=1
			binItem.Open
			binForm.Position=p_start
			lngFsiz=p_end-p_start-2
			binForm.CopyTo binItem,lngFsiz

			intTemp=Instr(39,strItem,"""")
			strInam=Mid(strItem,39,intTemp-39)

			if Instr(intTemp,strItem,"filename=""")<>0 then
			if not objForm.Exists(strInam&"_From") then
				strFileItem=strFileItem&strSplit&strInam
				if binItem.Size<>0 then
					intTemp=intTemp+13
					strFtyp=Mid(strItem,Instr(intTemp,strItem,"Content-Type: ")+14)
					strTemp=Mid(strItem,intTemp,Instr(intTemp,strItem,"""")-intTemp)
					intTemp=InstrRev(strTemp,"\")
					strFnam=Mid(strTemp,intTemp+1)
					objForm.Add strInam&"_Type",strFtyp
					objForm.Add strInam&"_Name",strFnam
					objForm.Add strInam&"_Path",Left(strTemp,intTemp)
					objForm.Add strInam&"_Size",lngFsiz
					if Instr(intTemp,strTemp,".")<>0 then
						strFext=Mid(strTemp,InstrRev(strTemp,".")+1)
					else
						strFext=""
					end if
					if left(strFtyp,6)="image/" then
						binItem.Position=0
						binItem.Type=1
						strTemp=binItem.read(10)
						if strcomp(strTemp,chrb(255) & chrb(216) & chrb(255) & chrb(224) & chrb(0) & chrb(16) & chrb(74) & chrb(70) & chrb(73) & chrb(70),0)=0 then
							if Lcase(strFext)<>"jpg" then strFext="jpg"
							binItem.Position=3
							do while not binItem.EOS
								do
									intTemp = ascb(binItem.Read(1))
								loop while intTemp = 255 and not binItem.EOS
								if intTemp < 192 or intTemp > 195 then
									binItem.read(Bin2Val(binItem.Read(2))-2)
								else
									Exit do
								end if
								do
									intTemp = ascb(binItem.Read(1))
								loop while intTemp < 255 and not binItem.EOS
							loop
							binItem.Read(3)
							objForm.Add strInam&"_Height",Bin2Val(binItem.Read(2))
							objForm.Add strInam&"_Width",Bin2Val(binItem.Read(2))
						elseif strcomp(leftB(strTemp,8),chrb(137) & chrb(80) & chrb(78) & chrb(71) & chrb(13) & chrb(10) & chrb(26) & chrb(10),0)=0 then
							if Lcase(strFext)<>"png" then strFext="png"
							binItem.Position=18
							objForm.Add strInam&"_Width",Bin2Val(binItem.Read(2))
							binItem.Read(2)
							objForm.Add strInam&"_Height",Bin2Val(binItem.Read(2))
						elseif strcomp(leftB(strTemp,6),chrb(71) & chrb(73) & chrb(70) & chrb(56) & chrb(57) & chrb(97),0)=0 or strcomp(leftB(strTemp,6),chrb(71) & chrb(73) & chrb(70) & chrb(56) & chrb(55) & chrb(97),0)=0 then
							if Lcase(strFext)<>"gif" then strFext="gif"
							binItem.Position=6
							objForm.Add strInam&"_Width",BinVal2(binItem.Read(2))
							objForm.Add strInam&"_Height",BinVal2(binItem.Read(2))
						elseif strcomp(leftB(strTemp,2),chrb(66) & chrb(77),0)=0 then
							if Lcase(strFext)<>"bmp" then strFext="bmp"
							binItem.Position=18
							objForm.Add strInam&"_Width",BinVal2(binItem.Read(4))
							objForm.Add strInam&"_Height",BinVal2(binItem.Read(4))
						end if
					end if
					objForm.Add strInam&"_Ext",strFext
					objForm.Add strInam&"_From",p_start
					intTemp=GetFerr(lngFsiz,strFext)
					if p_AutoSave<>2 then
						objForm.Add strInam&"_Err",intTemp
						if intTemp=0 then
							if p_AutoSave=0 then
								strFnam=GetTimeStr()
								if strFext<>"" then strFnam=strFnam&"."&strFext
							end if
							binItem.SaveToFile Server.MapPath(p_SavePath&strFnam),2
							objForm.Add strInam,strFnam
						end if
					end if
				else
					objForm.Add strInam&"_Err",-1
				end if
			end if
			else
				binItem.Position=0
				binItem.Type=2
				binItem.Charset="gb2312"
				strTemp=binItem.ReadText
				if objForm.Exists(strInam) then
					objForm(strInam) = objForm(strInam)&","&strTemp
				else
					strFormItem=strFormItem&strSplit&strInam
					objForm.Add strInam,strTemp
				end if
			end if

			binItem.Close()
			p_start = p_end+intSeparator+2
		loop Until p_start+3>lngRequestSize
		FormItem=split(strFormItem,strSplit)
		FileItem=split(strFileItem,strSplit)
	End Sub

	Private Function GetTimeStr()
		lngTime=lngTime+1
		GetTimeStr=strDate&lngTime
	End Function

	Private Function GetFerr(lngFsiz,strFext)
		dim intFerr
		intFerr=0
		if lngFsiz>p_MaxSize and p_MaxSize>0 then
			if p_Error=0 or p_Error=2 then p_Error=p_Error+1
			intFerr=intFerr+1
		end If
		If p_FileType<>"*.*" Then
			if Instr(1,LCase("/"&p_FileType&"/"),LCase("/"&strFext&"/"))=0 and p_FileType<>"" then
				if p_Error<2 then p_Error=p_Error+2
				intFerr=intFerr+2
			end If
		End if
		GetFerr=intFerr
	End Function

	Public Function Save(Item,strFnam)
		Save=false
		if objForm.Exists(Item&"_From") then
			dim intFerr,strFext
			strFext=objForm(Item&"_Ext")
			intFerr=GetFerr(objForm(Item&"_Size"),strFext)
			if objForm.Exists(Item&"_Err") then
				if intFerr=0 then
					objForm(Item&"_Err")=0
				end if
			else
				objForm.Add Item&"_Err",intFerr
			end if
			if intFerr<>0 then Exit Function
			if VarType(strFnam)=2 then
				select case strFnam
					case 0:strFnam=GetTimeStr()
						if strFext<>"" then strFnam=strFnam&"."&strFext
					case 1:strFnam=objForm(Item&"_Name")
				end select
			end if
			binItem.Type = 1
			binItem.Open
			binForm.Position = objForm(Item&"_From")
			binForm.CopyTo binItem,objForm(Item&"_Size")
			binItem.SaveToFile Server.MapPath(p_SavePath&strFnam),2
			binItem.Close()
			if objForm.Exists(Item) then
				objForm(Item)=strFnam
			else
				objForm.Add Item,strFnam
			end if
			Save=true
		end if
	End Function

	Public Function GetData(Item)
		GetData=""
		if objForm.Exists(Item&"_From") then
			if GetFerr(objForm(Item&"_Size"),objForm(Item&"_Ext"))<>0 then Exit Function
			binForm.Position = objForm(Item&"_From")
			GetData=binFormStream.Read(objForm(Item&"_Size"))
		end if
	End Function

	Public Function Form(Item)
		if objForm.Exists(Item) then
			Form=objForm(Item)
		else
			Form=""
		end if
	End Function

	Private Function BinVal2(bin)
		dim lngValue,i
		lngValue = 0
		for i = lenb(bin) to 1 step -1
			lngValue = lngValue *256 + ascb(midb(bin,i,1))
		next
		BinVal2=lngValue
	End Function

	Private Function Bin2Val(bin)
		dim lngValue,i
		lngValue = 0
		for i = 1 to lenb(bin)
			lngValue = lngValue *256 + ascb(midb(bin,i,1))
		next
		Bin2Val=lngValue
	End Function

End Class
%>