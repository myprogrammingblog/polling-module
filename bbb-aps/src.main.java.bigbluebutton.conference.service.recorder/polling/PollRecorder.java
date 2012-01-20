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

package org.bigbluebutton.conference.service.recorder.polling;


import java.net.InetAddress;

import javax.servlet.ServletRequest;

import org.red5.logging.Red5LoggerFactory;
import org.slf4j.Logger;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

//import java.util.Date;

import org.apache.commons.lang.time.DateFormatUtils;

import org.bigbluebutton.conference.service.poll.Poll;


public class PollRecorder {
        private static Logger log = Red5LoggerFactory.getLogger( PollRecorder.class, "bigbluebutton");

       //private static final String COLON=":";
        JedisPool redisPool;
        String rHost;
        int rPort;


         public PollRecorder() {
        	 super();
                  log.debug("[TEST] initializing PollRecorder");

         }

        public JedisPool getRedisPool() {
        	 return redisPool;
        }

        public void setRedisPool(JedisPool pool) {
        	 this.redisPool = pool;
        }

        public void record(Poll poll) {
            log.debug("[TEST] inside pollRecorder record");
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
            
            redisPool = new JedisPool(serverIP, 6379);
            Jedis jedis = redisPool.getResource();
			
            // Merges the poll title, room into a single string seperated by a hyphen
			String pollKey = poll.room + "-" + poll.title;

			// Saves all relevant information about the poll as fields in a hash; dynamically generates
			// enough fields for each answer and the number of votes for each answer
			jedis.hset(pollKey, "title", poll.title);
			jedis.hset(pollKey, "question", poll.question);
			jedis.hset(pollKey, "multiple", poll.isMultiple.toString());
			
			for (int i = 1; i <= poll.answers.size(); i++)
			{
				jedis.hset(pollKey, "answer"+i+"text", poll.answers.toArray()[i-1].toString());
				jedis.hset(pollKey, "answer"+i, "0");
			}

			String time = DateFormatUtils.formatUTC(System.currentTimeMillis(), "MM/dd/yy HH:mm");
			jedis.hset(pollKey, "room", poll.room);
			jedis.hset(pollKey, "time", time); 
			redisPool.returnResource(jedis);
			log.debug("[TEST] after Jedis jedis");
			
			// The rest of this method is simply a demonstration that jedis is in fact writing to the data store,
			// and also provides a template for extracting an individual poll
			log.debug("[TEST] Stored under poll key: " + pollKey);
			
			log.debug("[TEST] Field Title is: " + jedis.hget(pollKey, "title"));
			log.debug("[TEST] Field Question is: " + jedis.hget(pollKey, "question"));
			log.debug("[TEST] Field Multiple is: " + jedis.hget(pollKey, "multiple"));
			
			long pollSize = jedis.hlen(pollKey);
			// IMPORTANT! 
			// Increase the value of otherFields for each field you add to the hash which is not a new answer
			// (locales, langauge, etc)
			int otherFields = 5;
			long numAnswers = + (pollSize-otherFields)/2;
			log.debug("[TEST] This key contains " + pollSize + " items.");
			log.debug("[TEST] Number of answers: " + numAnswers);
			
			for (int j = 1; j <= numAnswers; j++)
			{
				log.debug("[TEST] Field Answer"+j+"Text is: " + jedis.hget(pollKey, "answer"+j+"text"));
				log.debug("[TEST] Field Answer"+j+" is: " + jedis.hget(pollKey, "answer"+j));
			}
			
			log.debug("[TEST] Field Room is: " + jedis.hget(pollKey, "room"));
			log.debug("[TEST] Field Time is: " + jedis.hget(pollKey, "time"));
        }
        
        /*
         poll retrieval method {
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
            
            redisPool = new JedisPool(serverIP, 6379);
            Jedis jedis = redisPool.getResource();
         
            String pTitle = jedis.hget(pollKey, "title");
			String pQuestion = jedis.hget(pollKey, "question");
			bool pMultiple = jedis.hget(pollKey, "multiple").toBoolean()
			
			// Answer extraction
			long pollSize = jedis.hlen(pollKey);
			// IMPORTANT! 
			// Increase the value of otherFields for each field you add to the hash which is not a new answer
			// (locales, langauge, etc)
			int otherFields = 5;
			long numAnswers = + (pollSize-otherFields)/2;
			// Create an ArrayList of Strings for answers, and one of ints for answer votes
			for (int j = 1; j <= numAnswers; j++)
			{
				log.debug("[TEST] Field Answer"+j+"Text is: " + jedis.hget(pollKey, "answer"+j+"text"));
				log.debug("[TEST] Field Answer"+j+" is: " + jedis.hget(pollKey, "answer"+j));
			}
			
			String pRoom = jedis.hget(pollKey, "room");
			String pTime = jedis.hget(pollKey, "time");
         }
         */
}
