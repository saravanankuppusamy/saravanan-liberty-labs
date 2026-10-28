# 02_list_servers.py - Part 3: every server the collective knows about, and its state.
from labconnect import connect
import collective

connector, mbsc = connect()
print "%-12s %-10s %s" % ("SERVER", "STATE", "USER DIR")
for host, user_dir, server in collective.list_servers(mbsc):
    print "%-12s %-10s %s" % (server, collective.status(mbsc, host, user_dir, server), user_dir)
connector.disconnect()
