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
	private int MAX_WEBKEYS	= 9;
	
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
 	       	log.debug("[TEST] IP capture successful, IP is " + serverIP);
 	       } catch (Exception e)
 	       {
 	       	log.debug("[TEST] IP capture failed...");
 	       }
 	       
 	       JedisPool redisPool = new JedisPool(serverIP, 6379);
 	       return redisPool.getResource();
    }
	
	public void destroyPolls(String name){
		// Destroy polls that were created in the room
		Jedis jedis = dbConnect();
		log.debug("PollApplication.destroyPolls");
		
		/*/ For debugging purposes only, remove before release
			log.debug("[TEST] Cleaning Redis store ");
			for (String s : jedis.keys("*"))
	    	{
				jedis.del(s);
	    	}
		*/// DEBUG: Clean Redis Store
		
		//*
		ArrayList polls = titleList();
		
	    int pollCounter = 0;
	    int webCounter = 0;
	    
		for (int i = 0; i < polls.size(); i++){
			String pollKey = name + "-" + polls.get(i).toString();
			Poll doomedPoll = getPoll(pollKey);
			//String webKey = null;
			ArrayList <String> webKeys = new ArrayList <String>();
			
			
			String webKeyString = jedis.get(CURRENTKEY);
			Integer webKeyInt = Integer.parseInt(webKeyString);
			log.debug("webKeyString is " + webKeyString + " and webKeyInt is " + webKeyInt);
			
			if (doomedPoll.publishToWeb){
				log.debug("Poll is web-enabled, prepping for webkey deletion");
				// Search through the available webkeys to find one that holds this poll
				for (Integer index = 0; index <= webKeyInt; index++){
					String indexStr = index.toString();
					log.debug("indexStr is " + indexStr);
					if (jedis.exists(indexStr)){
						if (jedis.get(indexStr).equals(pollKey)){
							log.debug("PollKey has been found at webKey " + indexStr);
							webKeys.add(indexStr);
						}
					}
				}

				log.debug("The poll about to be deleted lives at webKey: " + webKeys);
			}
			try{
				jedis.del(pollKey);
				++pollCounter;
				log.debug("[TEST] Poll deletion successful on title: " + polls.get(i).toString());
				
				for (String s : webKeys){
					log.debug("Trying to delete webkey " + s);
					try{
						jedis.del(s);
						log.debug("Webkey deletion successful!");
						++webCounter;
					}
					catch (Exception e){
						log.debug("[ERROR] Webkey deletion had a problem.");
					}
				}
			}
			catch (Exception e){
				log.debug("[ERROR] Poll deletion had a problem.");
			}
			log.debug(" Deleted " + pollCounter + " polls.");
			log.debug(" Deleted " + webCounter + " webkeys.");
		}//*/
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
		log.debug("[TEST] Step 4 inside  savePoll of PollApplication sending poll to roomsManager and saving data to PollRecorder:");
		poll.checkObject();
        PollRecorder pollRecorder = new PollRecorder();
        pollRecorder.record(poll);
	}
	
	public Poll getPoll(String pollKey)
	{
		log.debug("[TEST] Inside retrievePoll of PollApplication.java passing a Poll object back up to Pollservice");
		PollInvoker pollInvoker = new PollInvoker();
		return pollInvoker.invoke(pollKey);
	}
	
	// AnswerIDs comes in as an array of each answer the user voted for
	// If they voted for answers 3 and 5, the array could be [0] = 3, [1] = 5 or the other way around, shouldn't matter
	public void vote(String pollKey, Object[] answerIDs, Boolean webVote){
		log.debug("[TEST] Recording votes");
	    // Retrieve the poll that corresponds to pollKey
		PollRecorder recorder = new PollRecorder();
	    Poll poll = getPoll(pollKey);
	    recorder.vote(pollKey, poll, answerIDs, webVote);
	}
	
	public ArrayList titleList()
	{
		log.debug("Entering PollApplication titleList");
		PollInvoker pollInvoker = new PollInvoker();
		ArrayList titles = pollInvoker.titleList(); 
		log.debug("Leaving PollApplication titleList");
		return titles;
	}
	
	public void setStatus(String pollKey, Boolean status){
		log.debug("[TEST] In pollApplication, setting status of " + pollKey + " to " + status);	
        PollRecorder pollRecorder = new PollRecorder();
        pollRecorder.setStatus(pollKey, status);
	}
	
	public String generate(String pollKey){
		log.debug("Entering PollApplication.generate with pollKey " + pollKey);
		Jedis jedis = dbConnect();
		
		if (!jedis.exists(CURRENTKEY) || Integer.parseInt(jedis.get(CURRENTKEY)) > MAX_WEBKEYS){
			// If the bbb-polling-webID key doesn't exist, or has reached the limit set in MAX_WEBKEYS, start/restart it at "0"
			// We don't need to worry about deleting keys when we loop around, because Redis will simply overwrite what's already there if it comes to that.
			// With a high enough value in MAX_WEBKEYS, that won't be a problem to functionality.
			if (!jedis.exists(CURRENTKEY))
				log.debug("The " + CURRENTKEY + " pair doesn't exist, creating it again with zero.");
			if (Integer.parseInt(jedis.get(CURRENTKEY)) > MAX_WEBKEYS)
				log.debug("The " + CURRENTKEY + " pair exceeds the max, creating it again with zero.");
			jedis.set(CURRENTKEY, "0");
			log.debug("Success in setting/resetting " + CURRENTKEY);
		}
		
		// The value stored in the bbb-polling-webID key represents the next available web-friendly poll ID 
		String webKeyString = jedis.get(CURRENTKEY);
		Integer webKeyInt = Integer.parseInt(webKeyString);
		
		// Increment the web poll ID until we find one that isn't being used
		while (jedis.exists(webKeyString)){
			log.debug("The pair with key " + webKeyString + " exists, incrementing and trying again.");
			++webKeyInt;
			webKeyString = webKeyInt.toString();
			log.debug("WebKeyString is now " + webKeyString);
		}
		log.debug("Checking is done, setting a new pair with " + webKeyString + " and the pollKey for a value.");
		jedis.set(webKeyString, pollKey);
		// Replace the value stored in bbb-polling-webID
		jedis.set(CURRENTKEY, webKeyString);
		return webKeyString;
	}
}

	
