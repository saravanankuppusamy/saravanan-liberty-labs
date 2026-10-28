<%@ page contentType="text/plain; charset=UTF-8" %><%
  // Holds ?mb= megabytes of heap until ?clear=1 or the server restarts. Used by Lab 7.
  @SuppressWarnings("unchecked")
  java.util.List<byte[]> hold = (java.util.List<byte[]>) application.getAttribute("leak");
  if (hold == null) { hold = java.util.Collections.synchronizedList(new java.util.ArrayList<byte[]>()); application.setAttribute("leak", hold); }
  if (request.getParameter("clear") != null) { hold.clear(); }
  else {
    int mb = 10;
    try { mb = Math.min(200, Integer.parseInt(request.getParameter("mb"))); } catch (Exception e) { }
    for (int i = 0; i < mb; i++) { hold.add(new byte[1024 * 1024]); }
  }
  String server = new java.io.File(".").getCanonicalFile().getName();
%>holding <%= hold.size() %> MB on <%= server %>
