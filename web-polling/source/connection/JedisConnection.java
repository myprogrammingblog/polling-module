/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
*
* Copyright (c) 2010 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 2.1 of the License, or (at your option) any later
* version.
*
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
* 
*/

package connection;

import java.util.ArrayList;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import java.net.InetAddress;
import java.net.UnknownHostException;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class JedisConnection {
	JedisPool redisPool;

	String pollKey;
	String title;
	String question;
	String multiple;
	ArrayList<String> answers;
	
	String curWebKey;
	ArrayList<String> pollsVoted = new ArrayList<String>();
	
	private Jedis dbConnect() {
		String serverIP = "INVALID IP";
		try {
			serverIP = InetAddress.getLocalHost().getHostAddress();
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		redisPool = new JedisPool(serverIP, 6379);
		return redisPool.getResource();
	}

	public boolean retrievePoll(String webKey) {
		Jedis jedis = dbConnect();

		if (jedis.exists(webKey)) {
			curWebKey = webKey;
			
			pollKey = jedis.get(webKey);
			title = jedis.hget(pollKey, "title");
			question = jedis.hget(pollKey, "question");
			multiple = jedis.hget(pollKey, "multiple");
			
			long pollSize = jedis.hlen(pollKey);
			int otherFields = 10;
	 	   	long numAnswers = (pollSize-otherFields)/2;
	 	   	
	 	   	answers  = new ArrayList <String>();
	 	   	
	 	   	for (int j = 1; j <= numAnswers; j++) {
	 	   		answers.add(jedis.hget(pollKey, "answer"+j+"text"));
	 	   	}
	 	   	
	 	   	return true;
		} else
			return false;
		
	}
	
	public void recordRadioVote(String vote) {
		Jedis jedis = dbConnect();
		
		jedis.hincrBy(pollKey, "totalVotes", 1);
		jedis.hincrBy(pollKey, "answer"+vote, 1);
		
		pollsVoted.add(curWebKey);
	}
	
	public void recordCheckVote(String [] votes) {
		Jedis jedis = dbConnect();
		
		jedis.hincrBy(pollKey, "totalVotes", 1);
		
		for (int i=0; i<votes.length; i++) {
			jedis.hincrBy(pollKey, "answer"+votes[i], 1);
		}
		
		pollsVoted.add(curWebKey);
	}
	
	public boolean cookieCheck(String cv, String webkey) {
		Pattern p = Pattern.compile(","+webkey+",");
		Matcher m = p.matcher(cv);
		return m.find(0);
	}
	
	public boolean cleanWebKey(String key) {
		Pattern p = Pattern.compile("[^\\d]");
		Matcher m = p.matcher(key);
		return m.find(0);
	}
	
	public boolean sessionVoted(String poll) {
		return pollsVoted.contains(poll);
	}
	
	public String getTitle() {
		return title;
	}
	
	public String getQuestion() {
		return question;
	}
	
	public String getMultiple() {
		return multiple;
	}
	
	public String [] getAnswers() {
		String [] temp = new String [answers.size()];
		return answers.toArray(temp);
	}
	
	public String getWebKey() {
		return curWebKey;
	}
}
