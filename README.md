# Auto-deploy for NGINX, HTTPS and PHP
This script allows you to configure NGINX with PHP and HTTPS with one command.

Features:
- NGINX configuration creation for current domain
- Obtaining a HTTPS Certificate (need Certbot)
- Сreating a directory for the site with configured rights

### Make a file executable
```
chmod +x phpnginxdeploy.sh
```
### Default command
```
sudo ./phpnginxdeploy.sh domain.com 
```

### Deploy with custom config name for Nginx 
```
sudo ./phpnginxdeploy.sh domain.com configname
```

### Deploy with another PHP version
```
sudo ./phpnginxdeploy.sh domain.com configname 7.4
```
### To convert the line endings from DOS/Windows style to Unix style
```
sudo sudo apt-get install dos2unix
dos2unix phpnginxdeploy.sh
```
