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
	public PollHandler handler;

	
	
	public boolean createRoom(String name) {
		roomsManager.addRoom(new PollRoom(name));
		return true;
	}
	
	public boolean destroyRoom(String name) {
		if (roomsManager.hasRoom(name)) {
			roomsManager.removeRoom(name);
			// Destroy polls that were created in the room
			
			// REDIS CONNECTION
			JedisPool redisPool;
			// Reads IP from Java, for portability
		    String serverIP = "INVALID IP";
		    try
		    {
		    	InetAddress addr = InetAddress.getLocalHost();
		        // Get hostname
		        String hostname = addr.getHostName();
		        serverIP = hostname;
		    } catch (Exception e){}
		    redisPool = new JedisPool(serverIP, 6379);
		    Jedis jedis = redisPool.getResource();
		    // _REDIS CONNECTION
		    for (String s : jedis.keys(name+"*"))
		    {
		       try
		       {
		    	   jedis.del(s);
		    	   log.debug("[TEST] Deletion of key " + s + " successful!");
		       } 
		       catch (Exception e) 
		       {
		    	   log.debug("[TEST] Error in deleting key.");
		       }
		    }
		    redisPool.returnResource(jedis);
		    // _Poll destruction
		}
		return true;
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
	public void vote(String pollKey, Object[] answerIDs){
		log.debug("[TEST] Recording votes");
	    // Retrieve the poll that corresponds to pollKey
	    Poll poll = getPoll(pollKey);
	    for (int i = 0; i < answerIDs.length; i++){
	    	// Extract  the index value stored at element i of answerIDs
	    	Integer index = Integer.parseInt(answerIDs[i].toString());
	    	// Get the current value of votes for that index; remember that the answers are now zero-based like an array
	    	Integer total = poll.votes.get(index.intValue());
	    	// Increment the votes for answer
	    	poll.votes.set(index.intValue(), ++total);
	    }
	    ++poll.totalVotes;
	    --poll.didNotVote;
	    savePoll(poll);
	}
	
	public ArrayList titleList()
	{
		log.debug("Entering PollApplication titleList");
		PollInvoker pollInvoker = new PollInvoker();
		ArrayList titles = pollInvoker.titleList(); 
		log.debug("Leaving PollApplication titleList");
		return titles;
	}
	
	public ArrayList statusList()
	{
		log.debug("Entering PollInvoker titleList");
		PollInvoker pollInvoker = new PollInvoker();
		ArrayList status = pollInvoker.statusList();
		log.debug("Leaving PollApplication statusList");
		return status;
	}
	
	public void setStatus(String pollKey, Boolean status){
		log.debug("[TEST] In pollApplication, setting status of " + pollKey + " to " + status);	
        PollRecorder pollRecorder = new PollRecorder();
        pollRecorder.setStatus(pollKey, status);
	}
}

	
