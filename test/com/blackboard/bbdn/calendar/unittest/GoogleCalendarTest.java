/* Copyright (C) 2008, Blackboard Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  -- Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *  -- Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *  -- Neither the name of Blackboard Inc. nor the names of its contributors 
 *     may be used to endorse or promote products derived from this 
 *     software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY BLACKBOARD INC ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL BLACKBOARD INC. BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.blackboard.bbdn.calendar.unittest;

import junit.framework.TestCase;
import com.google.gdata.client.calendar.*;
import com.google.gdata.data.*;
import com.google.gdata.data.calendar.*;
import com.google.gdata.util.*;
import java.net.URL;
import java.io.*;

public class GoogleCalendarTest extends TestCase {

	public void testCreateGradesDocument() throws IOException, ServiceException {

		CalendarService myService = new CalendarService("Bb-Goog-test");

		// Send the request and print the response
		// enter your test feed URL here - it should take the format of:
		// http://www.google.com/calendar/feeds/username%40gmail.com/private-04401eee224d8100da374da060bfc2b0/full
		URL feedUrl = new URL("http://www.google.com/calendar/feeds//full");
		CalendarEventFeed resultFeed = new CalendarEventFeed();
		try {
			CalendarQuery cq = new CalendarQuery(feedUrl);
			cq.setMinimumStartTime(DateTime.now());
			cq.setMaximumStartTime(new DateTime(org.apache.commons.lang.time.DateUtils.addDays(new java.util.Date(System.currentTimeMillis()), 7)));
			cq.setStringCustomParameter("singleevents", "true");
			resultFeed = myService.query(cq, CalendarEventFeed.class);
		} catch (Exception e) {
			e.printStackTrace();
		}
		for (int i = 0; i < resultFeed.getEntries().size(); i++) {
			com.google.gdata.data.calendar.CalendarEventEntry entry = resultFeed.getEntries().get(i);
			System.out.println("<br>" + entry.getTitle().getPlainText());
			System.out.println("<br>" + entry.getTimes().get(0).getStartTime());
			if (null != entry.getRecurrence()) {
				System.out.println(entry.getRecurrence().getValue() + "<br>");
			}
		}

	}
}
