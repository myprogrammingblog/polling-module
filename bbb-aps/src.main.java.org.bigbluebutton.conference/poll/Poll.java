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

import org.slf4j.Logger;
import org.red5.logging.Red5LoggerFactory;

import net.jcip.annotations.ThreadSafe;
import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@ThreadSafe
public class Poll{

	private static Logger log = Red5LoggerFactory.getLogger( Poll.class, "bigbluebutton" );
	private String LOGNAME = "[Poll]";
	public final String title;
	public final String room;
	public final Boolean isMultiple;
	public final String question;
	public ArrayList <String> answers;
	public Map <String, Integer> answersCount;
	
	@SuppressWarnings("unchecked")
	public Poll( String title , String question , ArrayList answers, Boolean isMultiple, String room){
		log.debug(LOGNAME + "[TEST ] Step 2 :  Poll.java encapsulated received info into object");
		this.question = question;
		this.title= title;
		this.isMultiple = isMultiple;
		this.answers = answers;
		this.room = room;
		structureAnswersCount ();
	}

	public String getRoom() {
		return room;
	}

	/**
	 *  Function that creates a HashMap of answer-integer. Integers that will be incremented as soon as vote starts, thus statistics will be counted
	 **/
	public void structureAnswersCount (){
		answersCount = new HashMap<String, Integer>();
		String _answers;
		for(int i=0; i<answers.size(); i++){
			log.debug(LOGNAME + "[TEST 2] _answers :" + answers.get(i));
			answersCount.put(answers.get(i).toString(), 0);
			log.debug(LOGNAME + "[TEST 2] add to answer count  :"+ answersCount.entrySet());
		}
			
	}

}
