build: clean
	mkdir gen
	dart2js autorestyle.dart -ogen/autorestyle.js
	cp CNAME index.html gen
clean:
	rm -rf gen
commit:
	git checkout gh-pages
	git rm -rf --ignore-unmatch .
	test -d gen && find gen -type f | xargs -I% cp % .
	git save -A || true
	git checkout -
