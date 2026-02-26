### 2.3 Install and Configure HTTP

#**1. **

```
sudo dnf install httpd -y
```

#**1. Change default listen port to 8080 in httpd.conf**

```
sudo sed -i 's/Listen 80/Listen 0.0.0.0:8080/' /etc/httpd/conf/httpd.conf
```

#**2. Configure the firewall for Web Server traffic**
```
sudo firewall-cmd --add-port=8080/tcp --zone=public --permanent
sudo firewall-cmd --reload
```

#**3. Enable and start the service**
```
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl status httpd --full --no-pager
```

#**Change ownership and permissions of the web server directory**
```

sudo mkdir /var/www/html/ocp4
sudo chcon -R -t httpd_sys_content_t /var/www/html/ocp4/
sudo chown -R apache: /var/www/html/ocp4/
sudo chmod 755 /var/www/html/ocp4/
```
#Confirm you can see all files added to the /var/www/html/ocp4/ dir through Apache
```
sudo curl localhost:8080/ocp4/
```