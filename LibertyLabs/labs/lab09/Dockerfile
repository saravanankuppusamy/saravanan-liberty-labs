# Lab 9 - build a container image on IBM's WebSphere Liberty image.
#   docker build -t lab9-liberty .
#   docker run -d --name lab9 -p 9080:9080 lab9-liberty
#   docker run -d --name lab9b -p 9090:9090 -e HTTP_PORT=9090 lab9-liberty   (same image, new port)
#
# kernel = the smallest WebSphere Liberty runtime; features.sh adds only what server.xml lists.
FROM icr.io/appcafe/websphere-liberty:kernel-java17-openj9-ubi

# Configuration and application, owned by the non-root user (1001) the image runs as
COPY --chown=1001:0 server.xml /config/
COPY --chown=1001:0 sample.war /config/dropins/

# Install the features named in server.xml, then pre-warm caches for faster startup
RUN features.sh
RUN configure.sh
