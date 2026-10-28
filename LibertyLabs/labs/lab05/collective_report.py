# collective_report.py - Part 5: the report script you keep.
# Writes a dated text report of every server: state, heap, CPU and uptime (for started servers),
# reading member metrics through the controller with a routing context.
#   jy.cmd collective_report.py            -> prints, and writes C:\LibertyLabs\work\collective-report-<date>.txt
import time
import java
import jarray
import javax
from labconnect import connect
import collective

ROUTING = javax.management.ObjectName(
    "WebSphere:feature=collectiveController,type=RoutingContext,name=RoutingContext")
JVM = javax.management.ObjectName("WebSphere:type=JvmStats")
STRING = "java.lang.String"

def member_metrics(host, user_dir, server):
    """Opens a fresh connection routed to one member and reads its JvmStats."""
    connector, conn = connect()
    try:
        ok = conn.invoke(ROUTING, "assignServerContext",
                         jarray.array([host, user_dir, server], java.lang.Object),
                         jarray.array([STRING, STRING, STRING], java.lang.String))
        if not ok:
            return None
        used = conn.getAttribute(JVM, "UsedMemory") / (1024.0 * 1024)
        cpu = conn.getAttribute(JVM, "ProcessCPU")
        up = conn.getAttribute(JVM, "UpTime") / 60000.0
        return used, cpu, up
    except Exception, e:
        return None
    finally:
        connector.disconnect()

lines = []
lines.append("Liberty collective report  " + time.strftime("%Y-%m-%d %H:%M:%S"))
lines.append("")
lines.append("%-12s %-9s %10s %7s %10s  %s" % ("SERVER", "STATE", "HEAP MB", "CPU %", "UP (min)", "USER DIR"))
connector, mbsc = connect()
counts = {}
for host, user_dir, server in collective.list_servers(mbsc):
    state = collective.status(mbsc, host, user_dir, server)
    counts[state] = counts.get(state, 0) + 1
    m = state == "STARTED" and member_metrics(host, user_dir, server) or None
    if m:
        lines.append("%-12s %-9s %10.1f %7.1f %10.1f  %s" % (server, state, m[0], m[1], m[2], user_dir))
    else:
        lines.append("%-12s %-9s %10s %7s %10s  %s" % (server, state, "-", "-", "-", user_dir))
connector.disconnect()
lines.append("")
lines.append("Totals: " + ", ".join(["%s %d" % (k, v) for k, v in sorted(counts.items())]))

text = "\n".join(lines)
print text
out = java.io.File("C:/LibertyLabs/work/collective-report-%s.txt" % time.strftime("%Y%m%d-%H%M"))
out.getParentFile().mkdirs()
w = java.io.FileWriter(out)
w.write(text + "\n")
w.close()
print "\nWritten to", out.getPath()
