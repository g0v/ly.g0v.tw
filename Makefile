JS_FILES=server/app.js server/opengraph.js

.ls.js:
	env PATH="$$PATH:./node_modules/LiveScript/bin" livescript -c  $<

clean:
	rm -f $(JS_FILES)
	rm -rf _public

server : $(JS_FILES)

client:
	./node_modules/.bin/brunch b

build: client server

dev: client
	@echo "Using brunch..."
	./node_modules/.bin/brunch watch --server

run: server
	DEBUG=express:* node server/app.js

.SUFFIXES: .jade .html .ls .js
.PHONY: clean client server build dev run

