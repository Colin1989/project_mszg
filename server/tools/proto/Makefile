all: compile

compile:
	@rm -f *flymake*
	@erl -make
	erl -pz ebin -noshell -s gen_protocal start -s gen_enum_def start -s gen_protocal_csharp start -s init stop 
	@mv  protocal.erl ../../src; 
	@mv  packet_def.hrl ../../include; 
	@mv  enum_def.hrl ../../include; 
	#@mv  EnumDef.cs ../../../../client/Assets/Plugins/network; 
	#@mv  NetMsgType.cs ../../../../client/Assets/Plugins/network; 
	#@mv  NetPacket.cs ../../../../client/Assets/Plugins/network

clean:
	rm -rf ebin/*.beam erl_crash.dump
