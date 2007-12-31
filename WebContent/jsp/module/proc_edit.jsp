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
 					blackboard.portal.servlet.*,
 					blackboard.platform.*,
					blackboard.data.user.*"
	errorPage="/error.jsp"%>

<%@ taglib uri="/bbUI" prefix="bbUI"%>
<%@ taglib uri="/bbData" prefix="bbData"%>
<bbData:context>
	<%
		if(null == request.getParameter("xmlFeed")){
			// don't think this should ever happen
			Module m = PortalUtil.getModule(pageContext);
			PortalRequestContext prc = PortalUtil.getPortalRequestContext(pageContext);
			PortalExtraInfo pei = PortalUtil.loadPortalExtraInfo(m.getId(), prc.getPortalViewerId());
			pei.getExtraInfo().setValue("CalendarData", null);
			PortalUtil.savePortalExtraInfo(pei);
		} else if ( request.getParameter("xmlFeed").equalsIgnoreCase("")){
			// reset the data to null (e.g.: if you want to remove the Google Calendar feed URL)
			Module m = PortalUtil.getModule(pageContext);
			PortalRequestContext prc = PortalUtil.getPortalRequestContext(pageContext);
			PortalExtraInfo pei = PortalUtil.loadPortalExtraInfo(m.getId(), prc.getPortalViewerId());
			pei.getExtraInfo().clearEntry("CalendarData");
			PortalUtil.savePortalExtraInfo(pei);
		}else{
			// save the good data
			if((request.getParameter("xmlFeed").startsWith("http://www.google.com/calendar/feeds/")) || (request.getParameter("xmlFeed").startsWith("https://www.google.com/calendar/feeds/")) ){
				Module m = PortalUtil.getModule(pageContext);
				PortalRequestContext prc = PortalUtil.getPortalRequestContext(pageContext);
				PortalExtraInfo pei = PortalUtil.loadPortalExtraInfo(m.getId(), prc.getPortalViewerId());
				pei.getExtraInfo().setValue("CalendarData", request.getParameter("xmlFeed")+"|"+ request.getParameter("timeZone") + "|" + request.getParameter("daysShown"));
				PortalUtil.savePortalExtraInfo(pei);
			}else{
				// send user back to entry page
				response.sendRedirect("edit.jsp?error=bad_url");
			}
		}
	%>
<bbUI:modulePersonalizationReceipt>
Google Calendar feed URL successfully saved
</bbUI:modulePersonalizationReceipt>
</bbData:context>
