all: compile

compile:
	@rm -f *flymake*
	@erl -make
	@erl -noshell -s make_xml_source start -s init stop

clean:
	rm -rf ebin/*.beam erl_crash.dump
