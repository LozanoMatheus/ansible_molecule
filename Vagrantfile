# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def provision_script_path(type)
  "./scripts/#{type}.sh"
end

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"

  config.vm.provision :shell do |vm|
    vm.name = 'Prereqs'
    vm.path = provision_script_path('prereqs')
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true

end
