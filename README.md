# yphp

## 关于yphp

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

