# Auto-deploy for NGINX and PHP
This script allows you to configure NGINX and HTTPS with one command.

Features:
- NGINX configuration creation for current domain
- Obtaining a HTTPS Certificate (need Certbot)
- Сreating a directory for the site with configured rights

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
