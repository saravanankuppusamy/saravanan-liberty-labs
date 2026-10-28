WebSphere Liberty administration - 2-day class kit
=================================================

Unzip to C:\LibertyLabs on every classroom machine. Layout:

  scripts\   PowerShell setup scripts
      lab-env.ps1        EDIT FIRST: Java, Liberty, IHS and Plug-in paths; passwords
      lab00-check.ps1    run the day before class; every line should say PASS
      lab01-solve.ps1    does all of Lab 1 (run elevated - it registers a Windows service)
      labNN-start.ps1    puts a machine at the start of Lab NN (catch-up, or a clean restart)
      lab03-solve.ps1    builds the finished Lab 3 collective
      collective.ps1     shared collective/cluster helpers used by labs 3-7
      lab-stop-all.ps1   stops every lab server
      lab-reset-all.ps1  deletes every lab server so the machine can be reused
  apps\      sample.war, sample-ssl.war, payroll.war (+ src\ with the JSP source)
  labs\      per-lab helper files (Jython scripts, policies, templates, Dockerfile, LDIF)
  jython\    put jython-standalone-2.7.4.jar here (download from jython.org)
  work\      created by the labs (packages, reports, copies)

Run any script with:
  powershell -ExecutionPolicy Bypass -File C:\LibertyLabs\scripts\<script>.ps1

Labs 3-7: the controller starts and stops members over SSH, so install and start the Windows
OpenSSH Server (lab00-check prints the command). Scripts ask once for the Windows password of the
current user and never save it.

Ports used (one machine runs everything):
  labServer 9080/9443   controller 9180/9543   member1 9181/9544   member2 9182/9545
  member3 9183/9546     sslServer 9280/9643    cloudServer 9380/9743   payrollServer 9480/9843
  IHS 80                scaling host singleton 20020
Admin login everywhere: admin / adminpwd
