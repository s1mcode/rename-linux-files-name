#!/bin/bash
ROOT_DIR="/root/tools/test"

echo "开始批量替换文件名中的所有空格"
find $ROOT_DIR -type f -name "* *" -print |
while read name; do
	na=$(echo $name | tr ' ' '_')
	if [[ $name != $na ]]; then
		mv "$name" $na
	fi
done
echo "文件名中的空格全部替换完毕"

echo "开始批量去除文件名中所有非ASCII字符"
find $ROOT_DIR -type f -print0 | \
perl -n0e '$new = $_; if($new =~ s/[^[:ascii:]]//g) {
  print("Renaming $_ to $new\n"); rename($_, $new);
}'
echo "文件名中的非ASCII字符全部去除完毕"

echo "开始批量去除文件名中的所有特殊符号"
find $ROOT_DIR -type f -print |
while read name; do
	na=$(sed 's|[^0-9A-Za-z_./-]||g' <<< "$name")
	if [[ $name != $na ]]; then
		mv "$name" $na
	fi
done
echo "文件名中的特殊符号全部去除完毕"

# sed不支持\d类、\D、\W反义类，零宽断言、懒惰（非贪婪）模式。所以下面使用rename命令进行替换。文件名中不会出现./这两个字符。
echo "开始批量去除文件名中的冗余信息"
find $ROOT_DIR -type f -print |
while read name; do
	rename -v 's/(?<=\d{4}-\d{2}-\d{2}-\d{1,20})-[0-9A-Za-z_-]*?(?=(?:_watermark|_compress_watermark)?\.)//g' $name
done
echo "文件名中的冗余信息全部去除完毕"