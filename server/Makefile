
REBAR=./rebar

.PHONY: test

all: make_bossdb make_erlcron debug_crypto_autoUpdate

make_bossdb:
	cd deps/boss_db && make

make_erlcron:
	cd deps/erlcron && make

generate:
	$(REBAR) generate force=1

debug:
	$(REBAR) -D debug compile

release:
	$(REBAR) -D release compile

clean:
	$(REBAR) clean

test:
	$(REBAR) -D debug compile ct

compile:
	$(REBAR) -D release compile

crypto:
	$(REBAR) -D release -D crypto -D auto_update compile

debug_crypto:
	$(REBAR) -D debug -D crypto compile

release_crypto:
	$(REBAR) -D release -D crypto compile
	
debug_crypto_autoUpdate:
	$(REBAR) -D debug -D crypto -D auto_update compile
	
release_crypto_autoUpdate:
	$(REBAR) -D release -D crypto -D auto_update compile