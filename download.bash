# Copyright (c) 2023, Muhammed Enes Kaya
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash
base_url="https://i.4cdn.org/"
download_root="./out/"

wget --timestamping --no-verbose --input-file=./threads --tries=inf --directory-prefix=./tmp/html/

for html in ./tmp/html/*; do
	> ./tmp/ext_urls
	> ./tmp/temporary
	> ./tmp/urls

	echo -e $(cat $html | grep -Po "File: <a href=\"//is2.4chan.org/(.+?)\"" | \
				  sed -e "s!File: <a href=\"//is2.4chan.org/!!g" | \
				  sed -e "s!\"!!g") >> ./tmp/ext_urls
	for temp in $(< ./tmp/ext_urls); do
		echo $temp >> ./tmp/temporary
	done
	cp ./tmp/temporary ./tmp/ext_urls && rm ./tmp/temporary

	for ext_url in $(< ./tmp/ext_urls); do
		url=$(echo "$base_url$ext_url")
		echo $url >> ./tmp/urls
	done;

	tid=$(echo -e $(file $html | grep -Po "\./tmp/html/([0-9]+):" | \
						sed -e "s!\./tmp/html/!!g" | \
						sed "s!:!!g"))
	mkdir -p "${download_root}/${tid}"
	wget --no-clobber --no-verbose --input-file=./tmp/urls --tries=inf --directory-prefix="${download_root}${tid}"

	title=$(echo -e $(cat $html | grep -Po "<blockquote class=\"postMessage\" id=\"m${tid}\">(.*?)</blockquote>") | \
				sed -e "s!<blockquote class=\"postMessage\" id=\"m${tid}\">!!g" | \
				sed -e "s!</blockquote>!!g" | \
				sed -e "s!<span class=\"quote\">&gt;!>!g" | \
				sed -e "s!&#039;!'!g" | \
				sed -e "s!</span>!!g" | \
				sed -e "s!<s>!!g" | \
				sed -e "s!</s>!!g" | \
				sed -e "s!<br>!\`\`\`\`!g")
	grep -qF "${tid}" ./saved.org || echo "|${title}|${tid}|" >> ./saved.org
done;
