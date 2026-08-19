# Laboratorio multi-VM reproducible.
# Levanta 3 nodos Ubuntu 22.04 en red privada para practicar
# administración, troubleshooting y escenarios de falla.
#
#   vagrant up            → levanta todo
#   vagrant ssh app-01    → entra a un nodo
#   vagrant destroy -f    → borra todo sin dejar rastro

NODOS = [
  { nombre: "app-01",  ip: "192.168.56.11", ram: 1024, cpus: 1, rol: "app" },
  { nombre: "app-02",  ip: "192.168.56.12", ram: 1024, cpus: 1, rol: "app" },
  { nombre: "monitor", ip: "192.168.56.20", ram: 2048, cpus: 2, rol: "monitor" },
]

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_check_update = false

  NODOS.each do |nodo|
    config.vm.define nodo[:nombre] do |vm|
      vm.vm.hostname = nodo[:nombre]
      vm.vm.network "private_network", ip: nodo[:ip]

      vm.vm.provider "virtualbox" do |vb|
        vb.name   = "lab-#{nodo[:nombre]}"
        vb.memory = nodo[:ram]
        vb.cpus   = nodo[:cpus]
        # Sin GUI: el laboratorio se maneja por SSH
        vb.gui    = false
      end

      # Provisioning común a todos los nodos
      vm.vm.provision "shell",
        path: "scripts/bootstrap.sh",
        args: [nodo[:rol], nodo[:ip]]

      # El nodo monitor expone Grafana/Kibana al host si los instalás
      if nodo[:rol] == "monitor"
        vm.vm.network "forwarded_port", guest: 5601, host: 5601, auto_correct: true
        vm.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true
      end
    end
  end
end
