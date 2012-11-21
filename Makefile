build: clean
	mkdir gen
	dart2js autorestyle.dart -ogen/.js
	cp CNAME index.html gen
clean:
	rm -rf gen
commit:
	git checkout gh-pages
	git rm -rf --ignore-unmatch .
	find gen -type f | xargs -I% cp % .
	git add -A
	git rm -r --cached gen
	git commit --porcelain && git save || true
	git checkout -
