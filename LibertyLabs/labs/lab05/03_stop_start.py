# 03_stop_start.py - Part 4: stop a member, wait until the controller reports it STOPPED, start it again.
#   jy.cmd 03_stop_start.py member2
import sys
import time
from labconnect import connect
import collective

target = len(sys.argv) > 1 and sys.argv[1] or "member2"
connector, mbsc = connect()

matches = [s for s in collective.list_servers(mbsc) if s[2] == target]
if not matches:
    print "No server named", target, "in the collective"; sys.exit(1)
host, user_dir, server = matches[0]

def wait_for(state, seconds=120):
    deadline = time.time() + seconds
    while time.time() < deadline:
        now = collective.status(mbsc, host, user_dir, server)
        print "   ", server, "is", now
        if now == state:
            return True
        time.sleep(5)
    return False

print "Stopping", server
print "   result:", collective.stop(mbsc, host, user_dir, server).get("returnCode")
wait_for("STOPPED")
print "Starting", server
print "   result:", collective.start(mbsc, host, user_dir, server).get("returnCode")
wait_for("STARTED")
connector.disconnect()
