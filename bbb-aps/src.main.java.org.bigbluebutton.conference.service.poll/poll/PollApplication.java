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

package org.bigbluebutton.conference.service.poll;

import java.net.InetAddress;
import java.util.List;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import java.util.ArrayList;


import org.bigbluebutton.conference.service.poll.PollRoomsManager;
import org.bigbluebutton.conference.service.poll.PollRoom;
import org.bigbluebutton.conference.service.poll.IPollRoomListener;
import org.bigbluebutton.conference.service.recorder.polling.PollRecorder;
import org.bigbluebutton.conference.service.recorder.polling.PollInvoker;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;


public class PollApplication {

	private static Logger log = Red5LoggerFactory.getLogger( PollApplication.class, "bigbluebutton" );	
		
	private static final String APP = "Poll";
	private PollRoomsManager roomsManager;
	private String CURRENTKEY = "bbb-polling-webID";
	private int MAX_WEBKEYS	= 9999;
	
	public PollHandler handler;
	
	public boolean createRoom(String name) {
		roomsManager.addRoom(new PollRoom(name));
		return true;
	}
	
	public boolean destroyRoom(String name) {
		if (roomsManager.hasRoom(name))
			roomsManager.removeRoom(name);
		destroyPolls(name);
		return true;
	}
	
	public Jedis dbConnect(){
 	   	// Reads IP from Java, for portability
 	       String serverIP = "INVALID IP";
 	       try
 	       {
 	    	   InetAddress addr = InetAddress.getLocalHost();
 	           // Get hostname
 	           String hostname = addr.getHostName();
 	           serverIP = hostname;
 	       } 
 	       catch (Exception e)
 	       {
 	    	   log.error("IP capture failed.");
 	       }
 	       JedisPool redisPool = new JedisPool(serverIP, 6379);
 	       return redisPool.getResource();
    }
	
	public void destroyPolls(String name){
		// Destroy polls that were created in the room
		Jedis jedis = dbConnect();
		ArrayList polls = titleList();
	    int pollCounter = 0;
	    int webCounter = 0;
		for (int i = 0; i < polls.size(); i++){
			String pollKey = name + "-" + polls.get(i).toString();
			Poll doomedPoll = getPoll(pollKey);
			ArrayList <String> webKeys = new ArrayList <String>();
			String webKeyString = jedis.get(CURRENTKEY);
			Integer webKeyInt = Integer.parseInt(webKeyString);
			if (doomedPoll.publishToWeb){
				// Search through the available webkeys to find one that holds this poll
				for (Integer index = 0; index <= webKeyInt; index++){
					String indexStr = index.toString();
					if (jedis.exists(indexStr)){
						if (jedis.get(indexStr).equals(pollKey)){
							webKeys.add(indexStr);
						}
					}
				}
			}
			try{
				jedis.del(pollKey);
				++pollCounter;
				for (String s : webKeys){
					try{
						jedis.del(s);
						++webCounter;
					}
					catch (Exception e){
						log.error("Webkey deletion failed.");
					}
				}
			}
			catch (Exception e){
				log.error("Poll deletion failed.");
			}
		}
	}
	
	public boolean hasRoom(String name) {
		return roomsManager.hasRoom(name);
	}
	
	public boolean addRoomListener(String room, IPollRoomListener listener) {
		if (roomsManager.hasRoom(room)){
			roomsManager.addRoomListener(room, listener);
			return true;
		}
		log.warn("Adding listener to a non-existant room " + room);
		return false;
	}
	
	public void setRoomsManager(PollRoomsManager r) {
		log.debug("Setting room manager");
		roomsManager = r;
	}
	
	public void savePoll(Poll poll) {
        PollRecorder pollRecorder = new PollRecorder();
        pollRecorder.record(poll);
	}
	
	public Poll getPoll(String pollKey)
	{
		PollInvoker pollInvoker = new PollInvoker();
		return pollInvoker.invoke(pollKey);
	}
	
	// AnswerIDs comes in as an array of each answer the user voted for
	// If they voted for answers 3 and 5, the array could be [0] = 3, [1] = 5 or the other way around, shouldn't matter
	public void vote(String pollKey, Object[] answerIDs, Boolean webVote){
		PollRecorder recorder = new PollRecorder();
	    Poll poll = getPoll(pollKey);
	    recorder.vote(pollKey, poll, answerIDs, webVote);
	}
	
	public ArrayList titleList()
	{
		PollInvoker pollInvoker = new PollInvoker();
		ArrayList titles = pollInvoker.titleList(); 
		return titles;
	}
	
	public void setStatus(String pollKey, Boolean status){
		PollRecorder pollRecorder = new PollRecorder();
        pollRecorder.setStatus(pollKey, status);
	}
	
	public String generate(String pollKey){
		Jedis jedis = dbConnect();
		if (!jedis.exists(CURRENTKEY)){
			jedis.set(CURRENTKEY, "0");
		}
		// The value stored in the bbb-polling-webID key represents the next available web-friendly poll ID 		
		String nextWebKey = webKeyIncrement(Integer.parseInt(jedis.get(CURRENTKEY)), jedis);
		jedis.del(nextWebKey);
		jedis.set(nextWebKey, pollKey);
		// Replace the value stored in bbb-polling-webID
		jedis.set(CURRENTKEY, nextWebKey);
		return nextWebKey;
	}
	
	private String webKeyIncrement(Integer index, Jedis jedis){
		String nextIndex;
		if (++index <= MAX_WEBKEYS){
			nextIndex = index.toString();
		}else{
			nextIndex = "1";
		}
		return nextIndex;
	}
}