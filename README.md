# Vagrant Lab — Entorno de virtualización reproducible

Laboratorio multi-VM definido por código para practicar administración de Linux,
troubleshooting y escenarios de falla **sin tocar producción y sin miedo a romper nada**.

> Parte de mi ruta de especialización en SRE / DevOps.
> Contexto: vengo de gestión de incidentes críticos (P1/P2) en Fintech y Telco,
> y construyo estos entornos para practicar del lado de la prevención.

---

## El problema

En operaciones, la pregunta "¿qué pasa si este servicio se cae?" casi nunca se puede
responder probando. Producción no se toca, y armar un entorno de pruebas a mano
—instalar el SO, configurar la red, dejar las herramientas listas— toma horas y
termina siendo distinto cada vez que lo rehacés.

Sin un entorno descartable no hay forma de practicar la respuesta a incidentes.

## La solución

Infraestructura declarada en un `Vagrantfile`: tres nodos Ubuntu 22.04 en red privada,
con provisioning automatizado en Bash. El entorno completo se levanta con un comando,
se destruye con otro, y **siempre queda idéntico** porque está definido en código versionado.

```
┌─────────────────────────────────────────────────────┐
│  Host (Windows + VirtualBox)                        │
│                                                     │
│   ┌──────────┐  ┌──────────┐  ┌─────────────────┐   │
│   │  app-01  │  │  app-02  │  │     monitor     │   │
│   │ .56.11   │  │ .56.12   │  │    .56.20       │   │
│   │          │  │          │  │  Docker + 5601  │   │
│   └────┬─────┘  └────┬─────┘  └────────┬────────┘   │
│        └─────────────┴─────────────────┘            │
│              red privada 192.168.56.0/24            │
└─────────────────────────────────────────────────────┘
```

---

## Requisitos

- [VirtualBox](https://www.virtualbox.org/) 7.x
- [Vagrant](https://www.vagrantup.com/) 2.4+
- ~4 GB de RAM libres y ~10 GB de disco

## Cómo levantarlo

```bash
git clone https://github.com/seamnex/vagrant-lab.git
cd vagrant-lab

vagrant up                  # levanta los 3 nodos (primera vez: ~5-10 min)
vagrant status              # estado de cada VM
vagrant ssh app-01          # entrar a un nodo
vagrant destroy -f          # borrar todo
```

Comandos útiles durante el laboratorio:

```bash
vagrant reload app-01              # reiniciar un nodo
vagrant provision monitor          # re-ejecutar el provisioning
vagrant halt                       # apagar sin destruir
vagrant ssh app-01 -c "uptime"     # ejecutar un comando remoto
```

---

## Escenarios de falla para practicar

El valor del laboratorio no es levantarlo: es **romperlo a propósito** y medir cómo
te enterás y cuánto tardás en diagnosticarlo.

| # | Escenario | Cómo provocarlo | Qué observar |
|---|---|---|---|
| 1 | Nodo caído | `vagrant halt app-02` | ¿Cuánto tarda en detectarse desde `monitor`? |
| 2 | Disco lleno | `fallocate -l 8G /tmp/relleno` | Alertas de umbral, servicios que dejan de escribir |
| 3 | Saturación de CPU | `stress-ng --cpu 4 --timeout 300` | Load average, latencia de respuesta |
| 4 | Pérdida de red | `sudo ip link set eth1 down` | Timeouts vs. errores de conexión |
| 5 | Servicio muerto | `sudo systemctl stop <servicio>` | Diferencia entre "caído" y "no responde" |

Para cada escenario, el ejercicio real es cronometrar:
**tiempo hasta detectarlo (MTTD)** y **tiempo hasta diagnosticar la causa**.

---

## Bitácora de pruebas

<!-- COMPLETAR: llená esta tabla con tus corridas reales.
     No la publiques con datos inventados: el valor de esta sección
     es que sea evidencia verdadera de que corriste el laboratorio. -->

| Fecha | Escenario | MTTD | Cómo lo diagnostiqué | Aprendizaje |
|---|---|---|---|---|
| | | | | |

## Qué me llevo de este lab

<!-- COMPLETAR después de correrlo. Ideas para desarrollar:
     - Qué diferencia hay entre un nodo "caído" y uno "degradado"
       desde el punto de vista de quien monitorea.
     - Qué señal te habría avisado antes de que el servicio se cayera.
     - Qué parte del diagnóstico fue manual y podría automatizarse. -->

---

## Estructura

```
vagrant-lab/
├── Vagrantfile            # definición de los 3 nodos
├── scripts/
│   └── bootstrap.sh       # provisioning común (herramientas, hosts, timezone)
└── README.md
```

## Licencia

MIT
