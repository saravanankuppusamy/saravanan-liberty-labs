# 01_connect.py - Part 2: connect to the controller and prove it by reading one attribute.
import javax
from labconnect import connect

connector, mbsc = connect()
print "Connected. MBean count on the controller:", mbsc.getMBeanCount()
jvm = javax.management.ObjectName("WebSphere:type=JvmStats")
print "Controller heap used (bytes):", mbsc.getAttribute(jvm, "UsedMemory")
print "Controller uptime (ms):     ", mbsc.getAttribute(jvm, "UpTime")
connector.disconnect()
