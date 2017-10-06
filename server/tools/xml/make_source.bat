rm -f *flymake*
erl -make
erl -noshell -s make_xml_source start -s init stop
pause