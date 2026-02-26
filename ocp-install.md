## 4. Install and Configure OpenShift

> **Note:** Login to Helper Node

### 4.1 Install and Configure OpenShift

#1. Download packages

> **Note:** Download 4.19.10 packages as stated in ImageSetConfiguration file

#1. Create directories

```
WORKDIR=~/openshift
mkdir -p $WORKDIR/downloads
mkdir -p $WORKDIR/files
mkdir -p $WORKDIR/ocp
```

```
cd $WORKDIR/downloads
```

#1. Download oc and openshift-install

```
sudo yum install wget -y
```

```
wget openshift-install.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.10/openshift-install-linux.tar.gz
```

```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.10/openshift-client-linux-4.19.10.tar.gz
```

```
tar -zxvf openshift-client-linux-4.19.10.tar.gz
tar -zxvf openshift-install-linux.tar.gz
```

```
sudo mv oc kubectl openshift-install /usr/local/bin
```

```
oc version
```

#1. Create install-config.yaml

```
cd $WORKDIR/
```

```
cat << EOF > install-config.yaml
---
apiVersion: v1
baseDomain: demo.local 
compute:  
- hyperthreading: Enabled  
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ocp
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14 
    hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {} 
fips: false
pullSecret: '{"auths":{"registry.demo.local:8443":{"auth":".."}}}'  
sshKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNXjM7kT/f3cs9/uq/SbYmbk2qBpvFfZKjrnMDEtJ6PgUryCKCidc1n3EA0rMR7KZ73GZOxEh46xYcywZWwQfPqsUeLoJ6bpXSApK6uiM6kBa67dNVLmCSDQc1GNAwYl9SmnRA4IaCdegsVCwSZMmmxN+T3Gc95ARvij+ee1IpCl7l3/izfxF7DvXmQiFg4L/iMiKBm4hvLahm/rO3b/kU/A/xfl5Etc7wS56PRWG0QtLg9XJskpStzdM+eDS5WzFb/IKz1nEQo4s9RJm7vl6FDdkq3TznLUHKONcwOIVvbOG0MYbTs6gcjzoQR/tXxqeB8lN/POTGQcFOZL1wH/Nuiqnv1eSaX3W1imkblmcqVJm+1MTdFZcaGrZ/zgMEBVvr56ixJ/D+u0TBrae6poAV6wVcFN1mQfFkgm4xYkFUnGJ/ZC0BFjAfOewIjKGO8nbWwIMTKyEjGyHPNJsCwKIiXf+TjfZVtpTb5tIyRbrkLoT8qmQza/qKTAkpHGJW03U= root@centos-terminal'
#proxy:
#  httpProxy: http://192.168.1.36:3128/
#  httpsProxy: http://192.168.1.36:3128/
#  noProxy: .demo.local,192.168.152.0/24
additionalTrustBundle: |
  -----BEGIN CERTIFICATE-----
  MIID1jCCAr6gAwIBAgIUdHgb77jz5W3G6/Z3OfVfbc/WUakwDQYJKoZIhvcNAQEL
  BQAwajELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAlZBMREwDwYDVQQHDAhOZXcgWW9y
  azENMAsGA1UECgwEUXVheTERMA8GA1UECwwIRGl2aXNpb24xGTAXBgNVBAMMEHJl
  Z2lzdHJ5LnRzay5pbnQwHhcNMjUxMDIyMTQwNzQxWhcNMjgwODExMTQwNzQxWjBq
  MQswCQYDVQQGEwJVUzELMAkGA1UECAwCVkExETAPBgNVBAcMCE5ldyBZb3JrMQ0w
  CwYDVQQKDARRdWF5MREwDwYDVQQLDAhEaXZpc2lvbjEZMBcGA1UEAwwQcmVnaXN0
  cnkudHNrLmludDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALTstN7S
  GqtsEk0+lvRoXyHYE+6rwLNXX0eI5TltK2jo3ay0fCLWQU/NDMNpW/KlDQTOiYwG
  m9HvP1bLUM/wMFOfkisQeGU6Gx86BLRoJut1UuigkEFGiC+SLjQwZmG/ImAeGs1I
  +9bLR4mT4asciR7WuImneLZbiZl7bDwUgpBc8mz4SD69XKqYvJJ/5GB08yJJWa7i
  zPI+ZAavB3QLkm++Zn3Gj95Y1mFxhrkwULhKzMr44QI3+HDGdmRwIw2me3I5iMnr
  bYiRWIIXb/oLkGyKIY0RMWgANr6XhaF0hXFwEJGa5HaT1/LaDXLMX902aNXTKGE1
  vrF7CE19ngIhUOsCAwEAAaN0MHIwCwYDVR0PBAQDAgLkMBMGA1UdJQQMMAoGCCsG
  AQUFBwMBMBsGA1UdEQQUMBKCEHJlZ2lzdHJ5LnRzay5pbnQwEgYDVR0TAQH/BAgw
  BgEB/wIBATAdBgNVHQ4EFgQUsjvf48LtKEQnriXB9n3TRReyeoIwDQYJKoZIhvcN
  AQELBQADggEBAI/WvF7zLt8lV6MCtFQGrf9Othqypktdihx41PDvCZZflOcUvAUI
  y2F/+GuzgP7167se0SS9mVcphu8p2bcpv3oiZeWeI8Oauo4jN0JIZPBH9vpkQHPf
  eE9kYJ4Zj62DIxu97tEMydj2IiTYDQNIMFkEtycwQflBkxlYhPjjhP1j4UCyWNNj
  N3m8ddpfYhBYw0LWfn5HIx3d6WCIKwuXdFXhKqjwkyugtxy4XCS2MIwiVIorNL1d
  +ZypMO/uvX4x3s9nm5XXIwigjD2BrVpojfyH2S6wNoWAYabNxn1uKxVToHr5O29b
  0tHcM8Bgtx2IVpbXXsNnjUf3pj9gNKQbPJ4=
  -----END CERTIFICATE-----
imageDigestSources:
- mirrors:
  - registry.demo.local:8443/openshift/release
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
- mirrors:
  - registry.demo.local:8443/openshift/release-images
  source: quay.io/openshift-release-dev/ocp-release
imageContentSources:
- mirrors:
  - registry.demo.local:8443/openshift/release-images
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - registry.demo.local:84433/openshift/release
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
EOF
```

