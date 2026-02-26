### NEXUS + NGINX HTTPs Instalaltion
```
yum install nginx -y  
systemctl enable --now nginx
mkdir -p /etc/pki/nginx/  
mkdir -p /etc/pki/nginx/private/
```

#Backup conf file  
mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bak

#Update configuration HTTPS  

```
cat <<'EOF'>/etc/nginx/nginx.conf

# For more information on configuration, see:

# * Official English Documentation: http://nginx.org/en/docs/

# * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;  
worker_processes auto;  
error_log /var/log/nginx/error.log debug;  
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.

include /usr/share/nginx/modules/*.conf;

events {  
worker_connections 1024;  
}

http {  
log_format   main '$remote_addr - $remote_user [$time_local]  $status '
    '"$request" $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';

############

access_log  /var/log/nginx/access.log  main;

sendfile            on;
tcp_nopush          on;
tcp_nodelay         on;
keepalive_timeout   65;
types_hash_max_size 2048;
client_max_body_size 0;
include             /etc/nginx/mime.types;
default_type        application/octet-stream;

server {
    listen       5001 ssl http2 default_server;
    listen       [::]:5001 ssl http2 default_server;
    server_name  registry.demo.local;
    ssl_certificate "/etc/pki/nginx/domain.crt";
    ssl_certificate_key "/etc/pki/nginx/private/server.key";

    location / {
      proxy_pass http://registry.demo.local:5000/;
      proxy_set_header Host $http_host;
    }
}

################

}  
EOF

```

**configure selinux**
```bash
#selinux settings for nginx ports  
semanage port -a -t http_port_t -p tcp 5000  
semanage port -a -t http_port_t -p tcp 5001    
semanage port -m -t http_port_t -p tcp 5000  
semanage port -m -t http_port_t -p tcp 5001  

#check selinux configuration for nginx ports  
semanage port -l | grep http_port

#Set Boolean for httpd_can_network_connect  
setsebool -P httpd_can_network_connect 1
```

**configure certificate**
```bash
#Configure Certificates  
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/pki/nginx/private/server.key \
  -out /etc/pki/nginx/domain.crt \
  -subj "/CN=registry.demo.local" \
  -addext "subjectAltName=DNS:registry.demo.local,IP:192.168.154.12"

#Restart and check service  
sudo systemctl restart nginx  
sudo systemctl status nginx  

#Test https access and get error  
podman login -u admin -p redhat registry.demo.local:5001 
```

**trust self-signed certificate**
```bash
#Copy CRT file to ca-trust  
[root@helper ~]# openssl s_client -showcerts -connect registry.demo.local:5001 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/registry.demo.local:5001.crt

Connecting to 192.168.154.12
depth=0 CN=registry.demo.local
verify return:1
DONE

#update ca-trust  
[root@helper ~]#  update-ca-trust extract
```

**verify https access**
```bash
#Verify https access  
[root@helper ~]# podman login registry.demo.local:5001 -u admin -p redhat
Login Succeeded! 
```
