<%@ page contentType="text/plain; charset=UTF-8" %><%
  // Keeps one CPU busy for ?ms= milliseconds (default 1000, max 30000). Used by Lab 7.
  long ms = 1000;
  try { ms = Math.min(30000, Long.parseLong(request.getParameter("ms"))); } catch (Exception e) { }
  long end = System.currentTimeMillis() + ms; double x = 0;
  while (System.currentTimeMillis() < end) { x += Math.sqrt(x + 1); }
  String server = new java.io.File(".").getCanonicalFile().getName();
%>burned <%= ms %> ms of CPU on <%= server %>
