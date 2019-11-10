#!/bin/sh
www_path="/var/www/"        # Путь до директории с виртуальными хостами
wwwuser="www-data"                
wwwgroup="www-data"
domain=""
confname=""
phpversion="7.3"
 
case "$@" in
    "")
        echo "Введите имя домена (as root)."
        ;;
    *)
        clear
        echo "Создаю директории сайта"
        mkdir -p $www_path$1/html/
        mkdir -p $www_path$1/log/
        echo "$www_path$1/html/"
        echo "$www_path$1/log/"
 
        echo "\nСоздаю index.php "
        echo "Hello World" > $www_path$1/html/index.php
        chown -R $wwwuser:$wwwgroup /$www_path$1
        chmod -R 0755 /$www_path$1
        
        domain=$1
   
		if [ -n "$2" ]
		then
		  confname=$2
		else
		   confname=$1
		fi
		
		
		if [ -n "$3" ]
		then
			phpversion=$3
		fi


        echo "\nДобавляю хост в: /etc/nginx/sites-available/$confname"
        exec 3>&1 1>/etc/nginx/sites-available/$confname
        echo "server {"
        echo "  charset utf-8;"
        echo "	"
		echo "	listen 80;"
		echo "	listen [::]:80;"
		echo "	"
		echo "	server_name $1;"
		echo "	"
		echo "	root $www_path$1/html;"
		echo "	index index.php index.html index.htm;"
		echo "	" 
		echo " 	location / {"
		echo "      try_files \$uri \$uri/ /index.php?\$args;"
		echo "	}"
		echo "	"
		echo " 	location ~ /\. {"
		echo "      deny all;"
		echo "	}"
		echo "	"
		echo "	error_page 404 /404.html;"
		echo "	error_page 500 502 503 504 /50x.html;"
		echo " 	location = /50x.html {"
		echo "      root /usr/share/nginx/html;"
		echo "	}"
		echo "	"
		echo " 	location ~ \.php$ {"
		echo "      include snippets/fastcgi-php.conf;"
		echo "      fastcgi_pass unix:/run/php/php$phpversion-fpm.sock;"
		echo "	}"
		echo "	"
		echo " 	location = /favicon.ico { log_not_found off; access_log off; }"
		echo " 	location = /robots.txt { log_not_found off; access_log off; allow all; }"
		echo " 	location ~* \.(?:ico|css|gif|jpe?g|js|png|svg|woff|woff2)$ {"
		echo "      expires max;"
		echo "      log_not_found off;"
		echo "	}"
		echo "	"
		echo " 	location ~* \.(ico)$ {"
		echo "      expires 240h;"
		echo "      log_not_found off;"
		echo "	}"
		echo "}"
        exec 1>&3
        
        echo "\nДобавляю ссылку на конфиг Nginx в: /etc/nginx/sites-enabled/$confname"
        sudo ln -s /etc/nginx/sites-available/$confname /etc/nginx/sites-enabled/

        sleep 1
        echo "Перезапускаю (reload) Nginx"
        sudo service nginx reload
        

		while true; do
		    read -p "Выпускаем HTTPS сетрификат? " yn
		    case $yn in
		        [Yy]* ) 
		            echo "Выпускаю  HTTPS сертифкат с помощью certbot"
		        	#sudo certbot --nginx -n -d $domain
		        	
		        	
        	     	echo "Обновляю конфиг Nginx. Редирект с www включён."
			        sudo rm /etc/nginx/sites-available/$confname
			        sudo rm /etc/nginx/sites-enabled/$confname
		        	
		      
		        	while true; do
					    read -p "Делаем редирект с www? " yn
					    case $yn in
					        [Yy]* ) 
	
					         	exec 3>&1 1>/etc/nginx/sites-available/$confname
					         	echo "#"
					         	echo "# Redirect all www to non-www"
					         	echo "#"
						        echo "server {"
						        echo "	server_name          www.$domain;"
						        echo "	listen               *:80;"
						        echo "	listen               *:443 ssl http2;"
						        echo "	listen               [::]:80;"
						        echo "	listen               [::]:443 ssl http2;"
						        echo "	ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;"
						        echo "	ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;"
						       	echo "	ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;"
						        echo "	include /etc/letsencrypt/options-ssl-nginx.conf;"
						        echo "	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
								echo "	return 301 https://$domain\$request_uri;"
								echo "}"
						 		exec 1>&3
						 
						 
					        	break;;
					        [Nn]* ) 
					        	break;;
					        * ) echo "Please answer yes or no.";;
					    esac
					done
					
					
					{
							echo "#"
				         	echo "# Redirect from HTTP to HTTPS"
				         	echo "#"		        
					        echo "server {"
					        echo "	server_name          $domain;"
					        echo "	listen               *:80;"
					        echo "	listen               [::]:80;"
					        echo "	return 301 https://$domain\$request_uri;"
					        echo "}"
							echo "	"
							echo "#"
				         	echo "#"
				         	echo "#"
					        echo "server {"
					        echo "  charset utf-8;"
					        echo "	server_name          $domain;"
					        echo "	listen               *:443 ssl http2;"
					        echo "	listen               [::]:443 ssl http2;"
					        echo "	ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;"
					        echo "	ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;"
					       	echo "	ssl_trusted_certificate /etc/letsencrypt/live/$domain/chain.pem;"
					        echo "	include /etc/letsencrypt/options-ssl-nginx.conf;"
					        echo "	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"
							echo "	"
							echo "	root $www_path$domain/html;"
							echo "	index index.php index.html index.htm;"
							echo "	" 
							echo " 	location / {"
							echo "      try_files \$uri \$uri/ /index.php?\$args;"
							echo "	}"
							echo "	"
							echo " 	location ~ /\. {"
							echo "      deny all;"
							echo "	}"
							echo "	"
							echo "	error_page 404 /404.html;"
							echo "	error_page 500 502 503 504 /50x.html;"
							echo " 	location = /50x.html {"
							echo "      root /usr/share/nginx/html;"
							echo "	}"
							echo "	"
							echo " 	location ~ \.php$ {"
							echo "      include snippets/fastcgi-php.conf;"
							echo "      fastcgi_pass unix:/run/php/php$phpversion-fpm.sock;"
							echo "	}"
							echo "	"
							echo " 	location = /favicon.ico { log_not_found off; access_log off; }"
							echo " 	location = /robots.txt { log_not_found off; access_log off; allow all; }"
							echo " 	location ~* \.(?:ico|css|gif|jpe?g|js|png|svg|woff|woff2)$ {"
							echo "      expires max;"
							echo "      log_not_found off;"
							echo "	}"
							echo "	"
							echo " 	location ~* \.(ico)$ {"
							echo "      expires 240h;"
							echo "      log_not_found off;"
							echo "	}"
							echo "}"
					} >> /etc/nginx/sites-available/$confname

					
					
					sudo ln -s /etc/nginx/sites-available/$confname /etc/nginx/sites-enabled/

			        sleep 1
			        echo "Перезапускаю (reload) Nginx"
			        sudo service nginx reload
								
		        	break;;
		        [Nn]* ) 
		        	break;;
		        * ) echo "Please answer yes or no.";;
		    esac
		done
		

        echo "Всё готово"
        echo "Теперь вы можете перейти по адресу http://$domain"
        ;;
esac
