<%/* Copyright (C) 2008, Blackboard Inc.
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
 */%>
<%@page	import=	"com.blackboard.bbdn.calendar.UnifiedCalendarEntry,
				blackboard.base.BbList,
				blackboard.data.calendar.CalendarEntry,
				blackboard.persist.calendar.CalendarEntryDbLoader,
				blackboard.data.user.User,
				blackboard.platform.session.BbSession,
				blackboard.portal.servlet.PortalRequestContext,
				blackboard.portal.servlet.PortalUtil,
				blackboard.portal.data.PortalExtraInfo,
				blackboard.portal.data.Module,
				com.google.gdata.data.calendar.*,
				com.google.gdata.client.calendar.*,
				com.google.gdata.data.*,
				java.net.URL,
				java.util.List,
				java.util.ArrayList,
				java.util.Date,
				java.util.Calendar,
				org.apache.commons.lang.time.DateUtils,
				org.apache.commons.lang.time.DateFormatUtils"
	errorPage="/error.jsp"%>
<%@ taglib uri="/bbData" prefix="bbData"%>
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<bbData:context>
	<%
		// this is the master list of both the Google calendar events and Bb calendar events
		List<UnifiedCalendarEntry> masterList = new ArrayList();

		// these statements are used to load the URL to the user's private calendar feed
		// the feed URL looks like this: http://www.google.com/calendar/feeds/username%40gmail.com/private-04401eee224d8100da374da060bfc2b0/full
		Module m = PortalUtil.getModule(pageContext);
		PortalRequestContext prc = PortalUtil.getPortalRequestContext(pageContext);
		PortalExtraInfo pei = PortalUtil.loadPortalExtraInfo(m.getId(), prc.getPortalViewerId());
		String data = pei.getExtraInfo().getValue("CalendarData");
		
		int numDaysShown;
		// if the user has not entered this URL yet, don't do anything. 
		if (data == null) {
			 // default to 7 if this has not been configured yet
			numDaysShown = 7;			
		} else {
			// else, parse the calendar configuration from the portal extra info data
			String xmlFeedUrl = data.substring(0, data.indexOf("|"));
			if (xmlFeedUrl.endsWith("/basic")) {
				// we need the full Google feed for the Google API to work correctly, but the Google GUI defaults to giving the basic feed URL 
				// (meaning that most people are going to configure this with the basic URL), so fixing this here
				xmlFeedUrl = xmlFeedUrl.substring(0, xmlFeedUrl.indexOf("/basic")) + "/full";
			}
			
			// time zone is needed to correct one inconsistency below
			int timeZoneOffset = Integer.valueOf(data.substring(data.indexOf("|") + 1, data.lastIndexOf("|"))).intValue();
			
			// if the user actually configured how many days to be shown
			numDaysShown = Integer.valueOf(data.substring(data.lastIndexOf("|") + 1, data.length())).intValue();

			// create a Google calendar service
			CalendarService myService = new CalendarService("Bb-Goog-1");
			URL feedUrl = new URL(xmlFeedUrl);
			CalendarEventFeed resultFeed = new CalendarEventFeed();

			//get the feed from the Google service
			try {
				CalendarQuery cq = new CalendarQuery(feedUrl);
				// today/right now to start
				cq.setMinimumStartTime(DateTime.now());
				//however many days in the future to end, added with Apache Commons data utils
				cq.setMaximumStartTime(new DateTime(DateUtils.addDays(new java.util.Date(System.currentTimeMillis()), numDaysShown)));
				// setting so that events that recur are returned as individual events
				cq.setStringCustomParameter("singleevents", "true");
				resultFeed = myService.query(cq, CalendarEventFeed.class);
			} catch (Exception e) {
				e.printStackTrace();
			}

			//load the events from the feed
			for (int i = 0; i < resultFeed.getEntries().size(); i++) {
				// get the Google calendar item
				// full package and class to avoid conflicts between Google CalendarEntry and Bb CalendarEntry
				com.google.gdata.data.calendar.CalendarEventEntry entry = resultFeed.getEntries().get(i);

				// create our "unified" calendar item from the Google one
				// we do this so that we can organize all of the calendar events from both Google and Blackboard
				// into a single list that we can sort and display chronologically 
				
				// for multi-day events
				if (entry.getTimes().get(0).getEndTime().getValue() >= DateUtils.addDays(new Date(entry.getTimes().get(0).getStartTime().getValue()), 1).getTime()) {
					// ANOMALY ALERT - For multi-day events, the times returned by Google are not in the time zone as specified in Google preferences
					// they are returned in GMT. Therefore, we need to convert these times to the local time zone to display properly in the Bb GUI.
					long startTime = DateUtils.addHours(new Date(entry.getTimes().get(0).getStartTime().getValue()), timeZoneOffset).getTime();
					long endTime = DateUtils.addHours(new Date(entry.getTimes().get(0).getEndTime().getValue()), timeZoneOffset).getTime();
		
					//iterate through multi-day events here, representing each as an individual day-long event
					do {
						UnifiedCalendarEntry uce = new UnifiedCalendarEntry();
						uce.setTitle(entry.getTitle().getPlainText());
						uce.setUrl(entry.getHtmlLink().getHref());
						uce.setStartDate(startTime);
						startTime = DateUtils.addDays(new Date(startTime), 1).getTime();
						uce.setEndDate(startTime);
						masterList.add(uce);
						uce = null;
					} while ((startTime < endTime) && startTime < DateUtils.addDays(new Date(System.currentTimeMillis()), numDaysShown).getTime());
				} else {
					//for non-multi-day events, represent individually
					UnifiedCalendarEntry bbentry = new UnifiedCalendarEntry();
					bbentry.setStartDate(DateUtils.addHours(new Date(entry.getTimes().get(0).getStartTime().getValue()), 0).getTime());
					bbentry.setEndDate(DateUtils.addHours(new Date(entry.getTimes().get(0).getEndTime().getValue()), 0).getTime());
					bbentry.setTitle(entry.getTitle().getPlainText());
					bbentry.setUrl(entry.getHtmlLink().getHref());
					masterList.add(bbentry);
				}

			}
		}

		// just like we created a Google calendar service to load those calendar entries
		// we use the Blackboard calendar entry loader to get the Bb calendar entries
		CalendarEntryDbLoader cedl = CalendarEntryDbLoader.Default.getInstance();
		User usr = bbContext.getUser();
		//start date 
		java.util.Calendar now = java.util.Calendar.getInstance();
		// end date adds the number of days to be shown
		java.util.Calendar then = java.util.Calendar.getInstance();
		then.add(Calendar.DAY_OF_YEAR, numDaysShown);
		BbList entries = cedl.loadByUserId(usr.getId(), now, then);

		for (int i = 0; i < entries.size(); i++) {
			// get the Blackboard calendar item
			// full package and class to avoid conflicts between Google CalendarEntry and Bb CalendarEntry
			blackboard.data.calendar.CalendarEntry entry = (blackboard.data.calendar.CalendarEntry) entries.get(i);

			//create out calendar item from the Blackboard one just like we did above
			UnifiedCalendarEntry bbentry = new UnifiedCalendarEntry();
			//create Bb URL (not in API, so has to be done manually)
			bbentry.setUrl("/bin/common/calendar.pl?subroutine=event_view&go_to=my_inst&location=mybb&_event_id=" + entry.getId().getExternalString());
			bbentry.setTitle(entry.getTitle());
			bbentry.setStartDate(entry.getStartDate().getTimeInMillis());
			bbentry.setEndDate(entry.getEndDate().getTimeInMillis());
			masterList.add(bbentry);
		}

		// sort all of our calendar items by date
		java.util.Collections.sort(masterList);

		//output the calendar items to the screen
		long oldStartDate = System.currentTimeMillis();  //initialize
		
		for (int i = 0; i < masterList.size(); i++) {
			long startDate = masterList.get(i).getStartDate();
			long endDate = masterList.get(i).getEndDate();
			
			//print the data of the first event
			if (i == 0 || !DateUtils.isSameDay(new Date(startDate), new Date(oldStartDate))) {
				if (i > 0) {
					out.println("<br>");
				}
				// date format examples can be found at: http://java.sun.com/j2se/1.4.2/docs/api/java/text/SimpleDateFormat.html
				out.println("<b>" + DateFormatUtils.format(masterList.get(i).getStartDate(), "EEEE, MMM d") + "</b><br>");
			}

			// compare times
			if (DateUtils.addDays(new Date(startDate), 1).getTime() <= endDate) {
				// if it's an all day event
				out.println("&nbsp;All Day: <a href=\"" + masterList.get(i).getUrl() + "\">" + masterList.get(i).getTitle() + "</a><br>");
			} else {
				// if it's not an all day event
				out.println("&nbsp;" + DateFormatUtils.format(masterList.get(i).getStartDate(), "h:mm a") + ": <a href=\"" + masterList.get(i).getUrl() + "\" title=\"" + DateFormatUtils.format(masterList.get(i).getStartDate(), "h:mm a") + "-"
				+ DateFormatUtils.format(masterList.get(i).getEndDate(), "h:mm a") + "\">" + masterList.get(i).getTitle() + "</a><br>");
			}
			oldStartDate = startDate;
		}
	%>
	<p align="right"><a href="/bin/common/calendar.pl?location=mybb&subroutine=month&filter=showAll">more...</a></p>
</bbData:context>
