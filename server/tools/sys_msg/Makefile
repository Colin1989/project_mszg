all: compile

compile:
	@rm -f *flymake*
	@erl -make
	@erl -noshell -s make_sys_msg_def start -s init stop

clean:
	rm -rf ebin/*.beam erl_crash.dump
