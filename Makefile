build:
	rm -fr gen && mkdir gen
	dart2js autorestyle.dart -ogen/.js
	cp CNAME index.html gen
