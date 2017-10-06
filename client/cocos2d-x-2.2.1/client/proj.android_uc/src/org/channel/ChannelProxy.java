package org.channel;


public class ChannelProxy {
	
	static ChannelOperators operators = null;
	
	public static ChannelOperators getInstance(){
		if(operators == null){
			
			operators = new UC_Channel(); //自有渠道
		}
		
		return operators;
	}

}
