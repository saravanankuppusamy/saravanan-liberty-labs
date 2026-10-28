<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html><head><title>Payroll</title>
<style>body{font-family:Segoe UI,Arial,sans-serif;margin:2em;max-width:42em}td{padding:.2em 1em .2em 0}</style></head>
<body>
<h1>Payroll</h1>
<table>
<tr><td>Signed in as</td><td><b><%= request.getUserPrincipal() == null ? "(nobody)" : request.getUserPrincipal().getName() %></b></td></tr>
<tr><td>In role employee?</td><td><%= request.isUserInRole("employee") %></td></tr>
<tr><td>In role manager?</td><td><%= request.isUserInRole("manager") %></td></tr>
</table>
<h2>This month</h2>
<table>
<tr><td>Alice Ng</td><td>Engineering</td><td>$8,200</td></tr>
<tr><td>Bob Ortiz</td><td>Finance</td><td>$7,450</td></tr>
<tr><td>Carol Price</td><td>Support</td><td>$5,900</td></tr>
</table>
<p><a href="manage/raise.jsp">Approve a raise</a> (managers only)</p>
<p>To sign in as someone else, close every browser window (BASIC auth is cached by the browser) or use a private window.</p>
</body></html>
