#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'

# configure to your liking

ROOT				=	File.expand_path(File.dirname(__FILE__))
WORKSPACE		=	File.join(ROOT, 'workspace')
CHECKOUT		=	File.join(ROOT, 'checkout')
INSTALL_DIR	=	File.join(ROOT, 'eclipse')
INSTALL_CMD	=	File.join(ROOT, 'director', 'director') + " -destination #{INSTALL_DIR} -profile Elexis "
REPOS = {
  'http://download.eclipse.org/releases/kepler' => ['epp.package.rcp',
                                                    'org.eclipse.egit.feature.group',
                                                    'org.eclipse.mylyn.wikitext_feature.feature.group',
                                                   ],
  'http://jeeeyul.github.io/update' => ['net.jeeeyul.pdetools.feature.feature.group',],
  'http://repo1.maven.org/maven2/.m2e/connectors/m2eclipse-tycho/0.7.0/N/0.7.0.201309291400' => ['org.sonatype.tycho.m2e.feature.feature.group'],
  'http://download.eclipse.org/technology/m2e/releases' => ['org.eclipse.m2e.sdk.feature.feature.group'],
  'https://raw.github.com/inventage/version-tiger-repos/master/releases' =>['com.inventage.tools.versiontiger'],
  'http://www.wdev91.com/update' =>['com.wdev91.eclipse.copyright'],
  'http://workspacemechanic.eclipselabs.org.codespot.com/git.update/mechanic' =>['com.google.eclipse.mechanic/0.3.4'],
  }

JINTO_VERS = '0.13.5'

# end of configuration section

puts "#{Time.now}: Using #{CHECKOUT}/director, #{CHECKOUT} and #{INSTALL_DIR} to install #{REPOS.keys}"
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
	res = open(url) {
		|f|
		File.open(File.basename(url), 'w+') { |outfile| outfile.write f.read }
	}
	puts "dest ist #{dest} size #{File.size(dest)} from url #{url}"
	res
end

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
	exit 1 unless system("#{INSTALL_CMD} -repository #{REPOS.keys.join(',')} -installIUs #{REPOS.values.join(',')}")
end

unless File.exists?(File.join(INSTALL_DIR, 'plugins', "de.guhsoft.jinto.core_#{JINTO_VERS}.jar"))
	Dir.chdir(INSTALL_DIR)
	FileUtils.rm_f("de.guhsoft.jinto-*.zip*")
	exit 1 unless get_file_from_url("http://www.guh-software.de/jinto/de.guhsoft.jinto-#{JINTO_VERS}.zip")
  exit 1 unless system("unzip de.guhsoft.jinto-#{JINTO_VERS}.zip")
end if JINTO_VERS
puts "#{Time.now}: finished installing #{REPOS.keys} into #{CHECKOUT}/director, #{CHECKOUT} and #{INSTALL_DIR}"
system("#{INSTALL_DIR}/eclipse -data #{WORKSPACE} &")
