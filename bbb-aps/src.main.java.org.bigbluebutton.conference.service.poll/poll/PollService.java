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

import org.apache.commons.lang.time.DateFormatUtils;
import org.bigbluebutton.conference.service.poll.PollApplication;
import org.bigbluebutton.conference.service.poll.Poll;
import java.util.ArrayList;
import java.util.Arrays;

import java.util.List;

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;
import org.red5.server.api.so.ISharedObject;

import org.red5.server.api.Red5;

import redis.clients.jedis.Jedis;




public class PollService {
	
	private static Logger log = Red5LoggerFactory.getLogger( PollService.class, "bigbluebutton" );
	
	private PollApplication application;
	private String LOGNAME = "[PollService]";
	private Poll poll;
	
	// This method is called by the savePoll method in bbb-client PollingService.as
	public void savePoll(ArrayList answers, String question , String title , Boolean isMultiple, String room, ArrayList votes, String time ) {
		log.debug(LOGNAME + "[TEST ]Step 1 : pollService received info: title:"+title+ " answers:"+ answers.toString()+   " Question: "+question+ " isMultiple ? " +isMultiple.toString());
	    String roomName = Red5.getConnectionLocal().getScope().getName();
	    String pollTime = DateFormatUtils.formatUTC(System.currentTimeMillis(), "MM/dd/yy HH:mm");
	    poll = new Poll(title, question, answers, isMultiple, roomName, votes, pollTime);
	    log.debug(LOGNAME + "[TEST ] Step 3 :  Sending Poll object to PollApplication");
		application.savePoll(poll);
	}
	
	public void setPollApplication(PollApplication a) {
		log.debug(LOGNAME + "Setting Poll Applications");
		application = a;
	}
	
	public ArrayList getPoll(String pollKey)
	{
		log.debug(LOGNAME + "Retrieving poll with key: " + pollKey);
		Poll poll = application.getPoll(pollKey);
		log.debug(LOGNAME + "Retrieved poll " + poll.title);
		
		ArrayList values = new ArrayList();
		values.add(poll.title);
		values.add(poll.room);
		values.add(poll.isMultiple);
		values.add(poll.question);
		values.add(poll.answers);
		values.add(poll.votes);
		values.add(poll.time);		
		return values;
	}
	
	public void vote(String pollKey, ArrayList answerIDs)
	{
		// Add a poll.Vote bean nc.call
		application.vote(pollKey, answerIDs);
		/*
		// TESTING: Automatically send in a vote to observe the results.
		ArrayList voteTest = new ArrayList();
		voteTest.add(2);
		if (poll.isMultiple){voteTest.add(1);}
		vote(pollKey, voteTest);
		*/
	}
	
	
}
