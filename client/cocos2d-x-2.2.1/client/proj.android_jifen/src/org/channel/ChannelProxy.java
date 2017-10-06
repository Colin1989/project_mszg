package org.channel;


public class ChannelProxy {
	
	static ChannelOperators operators = null;
	
	public static ChannelOperators getInstance(){
		if(operators == null){
			
//			operators = new Onekes_Channel(); //��������
			
			operators = new Jifen_Channel();
		}
		
		return operators;
	}

}
