	Dim theStr
	theStr = InputBox("请输入要加密的字串")

	If theStr <> "" Then
		Call InputBox("请复制已经加密好的字串",,Encode(theStr))
	End If

	Function Encode(strPass)
		Dim i, theStr, strTmp

		For i = 1 To Len(strPass)
			strTmp = Asc(Mid(strPass, i, 1))
			theStr = theStr & Abs(strTmp)
		Next

		strPass = theStr
		theStr = ""

		Do While Len(strPass) > 16
			strPass = JoinCutStr(strPass)
		Loop

		For i = 1 To Len(strPass)
			strTmp = CInt(Mid(strPass, i, 1))
			strTmp = IIf(strTmp > 6, Chr(strTmp + 60), strTmp)
			theStr = theStr & strTmp
		Next

		Encode = theStr
	End Function
	
	Function JoinCutStr(str)
		Dim i, theStr
		For i = 1 To Len(str)
			If Len(str) - i = 0 Then Exit For
			theStr = theStr & Chr(CInt((Asc(Mid(str, i, 1)) + Asc(Mid(str, i + 1, 1))) / 2))
			i = i + 1
		Next
		JoinCutStr = theStr
	End Function

	Function IIf(var, val1, val2)
		If var = True Then
			IIf = val1
		 Else
			IIf = val2
		End If
	End Function