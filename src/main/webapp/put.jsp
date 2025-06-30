<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<html lang="fr">
    <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" href="include/css/simple.css" type="text/css" />
    </head>
    <body>
	<h2>Assignations en session</h2>
	<%
	    System.out.println( "Putting date now" );
	    session.setAttribute("current.time", new java.util.Date());
	    String dev = request.getParameter("dev");
	    session.setAttribute("dev", dev);
	    session.setAttribute("qualification", request.getParameter("qualification"));
	%>
	<jsp:include page="WEB-INF/include/jsp/server-data.jsp" />
	<jsp:include page="WEB-INF/include/jsp/session-attrs.jsp" />
    </body>
</html>
