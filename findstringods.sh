 #!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: search odt file searchterm"
	exit 1
fi

for file in *.odt; do
	unzip -p "$file" content.xml | grep -i "$1" > /dev/null
	if [ $? -eq 0 ]; then
		echo "$file"
	fi;
done
