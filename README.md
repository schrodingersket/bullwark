# Bullwark

Bullwark is a secure, IPSec-gated and scalable microservice discovery platform.
It provides decentralized and replicated configuration, as well as dynamic
reverse proxy services.

## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)

Tested with Vagrant 2.2.3 and VirtualBox 6.0.4r128164.

## Getting Started

### Create Virtual Machine cluster

To create the virtual machine cluster which represent service workers and
orchestrator, navigate to `./install/vagrant`, and run:

```bash
vagrant up --provision
```

This will bootstrap the orchestrator, which will then execute the Ansible
playbooks in this repository to create the VM cluster.

To SSH into any machine, execute:

```bash
vagrant ssh <machine name>
```

Alternatively, you can SSH without Vagrant by:

```bash
ssh vagrant@<machine ip>
```

The default password is `vagrant`.

The three machines which comprise the worker cluster out of the box are `bast`
(192.168.50.129), `kvothe` (192.168.50.130), and `chronicler` (192.168.50.131).

The orchestrator VM (`elodin`) can be found at 192.168.50.128.

### Ansible Development

If you're actively working on Ansible playbooks, you can re-run Ansible scripts
from the orchestrator (or your host machine, if you're running Linux/Mac).

First, synchronize your local work with the orchestrator VM 
(from `./install/vagrant`):

```bash
vagrant rsync elodin
```

Then, SSH into the orchestrator (from `./install/vagrant`):

```bash
vagrant ssh elodin
```

Then, navigate to `/bullwark/install/ansible`, and run:

```bash
./ansible.sh
```

If you're working on a particular playbook and have it tagged, you can restrict
execution to particular playbooks:

```bash
./ansible.sh --tags "set_hosts,common,ipsec"
```

Note that the `set_hosts` and `common` tags are always required, as they provide
common configuration for all other roles.

## IPSec Verification

To verify that IPSec is running, simply ping one machine from another. For
instance, from `bast`:

```bash
ping 192.168.50.130
```

Running `sudo ipsec whack --trafficstatus` from `kvothe` should yield something
like:

    006 #9: "private#192.168.50.0/24"[3] ...192.168.50.130, type=ESP, add_time=1544227420, inBytes=252, outBytes=252, id='192.168.50.130'

Anything running over IPSec should communicate over the 192.168.50.128/25 subnet 
(which is the only one on which the cluster can currently communicate).

That said, all ports are available for access by default from the host machine.
Nobody enjoys SSH tunnels that much during development.

## Adding Workers

To add workers beyond the two provided out of the box, simply add a new entry to
`./vagrant/servers.yml`. For instance, to add a new worker at 192.168.50.132 named
"new_worker", append the following to `servers.yml`:

```yaml
  - hostname: 'new_worker'
    ip: '192.168.50.132'
    ssh_ip: '192.168.50.132'
    ssh_port: '22'
```

Then, re-run `vagrant up --provision` and `ansible.sh` as specified in previous
sections.

## Salient UI Endpoints

- Consul Console (heh): http://machine_ip:8500/ui/
- Traefik Admin Panel: http://machine_ip:8080/dashboard/
- Traefik Service Route: http://machine_ip/<your application route>

## Registering a new Service

Once you've verified that everything is up and running, navigate to
`./install/ansible/roles/bullwark-registrar/files/bullwark-registrar`. From there, you can run the
following with the freshly compiled `bullwark-registrar` CLI to expose Traefik and
Consul's dashboards through Traefik:

```bash
./bin/bullwark-registrar --client \
                --config=./src/examples/register-consul-traefik.yml \
                --registrar-host=192.168.50.129
```

Note that since all configuration is clustered and decentralized, you can modify
`--registrar-host` to point to any virtual machine provisioned in the cluster to
the same effect.

This `./src/examples/register-consul-traefik.yml` serves as a canonical example
for how to dynamically register new services with the platform.

To verify, ensure that the following endpoints show up without errors:

- Consul Console: http://machine_ip/ui/
- Traefik Dashboard: http://machine_ip/dashboard/

## Moving Forward

Currently, the primary sandbox for this project consists of a network of VMs in
VirtualBox. The architecture of this project, however, is intentionally designed
to support deployments via Docker/Docker Compose/Kubernetes/Rancher/etc. To that
end, Ansible configuration in this repository is structured in such a way that
static configuration (i.e., installation of base packages, static config, etc.)
is performed in playbooks separate from dynamic configuration; currently, all
dynamic configuration is performed via environment variables provided to scripts
in the `vagrant` playbook. The overall structure of this playbook and its
execution is roughly in line with the `docker-entrypoint.d` initialization
architecture, but is done so in such a way as to be as friendly toward
containerized solutions and managed platform deployments as it is toward 
deployment to raw hardware resources. This encourages client applications to be
as platform-agnostic as possible, as customers may require a wide diversity of
deployment environments for applications build on top of the Bullwark
architecture.
