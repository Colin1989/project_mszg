.PHONY: test

all:
	./rebar -D debug compile

generate:
	./rebar generate force=1

debug:
	./rebar -D debug compile

release:
	./rebar -D release compile

clean:
	./rebar clean

test:
	./rebar -D debug compile ct

compile:
	./rebar -D release compile

crypto:
	./rebar -D release -D crypto compile