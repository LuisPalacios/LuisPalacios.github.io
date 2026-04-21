---
title: "My First Steps with Docker"
date: "2014-11-01"
categories: ["notes"]
tags: ["docker","virtualization","containers"]
draft: false
cover:
  image: "/img/posts/logo-microservices1.svg"
  hidden: true
---

<img src="/img/posts/logo-microservices1.svg" alt="microservices logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

From what I understood, it's a tool that allows you to package "Linux applications and all their dependencies" into a self-contained virtual container (something like sandboxes). That doesn't tell us much, but what if I tell you that you can run your Linux applications (thanks to the Docker daemon) always in the same way on any platform? (for example Windows or macOS by using a super lightweight virtual machine, VirtualBox-style). Now that's cool.

<br clear="left"/>
<!--more-->

## Introduction

Platforms like Amazon EC, Google Cloud, Rackspace Cloud, etc. already support Docker containers, so things start getting interesting. In fact, there's more — Docker containers and everything being developed around them are accelerating at an impressive speed. This is not a Host Hypervisor like ESX, KVM, or Hyper-V tied to hardware with their virtual machines; instead, it's a virtualizer that runs containers with self-contained isolated applications almost anywhere, offering impressive IT flexibility and agility. If you have (Linux) applications, think about running them anywhere — hundreds of them per server, with impressive scalability.

It virtualizes the operating system by using *isolation* resources offered by the Linux Kernel and allows running "independent containers" within a single Linux instance. Note: it's neither a hypervisor nor does it run virtual machines. It relies on Linux kernel **namespaces**, which provide an isolated view of the environment where the application operates, including the process list, networking, user IDs, and mounted file systems. On the other hand, **cgroups** provide an isolated view of CPU, memory, I/O, and network resources.

Docker includes the **libcontainer** library as a reference implementation for containers. Its development is based on the **libvirt** library, LXC (Linux containers), and systemd-nspawn, which provide interfaces to access the various capabilities provided by the Linux kernel.

<br/>

### Installation on Linux

As always, I tested this on a Gentoo Linux host. Here are the kernel modifications:

```conf
# MANDATORY

CONFIG_NAMESPACES
CONFIG_NET_NS
CONFIG_PID_NS
CONFIG_IPC_NS
CONFIG_UTS_NS

CONFIG_DEVPTS_MULTIPLE_INSTANCES

CONFIG_CGROUPS
CONFIG_CGROUP_CPUACCT
CONFIG_CGROUP_DEVICE
CONFIG_CGROUP_FREEZER
CONFIG_CGROUP_SCHED

CONFIG_MACVLAN
CONFIG_VETH
CONFIG_BRIDGE
CONFIG_NF_NAT_IPV4
CONFIG_IP_NF_TARGET_MASQUERADE
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
CONFIG_NETFILTER_XT_MATCH_CONNTRACK
CONFIG_NF_NAT
CONFIG_NF_NAT_NEEDED

CONFIG_BLK_DEV_DM
CONFIG_DM_THIN_PROVISIONING

# OPTIONAL

CONFIG_MEMCG_SWAP
CONFIG_RESOURCE_COUNTERS
CONFIG_CGROUP_PERF

# File Systems

CONFIG_EXT4_FS_POSIX_ACL
CONFIG_EXT4_FS_SECURITY
```

I add the following to /etc/portage/accept_keywords

```conf
# Docker virtualizer
=app-emulation/docker-1.3.1 ~amd64
```

I install the program

```shell
totobo ~ # emerge -v app-emulation/docker
```

I add it to boot, add my user "luis" so he can control Docker, and start it

```shell
totobo ~ # rc-update add docker default
 * service docker added to runlevel default

totobo ~ # usermod -aG docker luis

totobo ~ # /etc/init.d/docker start
 * Caching service dependencies ... [ ok ]
 * /var/log/docker.log: creating file
 * /var/log/docker.log: correcting mode
 * /var/log/docker.log: correcting owner
 * Starting docker daemon ...
```

| **Note**: There are some things I didn't do that haven't affected me so far. I haven't enabled LVM — during the Docker installation its LVM dependency gets installed and it suggests adding lvm to the boot runlevel (rc-update add lvm boot) and enabling "lvmetad" in `/etc/lvm/lvm.conf` (if you want lvm autoactivation + metadata caching). I also haven't installed nor have systemd active: Docker says it has a dependency on systemd in its documentation |

<br/>

#### Installation on macOS

**The boot2docker installer**

- Creates a VirtualBox-based virtual machine
- Stored in /Users/luis/VirtualBox VMs (takes up 25MB)

The next step is to run Boot2Docker from Finder (Applications) **to start the daemon** — it opens Terminal.app and does the following:

```conf
- First time:
    - Creates ~/.boot2docker
    - Copies /usr/local/share/boot2docker/boot2docker.iso to ~/.boot2docker
- Runs:
    - /usr/local/bin/boot2docker init
        - First time creates public/private keys
    - /usr/local/bin/boot2docker up
    - $(/usr/local/bin/boot2docker shellinit)
```

<br/>

#### Running the first test container

I ran the same test on both machines — on Gentoo and on macOS (from the Terminal.app window it opens).

**Hello-World**

From the Gentoo shell or Terminal.app I run the same thing with the same result

$ docker run hello-world

- The Docker client contacts the Docker daemon
- The daemon downloads the "hello world" image because we didn't have it yet
- The daemon creates a new container from this image and runs it
- The daemon streams the "Hello from Docker." output to the client
- The client displays it on screen (our Terminal.app)

**Running Ubuntu**

The second test was more ambitious,

```shell
docker run -it ubuntu bash
```

The result is... spectacular — it downloads Ubuntu (~200MB), enters it, and it works :)
