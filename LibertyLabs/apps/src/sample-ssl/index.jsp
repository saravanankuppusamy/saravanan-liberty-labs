<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Liberty runs each server with its output folder (usr/servers/<name>) as the working directory,
  // so the folder name tells us which server answered.
  String server = new java.io.File(".").getCanonicalFile().getName();
  Integer hits = (Integer) session.getAttribute("hits");
  hits = (hits == null) ? 1 : hits + 1;
  session.setAttribute("hits", hits);
  Runtime rt = Runtime.getRuntime();
  long usedMb = (rt.totalMemory() - rt.freeMemory()) / (1024 * 1024);
%>
<!DOCTYPE html>
<html><head><title>Liberty lab sample</title>
<style>body{font-family:Segoe UI,Arial,sans-serif;margin:2em;max-width:42em}
td{padding:.2em 1em .2em 0}.big{font-size:1.6em;font-weight:600}</style></head>
<body>
<p class="big">Served by <%= server %></p>
<table>
<tr><td>Port</td><td><%= request.getLocalPort() %> (<%= request.isSecure() ? "HTTPS" : "HTTP" %>)</td></tr>
<tr><td>Time</td><td><%= new java.util.Date() %></td></tr>
<tr><td>Session hits</td><td><%= hits %> (session <%= session.getId() %>)</td></tr>
<tr><td>Heap used</td><td><%= usedMb %> MB of <%= rt.maxMemory() / (1024 * 1024) %> MB max</td></tr>
</table>
<p>Lab helpers: <a href="load.jsp?ms=2000">load.jsp?ms=2000</a> (burn CPU),
<a href="slow.jsp?s=10">slow.jsp?s=10</a> (slow response),
<a href="leak.jsp?mb=20">leak.jsp?mb=20</a> (hold heap), <a href="leak.jsp?clear=1">leak.jsp?clear=1</a></p>
</body></html>