#2. create manifests
```
cp install-config.yaml ocp/install-config.yaml
openshift-install create manifests --dir ocp
```

#3. verify master schedulable is true 
```
cat ocp/manifests/cluster-scheduler-02-config.yml
```

#3. create ignition configs
```
openshift-install create ignition-configs --dir ocp
```
#4. move ignition configs to http
```
sudo scp ocp/bootstrap.ign root@192.168.1.38:/var/www/html/ocp4/.
sudo scp ocp/master.ign root@192.168.1.38:/var/www/html/ocp4/.
sudo scp ocp/worker.ign root@192.168.1.38:/var/www/html/ocp4/.
```

#1. list files on WEBSERVER
```
#run these commands on webserver
sudo chmod 755 -R /var/www/html/ocp4/
curl localhost:8080/ocp4/
```

#1. file download test on another server (registry)
```
[admin@registry ~]$ wget helper:8080/ocp4/worker.ign
--2025-10-20 21:27:52--  http://helper:8080/ocp4/worker.ign
Resolving helper (helper)... 192.168.1.36
Connecting to helper (helper)|192.168.1.36|:8080... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1714 (1.7K) [application/vnd.coreos.ignition+json]
Saving to: ‘worker.ign’

worker.ign          100%[===================>]   1.67K  --.-KB/s    in 0s      

2025-10-20 21:27:52 (103 MB/s) - ‘worker.ign’ saved [1714/1714]
```

#5. Download compatible rhcos image 
```
check the folder to get rhcos image 
https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/
```

```
https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.19/4.19.10/rhcos-4.19.10-x86_64-live-iso.isox86_64. 
```

