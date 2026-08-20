# Laboratorio multi-VM reproducible.
# Levanta 3 nodos Ubuntu 22.04 en red privada para practicar
# administración, troubleshooting y escenarios de falla.
#
#   vagrant up            → levanta todo
#   vagrant ssh app-01    → entra a un nodo
#   vagrant destroy -f    → borra todo sin dejar rastro
#
# Aprovisionamiento con Ansible (opcional, ver ansible/playbook.yml):
#
#   ANSIBLE=1 vagrant up              → bootstrap.sh + playbook
#   ANSIBLE=1 vagrant provision       → re-ejecutar solo el provisioning
#
# Va detrás de una variable de entorno a propósito: `ansible_local` instala
# Ansible dentro de cada VM y eso suma varios minutos al primer `vagrant up`.
# El default queda rápido; el playbook se pide cuando se lo quiere.

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

      # Aprovisionamiento declarativo. Corre DENTRO de la VM (`ansible_local`)
      # porque el host es Windows y Ansible no tiene soporte nativo ahí:
      # exigir WSL solo para levantar el lab rompería la reproducibilidad
      # que es el punto del laboratorio.
      if ENV["ANSIBLE"]
        vm.vm.provision "ansible_local" do |ansible|
          ansible.playbook       = "ansible/playbook.yml"
          ansible.compatibility_mode = "2.0"
          # Vagrant limita la ejecución a la VM actual, así que los grupos
          # tienen que declararse igual para que cada play matchee su rol.
          # El grupo se llama `monitoreo` y no `monitor` para no colisionar
          # con el host homónimo, que vuelve ambiguo el `hosts:` del playbook.
          ansible.groups = {
            "app"       => ["app-01", "app-02"],
            "monitoreo" => ["monitor"],
          }
        end
      end

      # El nodo monitor expone Grafana/Kibana al host si los instalás
      if nodo[:rol] == "monitor"
        vm.vm.network "forwarded_port", guest: 5601, host: 5601, auto_correct: true
        vm.vm.network "forwarded_port", guest: 3000, host: 3000, auto_correct: true
      end
    end
  end
end
