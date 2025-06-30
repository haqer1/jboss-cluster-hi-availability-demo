<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<table>
    <caption>Attributs session</caption>
    <tr>
	<th>Attribut(s)</th><th>Valeur(s)</th>
    </tr>
    <tr>
	<% System.out.println( "Getting date now" ); %>
	<td>(Date &amp;) Heure (de session)</td>
	<td class="value"><%= session.getAttribute("current.time") %></td>
    </tr>
    <tr>
	<td>Développeur &amp; qualification</td>
	<td class="value"><%= ((String)session.getAttribute("dev")) + ' '
		+ ((String)session.getAttribute("qualification")) %></td>
    </tr>
</table>
