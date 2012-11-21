build: clean
	mkdir gen
	dart2js autorestyle.dart -ogen/.js
	cp CNAME index.html gen
clean:
	rm -rf gen
commit:
	git checkout gh-pages
	git rm -rf --ignore-unmatch .
	find gen -type f | xargs -I% mv % .
	rmdir gen
	git add -A
	git commit --dry-run && git save || true
	git checkout -
