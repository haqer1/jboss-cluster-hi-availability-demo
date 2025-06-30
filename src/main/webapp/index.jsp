<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<html lang="fr">
     <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" href="include/css/simple.css" type="text/css" />
     </head>
    <body>
	<h2>Exemple réplication (session) en contexte clustering (grappelage) sur JBoss WildFly</h2>
	<jsp:include page="WEB-INF/include/jsp/server-data.jsp" />
	<%
	    System.out.println( "Evaluating date now" );
	    java.util.Date date = new java.util.Date();
	%>
	<p lang="en">Hello! The time is now <%= date %>.</p>
	<p>
	    <a
href="put.jsp?dev=Resat&qualification=est%20très%20bon,%20y%20compris%20en%20clustering%20(grappelage)."
		>Mettre données</a>.
	    <a href="get.jsp">Lire données</a> (si vous voyez les données session mises auparavant
		sur un hôte différent <span class="important"
title="E. g., via curl 'http://172.17.0.1/jboss-cluster-ha-demo/get.jsp' -b 'JSESSIONID=vpxOMNg4cZaAQDEV9RSKZjTYeM77Y4qifSqiULoj.wild1'"
		>en utilisant le même identifiant
		session (JSESSIONID)</span>, cela signifie que réplication marche).
	    <a href="delete.jsp">Supprimer données</a>.
	</p>
    </body>
</html>
