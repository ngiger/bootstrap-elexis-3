#!/bin/bash -v
# Installs the snapshot of the Elexis3 application including some often used features
# into elexis_3_demo
wget http://mirror.switch.ch/eclipse/tools/buckminster/products/director_latest.zip
unzip -u director_latest.zip
director/director \
-destination elexis_3_demo \
-application org.eclipse.equinox.p2.director \
-application org.eclipse.equinox.p2.director \
-repository http://download.elexis.info/elexis.3.core/snapshot/ \
-r http://download.elexis.info/elexis.3.base/snapshot/ \
-tag AutomatedInstall \
-profile Elexis \
-profileProperties org.eclipse.update.install.features=true \
-p2.os linux -p2.ws gtk -p2.arch x86_64 \
-roaming \
-installIUs ch.elexis.core.application \
-i ch.elexis.core.application.ElexisApp \
-i ch.elexis.core.logging.feature.feature.group \
-i org.eclipse.swt.gtk.linux.x86_64 \
-i ch.elexis.core.application.ElexisApp.executable.gtk.linux.x86_64.Elexis3 \
-i ch.elexis.base.ch.feature.feature.group \
-i org.iatrix.feature.feature.group \
-i ch.elexis.omnivore.feature.feature.group \
-i ch.elexis.base.ch.legacy.feature.feature.group \
-i com.hilotec.elexis.opendocument.feature.feature.group \
-i com.hilotec.elexis.kgview.feature.feature.group \
-i com.hilotec.elexis.messwerte.v2.feature.feature.group \
-i ch.elexis.agenda.feature.feature.group
