### 2.2 Install and Configure Load Balancer

#1. Install HAProxy packages**

```
sudo dnf install haproxy -y
```

#2. Set HAProxy configuration file**

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
global
  log         127.0.0.1 local2
  pidfile     /var/run/haproxy.pid
  maxconn     4000
  daemon
defaults
  mode                    http
  log                     global
  option                  dontlognull
  option http-server-close
  option                  redispatch
  retries                 3
  timeout http-request    10s
  timeout queue           1m
  timeout connect         10s
  timeout client          1m
  timeout server          1m
  timeout http-keep-alive 10s
  timeout check           10s
  maxconn                 3000

listen stats  
bind :9000  
mode http  
stats enable  
stats uri /  
stats refresh 10s

listen api-server-6443 
  bind *:6443
  mode tcp
  option  httpchk GET /readyz HTTP/1.0
  option  log-health-checks
  balance roundrobin
  server bootstrap bootstrap.ocp.demo.local:6443 verify none check check-ssl inter 10s fall 2 rise 3 backup 
  server master0 master0.ocp.demo.local:6443 weight 1 verify none check check-ssl inter 10s fall 2 rise 3
  server master1 master1.ocp.demo.local:6443 weight 1 verify none check check-ssl inter 10s fall 2 rise 3
  server master2 master2.ocp.demo.local:6443 weight 1 verify none check check-ssl inter 10s fall 2 rise 3

listen machine-config-server-22623 
  bind *:22623
  mode tcp
  server bootstrap bootstrap.ocp.demo.local:22623 check inter 1s backup 
  server master0 master0.ocp.demo.local:22623 check inter 1s
  server master1 master1.ocp.demo.local:22623 check inter 1s
  server master2 master2.ocp.demo.local:22623 check inter 1s

listen ingress-router-443 
  bind *:443
  mode tcp
  balance source
  server worker0 worker0.ocp.demo.local:443 check inter 1s
  server worker1 worker1.ocp.demo.local:443 check inter 1s
  server worker2 worker2.ocp.demo.local:443 check inter 1s
  server master0 master0.ocp.demo.local:443 check inter 1s
  server master1 master1.ocp.demo.local:443 check inter 1s
  server master2 master2.ocp.demo.local:443 check inter 1s

listen ingress-router-80 
  bind *:80
  mode tcp
  balance source
  server master0 master0.ocp.demo.local:80 check inter 1s
  server master1 master1.ocp.demo.local:80 check inter 1s
  server master2 master2.ocp.demo.local:80 check inter 1s
  server worker0 worker0.ocp.demo.local:80 check inter 1s
  server worker1 worker1.ocp.demo.local:80 check inter 1s
  server worker2 worker2.ocp.demo.local:80 check inter 1s
```

#1. Configure the firewall for HAProxy

```
sudo firewall-cmd --add-port=6443/tcp --zone=public --permanent
sudo firewall-cmd --add-port=22623/tcp --zone=public --permanent
sudo firewall-cmd --add-service=http --zone=public --permanent 
sudo firewall-cmd --add-service=http --zone=public --permanent
sudo firewall-cmd --add-service=https --zone=public --permanent
sudo firewall-cmd --add-service=https --zone=public --permanent
sudo firewall-cmd --add-port=9000/tcp --zone=public --permanent 
sudo firewall-cmd --reload
```

#1. Enable and start the HAProxy service
```
sudo setsebool -P haproxy_connect_any 1 
sudo systemctl enable haproxy
sudo systemctl start haproxy
sudo systemctl status haproxy --full --no-pager
```