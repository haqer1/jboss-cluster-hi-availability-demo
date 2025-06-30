<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<table>
    <caption>Serveur</caption>
    <tr>
	<th>Adresse IP</th><th>Nom hôte</th>
    </tr>
    <tr>
	<td class="value"><%= request.getLocalAddr() %></td>
	<td class="value"><%= System.getenv("HOSTNAME") %></td>
    </tr>
</table>
