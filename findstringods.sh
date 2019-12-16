 #!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: search odt file searchterm"
	exit 1
fi

for file in $(ls *.odt); do
	unzip -ca "$file" content.xml | grep -ql "$1"
	if [ $? -eq 0 ]; then
		echo "$file"
	fi
done
