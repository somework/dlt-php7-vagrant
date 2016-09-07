require 'json'
require 'yaml'

VAGRANTFILE_API_VERSION = "2"

php7devYamlPath = File.expand_path("./php7dev.yaml")
afterScriptPath = File.expand_path("./scripts/customize.sh")
aliasesPath = File.expand_path("./aliases")
# diffPath = File.expand_path("./php7dev.diff")

require_relative 'scripts/php7dev.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
	if File.exists? aliasesPath then
		config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
	end

	Php7dev.configure(config, YAML::load(File.read(php7devYamlPath)))

	if File.exists? afterScriptPath then
		config.vm.provision "shell", path: afterScriptPath
	end
end
