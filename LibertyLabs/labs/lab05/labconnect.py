# labconnect.py - opens a JMX connection to the collective controller over the REST connector.
#
# Liberty has no wsadmin. Its remote management door is the JMX REST connector at
#   https://<controller>:<httpsPort>/IBMJMXConnectorREST
# and restConnector.jar (wlp\clients) is the client side of it. Liberty ships a Jython helper,
# restConnector.py (wlp\clients\jython), that wraps the connection; jy.cmd puts it on python.path.
#
# CLASSROOM SHORTCUT: the controller uses a certificate signed by the collective's own root, so we
# trust it without checking. In production, set JMXRESTConnector.trustStore to a truststore that
# holds the controller's signer instead (see connect_with_truststore below).

import java
import jarray
import javax
from javax.net.ssl import SSLContext, X509TrustManager
from com.ibm.websphere.jmx.connector.rest import ConnectorSettings
from restConnector import JMXRESTConnector
import labconfig

class _TrustEverything(X509TrustManager):
    def checkClientTrusted(self, chain, authType): pass
    def checkServerTrusted(self, chain, authType): pass
    def getAcceptedIssuers(self): return jarray.array([], java.security.cert.X509Certificate)

def connect():
    """Returns (connector, MBeanServerConnection). Call connector.disconnect() when done."""
    ctx = SSLContext.getInstance("TLS")
    ctx.init(None, [_TrustEverything()], None)
    env = java.util.HashMap()
    env.put("jmx.remote.provider.pkgs", "com.ibm.ws.jmx.connector.client")
    env.put(javax.management.remote.JMXConnector.CREDENTIALS,
            jarray.array([labconfig.ADMIN_USER, labconfig.ADMIN_PASSWORD], java.lang.String))
    env.put(ConnectorSettings.CUSTOM_SSLSOCKETFACTORY, ctx.getSocketFactory())
    env.put(ConnectorSettings.DISABLE_HOSTNAME_VERIFICATION, True)
    connector = JMXRESTConnector()
    connector.connect(labconfig.CONTROLLER_HOST, labconfig.CONTROLLER_PORT, env)
    return connector, connector.getMBeanServerConnection()

def connect_with_truststore(truststore, password):
    """The production pattern: trust only the signers in the given truststore."""
    JMXRESTConnector.trustStore = truststore
    JMXRESTConnector.trustStorePassword = password
    connector = JMXRESTConnector()
    connector.connect(labconfig.CONTROLLER_HOST, labconfig.CONTROLLER_PORT,
                      labconfig.ADMIN_USER, labconfig.ADMIN_PASSWORD)
    return connector, connector.getMBeanServerConnection()

# MBeans the Lab 5 scripts use (both run inside the controller)
REPOSITORY = javax.management.ObjectName(
    "WebSphere:feature=collectiveController,type=CollectiveRepository,name=CollectiveRepository")
SERVER_COMMANDS = javax.management.ObjectName(
    "WebSphere:feature=collectiveController,type=ServerCommands,name=ServerCommands")
