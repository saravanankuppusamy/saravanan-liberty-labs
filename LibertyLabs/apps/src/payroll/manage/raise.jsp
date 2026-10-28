<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html><head><title>Approve raise</title>
<style>body{font-family:Segoe UI,Arial,sans-serif;margin:2em}</style></head>
<body>
<h1>Raise approved</h1>
<p><b><%= request.getUserPrincipal().getName() %></b> is in the manager role, so this page opened.</p>
<p>A user who is only an employee gets HTTP 403 (Forbidden) here, not a login prompt:
Liberty knows who they are, they are just not allowed.</p>
<p><a href="../index.jsp">Back</a></p>
</body></html>
