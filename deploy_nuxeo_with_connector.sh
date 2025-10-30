#!/usr/bin/env dash

curl "-u$NEXUS_USERNAME:$NEXUS_PASSWORD" https://packages.nuxeo.com/repository/maven-team-platform-private/org/nuxeo/ecm/distribution/nuxeo-server-tomcat/2023.0.159/nuxeo-server-tomcat-2023.0.159.zip -O
unzip nuxeo-server-tomcat-2023.0.159.zip
find ~/git/nuxeo-hxai-connector -type f -name "*package*zip"
nuxeoctl=./nuxeo-server-tomcat-2023.0.159/bin/nuxeoctl
chmod 744 nuxeoctl
nuxeoctl mp-install -y "$(find ~/git/nuxeo-hxai-connector -type f -name "*package*zip")"
yes | nuxeoctl mp-install "$(find ~/git/nuxeo-hxai-connector -type f -name "*package*zip")"
nuxeoctl console
