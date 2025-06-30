<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<html lang="fr">
    <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" href="include/css/simple.css" type="text/css" />
    </head>
    <body>
	<h2>Suppressions en session</h2>
	<%
	    System.out.println( "Removing session attributes..." );
	    session.removeAttribute("current.time");
	    session.removeAttribute("dev");
	    session.removeAttribute("qualification");
	%>
	<jsp:include page="WEB-INF/include/jsp/server-data.jsp" />
	<jsp:include page="WEB-INF/include/jsp/session-attrs.jsp" />
    </body>
</html>
