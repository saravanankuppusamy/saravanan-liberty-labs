<%@ page contentType="text/plain; charset=UTF-8" %><%
  // Sleeps ?s= seconds (default 5, max 120) before answering. Used by Lab 7 health policies.
  int s = 5;
  try { s = Math.min(120, Integer.parseInt(request.getParameter("s"))); } catch (Exception e) { }
  Thread.sleep(s * 1000L);
  String server = new java.io.File(".").getCanonicalFile().getName();
%>answered after <%= s %> s from <%= server %>
