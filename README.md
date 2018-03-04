# yphp

该项目包含两部分：
- 标准配置文件(php,nginx)
- yphp脚本

结合 [docker-images](https://github.com/52fhy/docker-images) 可以实现使用docker快速部署开发环境。下面针对使用场景进行示例说明。


环境要求：

- docker 
- git 

Mac、Windows可以使用 `docker-machine` 部署docker，Ubuntu直接可以安装docker。

准备工作：  
1、安装好docker环境，安装并配置好git。  
2、宿主机新建 `/work` 目录，Mac、Windows需要在Virtaul Box里配置共享文件夹 `/work` 到 虚拟机里面。`/work` 用于映射到容器里面。  
3、获取 [docker-images](https://github.com/52fhy/docker-images) 里的 php56-fpm-centos68-withext 和 php71-fpm-centos68-phalcon-withext 镜像。  
4、克隆 yphp 项目到 `/work` 目录。后续克隆自己的项目到 `/work/www/` 目录。  

## 快速部署php5+php7+nginx开发环境

docker 创建并运行 php5+php7+nginx 容器:
``` bash
docker run -d --restart=always --name yphp56  -p 9000:9000 \
     -v /work/:/work/  \
     -v "/work/yphp/php/etc56/":/usr/local/php/etc/  \
     php56-fpm-centos68-withext
     
docker run -d --restart=always --name yphp71  -p 9001:9000 \
     -v /work/:/work/  \
     -v "/work/yphp/php/etc/":/usr/local/php/etc/  \
     php71-fpm-centos68-phalcon-withext

docker run -d --restart=always --name some-nginx -p 80-90:80-90 --link yphp56 --link yphp \
     -v /work/:/work/ \
     -v /work/yphp/nginx/conf/:/etc/nginx/ \
     -v /work/yphp/nginx/logs/:/etc/nginx/logs/ \
     daocloud.io/library/nginx:1.12.2-alpine
```

`--restart=always`用于每次docker服务启动后自动运行这些容器。

使用`docker ps`可以查看容器运行状态：
``` 
docker@default:~$ docker ps
CONTAINER ID        IMAGE                                     COMMAND                  CREATED             STATUS              PORTS                            NAMES
796252980bde        daocloud.io/library/nginx:1.12.2-alpine   "nginx -g 'daemon of…"   20 hours ago        Up About an hour    0.0.0.0:80-90->80-90/tcp         some-nginx
2835123c6d45        php71-fpm-centos68-phalcon-withext        "/run.sh"                20 hours ago        Up About an hour    80/tcp, 0.0.0.0:9001->9000/tcp   yphp71
0e02a3049ba4        php56-fpm-centos68-withext                "/run.sh"                20 hours ago        Up About an hour    80/tcp, 0.0.0.0:9000->9000/tcp   yphp56
```
`STATUS` 为 `Up` 则说明正常。

宿主机需要配置 hosts:
```
192.168.99.100  hello.cc hello56.cc hello71.cc  ysapi.cc
```
如果你是使用docker-machine部署的docker，`192.168.99.100`是虚拟机`default`默认的IP，宿主机IP是`192.168.99.1`。我们需要借助虚拟机服务容器提供的服务。  
如果你是Ubuntu系统，那么可以直接运行docker服务，无需借助虚拟机，那么 hosts里直接写`127.0.0.1`即可。  

>使用docker-machine，流程是：宿主机运行虚拟机`default`，虚拟机提供docker环境。我们在虚拟机`default`运行容器，容器对虚拟机暴露端口。我们想要在宿主机访问容器里的访问，必须使用虚拟机`default`的IP才行。  

这时候，我们访问 http://hello56.cc/ 可以看到返回的phpinfo信息。如果返回 nginx 404，请按照 http://www.cnblogs.com/52fhy/p/8468791.html 检查原因。  

接下来需要配置php.ini扩展部分。  
因为我们使用 `/etc` 覆盖了容器内的 php 配置，所以需要重新配置 php.ini：
```
extension=redis.so
extension=swoole.so
extension=yar.so
extension=phalcon.so
extension=seaslog.so
extension=gearman.so
extension=mongodb.so
extension=tideways.so
extension=protobuf.so
extension=msgpack.so
```

按需开启。配置成功后，需要在 虚拟机`default` 运行 (假设修改的yphp56容器)：
```
docker exec yphp56 killall php-fpm
docker exec yphp56 php-fpm
```

重新刷新 http://hello56.cc/ 看看效果。

如果需要修改 nginx 配置，修改后请重启 nginx 服务：
```
docker exec some-nginx nginx -s reload
```

如果需要配置xdebug，yphp71 安装起来很简单：
```
docker exec yphp71 pecl install xdebug
```
然后修改宿主机 /work/yphp/php/etc/php.ini, 增加：
```
[xdebug]
zend_extension=xdebug.so
xdebug.enable=1
xdebug.remote_enable=1
xdebug.remote_connect_back=1
; IDE所在机器IP
xdebug.remote_host=192.168.99.1
; IDE里监听的端口
xdebug.remote_port=19001
xdebug.remote_log=/var/log/xdebug_remote.log
```

重启 yphp71 容器即可。对于 yphp56 , 需要指定版本号：
```
docker exec yphp56 pecl install xdebug-2.5.5
```
去 pecl.php.net 可以查看支持的版本号。

## 关于yphp使用

yphp只是对上面命令行的一些包装，具体可以查看 yphp.sh 代码。

当挂载本地配置的时候，可以直接将yphp里的配置映射到容器内：
``` bash
docker run -d --name ysphp -p 9001:9000 -p 8082:80 \
	 -v /work/:/work/  \
	 -v "/work/yphp/php/etc/php.ini":/usr/local/php/etc/php.ini  \
	 -v "/work/yphp/nginx/conf/nginx.conf":/usr/local/nginx/conf/nginx.conf  \
	 -v "/work/yphp/nginx/conf/vhost/":/usr/local/nginx/conf/vhost/  \
	 -v "/work/yphp/nginx/logs/":/usr/local/nginx/logs/  \
	 php71-fpm-centos68-phalcon-withext
```

nginx.conf配置默认会加载vhost目录配置，也可以只映射`/usr/local/nginx/conf/vhost/`：
``` bash
docker run -d --name ysphp -p 9001:9000 -p 8082:80 \
	 -v /work/:/work/  \
	 -v "/work/yphp/nginx/conf/vhost/":/usr/local/nginx/conf/vhost/  \
	 php71-fpm-centos68-phalcon-withext
```

注意：`/yphp/php/etc/php.ini`默认是7.1.12版本的。后续如果添加了其它版本，文件名我会加上版本号。

yphp提供了php71-fpm-centos68镜像内php、nginx配置文件目录的拷贝，且提供了yphp.sh脚本。

yphp.sh脚本提供了常用命令：

``` bash
$ sh yphp.sh
Usage: yphp.sh init | ps | ssh | rm | rm_all | nginx_reload | php_m | ip
```

- init 一键创建并运行容器
- ps 查看容器内状态
- ssh 进入容器
- rm 停止并删除当前容器
- rm_all 停止并删除所有容器
- nginx_reload 容器内nginx重启，用于修改了nginx配置
- php_m 查看容器内php的扩展
- ip 查看当前环境IP地址（不是容器内）

当前容器指的是容器名称带有`phalcon-withext`的容器。后续再完善。

