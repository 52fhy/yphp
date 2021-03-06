#!/bin/bash

# 基于镜像 php71-fpm-centos68-phalcon-withext

# 备用
#docker exec -it $(docker ps | grep 'phalcon-withext' | awk '{print $1}') /bin/bash
#docker stop $(docker ps | grep 'phalcon-withext' | awk '{print $1}') 
#docker rm $(docker ps | grep 'phalcon-withext' | awk '{print $1}') 
#docker start $(docker ps | grep 'phalcon-withext' | awk '{print $1}')

#docker ps -a | awk '{print $1}' |xargs docker stop
#docker ps -a | awk '{print $1}' |xargs docker rm

cid=$(docker ps | grep 'phalcon-withext' | awk '{print $1}') 
ip=$($(which ifconfig) -a|grep inet|grep -v 127.0.0.1|grep -v inet6 | awk '{print $2}' | tr -d "addr:"|tail -1)


function init(){
	docker run -d --restart=always --name ysphp  -p 80:80 \
	 -v /work/:/work/  \
	 -v "/work/yphp/php/etc/php.ini":/usr/local/php/etc/php.ini  \
	 -v "/work/yphp/php/etc/php-fpm.d/www.conf":/usr/local/php/etc/php-fpm.d/www.conf  \
	 -v "/work/yphp/nginx/conf/nginx.conf":/usr/local/nginx/conf/nginx.conf  \
	 -v "/work/yphp/nginx/conf/vhost/":/usr/local/nginx/conf/vhost/  \
	 -v "/work/yphp/nginx/logs/":/usr/local/nginx/logs/  \
	 php71-fpm-centos68-phalcon-withext && docker ps -a

	echo "Installation success, enjoy yourself!"
	echo "open demo: http://$ip:8082"
}

function ps_a(){
	docker ps -a
	docker exec -it $cid  ps -ef
}

function ssh(){
	docker exec -it $cid  /bin/bash
}

function rm_a(){
	docker stop $cid 
	docker rm $cid
}

function rm_all(){
	docker ps -a | awk '{print $1}' |xargs docker stop
	docker ps -a | awk '{print $1}' |xargs docker rm 
}

function nginx_reload(){
	docker exec -it $cid nginx -s reload
}

function nginx_t(){
	docker exec -it $cid nginx -t
}

function php_m(){
	docker exec -it $cid php -m
}

function ip(){
	echo $ip
}

case $1 in
    "init") init;nginx_t;;
    "ps") ps_a;;
    "ssh") ssh;;
    "rm") rm_a;;
    "rm_all") rm_all;;
    "nginx_reload") nginx_reload;;
    "nginx_t") nginx_t;;
    "php_m") php_m;;
    "ip") ip;;
    *) echo "Usage: `basename $0` init | ps | ssh | rm | rm_all | nginx_reload | php_m | ip";;
esac