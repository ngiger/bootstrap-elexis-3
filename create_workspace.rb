#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'

# configure to your liking

ROOT				=	File.expand_path(File.dirname(__FILE__))
CHECKOUT		=	File.join(ROOT, 'checkout')
ANT4ECLIPSE	=	File.join(ROOT, 'ant4eclipse')
INSTALL_DIR	=	File.join(ROOT, 'eclipse')
WORKSPACE		=	File.join(ROOT, 'workspace')
INSTALL_CMD	=	File.join(ROOT, 'director', 'director') + " -destination #{INSTALL_DIR} -profile Elexis "
IUS="epp.package.rcp,com.inventage.tools.versiontiger,org.eclipse.m2e.sdk.feature.feature.group,com.wdev91.eclipse.copyright,com.google.eclipse.mechanic/0.3.4"
REPOS="http://download.eclipse.org/releases/kepler,http://download.eclipse.org/technology/m2e/releases,https://raw.github.com/inventage/version-tiger-repos/master/releases,http://www.wdev91.com/update,http://workspacemechanic.eclipselabs.org.codespot.com/git.update/mechanic"
JINTO_VERS = '0.13.5'

# end of configuration section

puts "#{Time.now}: Using #{CHECKOUT}/director, #{CHECKOUT} and #{INSTALL_DIR} to install #{IUS}"
def system(cmd)
	puts "#{Time.now}: running #{cmd}"
	res = Kernel.system(cmd)
	unless res
		puts "#{Time.now}: FAILED running #{cmd}"
		exit 1
	end
	res
end

def get_file_from_url(url, dest= File.basename(url))
	open(url) {
		|f|
		File.open(File.basename(url), 'w+') { |outfile| outfile.write f.read }
	}
	puts "dest ist #{dest} size #{File.size(dest)} from url #{url}"
end

# get_file_from_url("https://sourceforge.net/projects/ant4eclipse/files/latest/download?source=files","org.ant4eclipse.tar.gz")
FileUtils.makedirs(WORKSPACE)
FileUtils.makedirs(ANT4ECLIPSE)
Dir.chdir(ANT4ECLIPSE)
zip_pattern="org.ant4eclipse_1.0.0.M4.zip"
unless Dir.glob(zip_pattern).size > 0
	get_file_from_url("http://freefr.dl.sourceforge.net/project/ant4eclipse/ant4eclipse/1.0.0.M4/#{zip_pattern}")
	puts Dir.pwd
	puts "Found "+ Dir.glob("*").to_s
	puts Dir.glob(zip_pattern)
	system("unzip #{zip_pattern}")
	puts "Found "+ Dir.glob("*").to_s
	puts Dir.glob('*.jar')
	system("unzip -u #{zip_pattern.sub('.zip', '.jar')}")
end
# system("ant -lib #{Dir.glob("org.ant4eclipse*.jar")[1]}")

exit 0
ant4eclipse = "https://downloads.sourceforge.net/project/ant4eclipse/ant4eclipse/1.0.0.M4/org.ant4eclipse_1.0.0.M4.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fant4eclipse%2Ffiles%2Fant4eclipse%2F&ts=1393614569&use_mirror=freefr"
build_xml_for_ant = %(
<?xml version="1.0"?>
<project name="build.ant4eclipse"
         basedir="."
         default="build"
         xmlns:ant4eclipse="antlib:org.ant4eclipse">

	<!-- define ant4eclipse tasks -->
	<taskdef uri="antlib:org.ant4eclipse" resource="org/ant4eclipse/antlib.xml" />

	<!-- import the ant4eclipse pde macros -->
	<import file="${basedir}/ant4eclipse/macros/a4e-pde-macros.xml" />

	<!-- define the workspace location here -->
	<property name="workspaceDirectory" value="${basedir}/workspace" />
	<echo message="basedir is ${basedir}" />
	<echo message="workspaceDirectory is ${workspaceDirectory}" />
 <ant4eclipse:workspaceDefinition id="myWorkspace">
		<dirset dir=" ${basedir}/checkout">
      <include name="**"/>
    </dirset>
  </ant4eclipse:workspaceDefinition>

  	<!-- =================================
          target: build
         ================================= -->
	<target name="build">

		<!-- iterate over all projects in the workspace -->
		<ant4eclipse:executeProjectSet workspaceDirectory="${workspaceDirectory}"
		                               allWorkspaceProjects="true">

			<!-- execute the contained build steps for all plug-in projects -->
			<ant4eclipse:forEachProject filter="(executeProjectSet.org.eclipse.pde.PluginNature=*)">

				<!--call the build plug-in project -->
				<buildPlugin workspaceDirectory="${workspaceDirectory}"
				             projectname="${executeProjectSet.project.name}"
				             targetplatformid="my.target.platform"
				             destination="${basedir}/destination" />

			</ant4eclipse:forEachProject>

		</ant4eclipse:executeProjectSet>

	</target>

</project>
)
exit

