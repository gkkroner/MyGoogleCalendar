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
 <%@page import=	"blackboard.portal.data.*,
					blackboard.data.user.*,
					blackboard.portal.servlet.*"
	errorPage="/error.jsp"%>
<%@ taglib uri="/bbUI" prefix="bbUI"%>
<%@ taglib uri="/bbData" prefix="bbData"%>
<bbData:context>
	<%
		// if user is returned here for entering an incorrectly formatted URL
		String errorMsg = "";
		if(null != request.getParameter("error")){
			if(request.getParameter("error").equalsIgnoreCase("bad_url")){
				errorMsg = "Please enter a properly formatted Google Calendar feed URL";
			}
		}
		
		//load the existing portal module data
		Module m = PortalUtil.getModule(pageContext);
		PortalRequestContext prc = PortalUtil.getPortalRequestContext(pageContext);
		PortalExtraInfo pei = PortalUtil.loadPortalExtraInfo(m.getId(), prc.getPortalViewerId());
		User usr = bbContext.getUser();
		String data = pei.getExtraInfo().getValue("CalendarData");
		String xmlFeedUrl = "";
		if (data == null) {
			// nothing there
		}else{
			//data is stored FeedURL|TimeZoneOffset|DaysShown
			xmlFeedUrl = data.substring(0, data.indexOf("|"));
		}
	%>
<bbUI:modulePersonalizationPage>
<FORM method="post" action="proc_edit.jsp">
<bbUI:step title="Configure your Calendar" number="1">
<bbUI:instructions>Enter the URL of your Google Calendar XML feed. See <a href="http://www.google.com/support/calendar/bin/answer.py?answer=34576&hl=en" target="_blank">this link</a> for instructions on how to obtain this link. Then configure time zone and display settings.<br>
<font color="red"><%=errorMsg %></font><br>
</bbUI:instructions>
<bbUI:dataElement label="Feed URL">
<input type="text" name="xmlFeed" value="<%=xmlFeedUrl %>">
</bbUI:dataElement>
<bbUI:dataElement label="Time Zone">
<select id="timeZone" name="timeZone">
<option value="5" selected="selected">United States / Eastern</option>
<option value="6">United States / Central</option>
<option value="7">United States / Mountain</option>
<option value="8">United States / Pacific</option>
</select>
</bbUI:dataElement>
<bbUI:dataElement label="Show calendar events for:">
<select id="daysShown" name="daysShown">
<option value="1">Today</option>
<option value="7" selected="selected">Next 7 days</option>
<option value="30">Next 30 days</option>
</select>
</bbUI:dataElement>
</bbUI:step>
<bbUI:stepSubmit title="Submit" number="2" />
</FORM>
</bbUI:modulePersonalizationPage>
</bbData:context>
