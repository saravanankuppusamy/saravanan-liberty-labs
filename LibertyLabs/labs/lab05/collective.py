# collective.py - reads the collective repository: which hosts, user dirs and servers it knows.
#
# The repository is a tree. Members live at
#   /sys.was.collectives/local/hosts/<host>/userdirs/<url-encoded user dir>/servers/<server>
# getChildren(path) lists the nodes directly under a path.

import urllib
import jarray
import java
from labconnect import REPOSITORY, SERVER_COMMANDS

ROOT = "/sys.was.collectives/local/hosts"
STRING = "java.lang.String"

def _children(mbsc, path):
    names = mbsc.invoke(REPOSITORY, "getChildren",
                        jarray.array([path], java.lang.Object), jarray.array([STRING], java.lang.String))
    if names is None:
        return []
    # Depending on the release, children come back as full paths or as bare names; keep the last segment.
    return [str(n).rstrip("/").split("/")[-1] for n in names]

def list_servers(mbsc):
    """Yields (host, userDir, serverName) for every server in the collective repository."""
    for host in _children(mbsc, ROOT):
        for enc_dir in _children(mbsc, "%s/%s/userdirs" % (ROOT, host)):
            user_dir = urllib.unquote(enc_dir)
            for server in _children(mbsc, "%s/%s/userdirs/%s/servers" % (ROOT, host, enc_dir)):
                yield host, user_dir, server

def status(mbsc, host, user_dir, server):
    """STARTED, STOPPED or UNKNOWN, as the controller sees it."""
    return str(mbsc.invoke(SERVER_COMMANDS, "getServerStatus",
                           jarray.array([host, user_dir, server], java.lang.Object),
                           jarray.array([STRING, STRING, STRING], java.lang.String)))

def _command(mbsc, op, host, user_dir, server):
    result = mbsc.invoke(SERVER_COMMANDS, op,
                         jarray.array([host, user_dir, server], java.lang.Object),
                         jarray.array([STRING, STRING, STRING], java.lang.String))
    # The result is a Map; returnCode 0 means the command ran. stdout/stderr hold the command output.
    return dict((str(k), result.get(k)) for k in result.keySet())

def start(mbsc, host, user_dir, server):
    return _command(mbsc, "startServer", host, user_dir, server)

def stop(mbsc, host, user_dir, server):
    return _command(mbsc, "stopServer", host, user_dir, server)