unless File.directory?(File.join(ROOT, 'director'))
	Dir.chdir(ROOT)
	FileUtils.rm_rf(["director", "director*.zip"])
	exit 1 unless get_file_from_url("http://mirror.switch.ch/eclipse/tools/buckminster/products/director_latest.zip")
	exit 1 unless system("unzip director_latest.zip")
end

FileUtils.makedirs(CHECKOUT)
['elexis-3-base', 'elexis-3-core'].each {
	|project|
	unless File.directory?(File.join(CHECKOUT, project))
		exit 1 unless system("git clone https://github.com/elexis/#{project}.git #{File.join(CHECKOUT, project)}")
	end
}

mech_dest  = File.join('~', '.eclipse', 'mechanic')
mech_tasks = Dir.glob(File.join(ROOT, 'mechanic', '*.epf'))
FileUtils.makedirs(mech_dest)
FileUtils.cp(mech_tasks, mech_dest, :verbose => true, :preserve => true) unless FileUtils.uptodate?(mech_dest, mech_tasks)

unless File.directory?(INSTALL_DIR)
	exit 1 unless system("#{INSTALL_CMD} -repository #{REPOS} -installIUs #{IUS}")
end

unless File.exists?(File.join(INSTALL_DIR, 'plugins', "de.guhsoft.jinto.core_#{JINTO_VERS}.jar"))
	Dir.chdir(INSTALL_DIR)
	FileUtils.rm_f("de.guhsoft.jinto-*.zip*")
	exit 1 unless get_file_from_url("http://www.guh-software.de/jinto/de.guhsoft.jinto-#{JINTO_VERS}.zip")
  exit 1 unless system("unzip de.guhsoft.jinto-#{JINTO_VERS}.zip")
end if JINTO_VERS
puts "#{Time.now}: finished installing #{IUS} into #{CHECKOUT}/director, #{CHECKOUT} and #{INSTALL_DIR}"

he definitions in the namespace antlib:org.ant4eclipse are:
    patchFeatureManifest
    executeBuildCommands
    executeTeamProjectSet
    getPythonPath
    executeProduct
    linkedResourceVariable
    executePluginLibrary
    antCall
    checkPluginProject
    userLibraries
    getJdtSourcePath
    executePluginProject
    executeProjectSet
    echoReference
    pythonContainer
    pdeProjectFileSet
    getUsedProjects
    cvsGetProjectSet
    jdtClassPathLibrary
    targetPlatform
    executeFeature
    hasBuildCommand
    getJdtOutputPath
    executeJdtProject
    pythonDoc
    jdtProjectFileSet
    executeEquinoxLauncher
    getJdtClassPath
    hasNature
    getRequiredBundles
    executeLauncher
    jdtClassPathVariable
    platformConfiguration
    getPythonSourcePath
    svnGetProjectSet
    getProjectDirectory
    getBuildOrder
    installedJREs
    queryProduct