#6. boot machines from iso and set temporary IP and run coreos installer

```
#bootstrap
#!/bin/bash
sudo coreos-installer install /dev/nvme0n1 --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/bootstrap.ign --append-karg=rd.neednet=1 --append-karg=ip=192.168.1.41::192.168.1.1:255.255.255.0:bootstrap.ocp.demo.local:ens5f1np1:none --append-karg=nameserver=10.0.60.9 --offline

#master0
#!/bin/bash
sudo coreos-installer install /dev/md/coreos --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/master.ign --append-karg=rd.neednet=1 --append-karg rd.md.uuid=c6487fbe:732e1cd7:289e6849:2dda154c --append-karg=bond=bond0:ens2f0np0,ens5f1np1:mode=802.3ad --append-karg=vlan=bond0.65:bond0 --append-karg=ip=192.168.1.20::192.168.1.1:255.255.255.0:master0.ocp.demo.local:bond0.65:none --append-karg=nameserver=10.0.60.9 --offline

#master1
#!/bin/bash
sudo coreos-installer install /dev/md/coreos --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/master.ign --append-karg=rd.neednet=1 --append-karg rd.md.uuid=d9826fbb:849e238b:c4942f13:d385b6e2  --append-karg=bond=bond0:ens2f0np0,ens5f1np1:mode=802.3ad --append-karg=vlan=bond0.65:bond0 --append-karg=ip=192.168.1.21::192.168.1.1:255.255.255.0:master1.ocp.demo.local:bond0.65:none --append-karg=nameserver=10.0.60.9 --offline

#master2
#!/bin/bash
sudo coreos-installer install /dev/md/coreos --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/master.ign --append-karg=rd.neednet=1 --append-karg rd.md.uuid=83235b6f:fb57b077:062a45ad:0ff3194d  --append-karg=bond=bond0:ens2f0np0,ens5f1np1:mode=802.3ad --append-karg=vlan=bond0.65:bond0 --append-karg=ip=192.168.1.22::192.168.1.1:255.255.255.0:master2.ocp.demo.local:bond0.65:none --append-karg=nameserver=10.0.60.9 --offline

#worker0 
#!/bin/bash
sudo coreos-installer install /dev/md/coreos --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/worker.ign --append-karg=rd.neednet=1 --append-karg rd.md.uuid=aed1200a:65565db5:380d617c:bcb3d439  --append-karg=bond=bond0:ens2f0np0,ens5f1np1:mode=802.3ad --append-karg=vlan=bond0.65:bond0 --append-karg=ip=192.168.1.23::192.168.1.1:255.255.255.0:worker0.ocp.demo.local:bond0.65:none --append-karg=nameserver=10.0.60.9 --offline

#worker1 
#!/bin/bash
sudo coreos-installer install /dev/md/coreos --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/worker.ign --append-karg=rd.neednet=1 --append-karg rd.md.uuid=b4c659f7:98c69f4d:a7724320:9227901e  --append-karg=bond=bond0:ens2f0np0,ens5f1np1:mode=802.3ad --append-karg=vlan=bond0.65:bond0 --append-karg=ip=192.168.1.24::192.168.1.1:255.255.255.0:worker1.ocp.demo.local:bond0.65:none --append-karg=nameserver=10.0.60.9 --offline

#worker2
#!/bin/bash
sudo coreos-installer install /dev/md/coreos --insecure-ignition --insecure --ignition-url=http://192.168.1.38:8080/ocp4/worker.ign --append-karg=rd.neednet=1 --append-karg rd.md.uuid=fedfff74:44286b29:1f4ae857:192a6399 --append-karg=bond=bond0:ens2f0np0,ens5f1np1:mode=802.3ad --append-karg=vlan=bond0.65:bond0 --append-karg=ip=192.168.1.25::192.168.1.1:255.255.255.0:worker2.ocp.demo.local:bond0.65:none --append-karg=nameserver=10.0.60.9 --offline

```

```
watch -n5 "oc get csr -o name | xargs oc adm certificate approve"
```