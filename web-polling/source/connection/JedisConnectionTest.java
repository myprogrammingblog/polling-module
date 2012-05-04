package connection;

import connection.JedisConnection;

public class JedisConnectionTest {
	
	public JedisConnectionTest(){}
	
	public static void main(String[] args) {
		JedisConnection test = new JedisConnection();
		
		System.out.println(test.retrievePoll("1234"));				//true
		System.out.println(test.getTitle());						//sample-poll
		System.out.println(test.getQuestion());						//Is this working?
		System.out.println(test.getMultiple());						//true
		System.out.println(test.getAnswers().length);				//2
		System.out.println(test.getWebKey());						//1234
		
		System.out.println(test.cookieCheck("1234,182,28", "182"));	//true
		System.out.println(test.cleanWebKey("1212b"));				//true
		System.out.println(test.cleanWebKey("1212"));				//false
	}
}
