all: compile

compile:
	@cd ../ && ./rebar -D debug compile
	@erl -pz ../ebin -noshell -eval "io:format(\"~p~n\", [xref:d(\"../ebin\")]), c:q()."
