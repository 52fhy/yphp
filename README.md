# yphp

## ����yphp

�����ر������õ�ʱ�򣬿���ֱ�ӽ�yphp�������ӳ�䵽�����ڣ�
``` bash
docker run -d --name ysphp -p 9001:9000 -p 8082:80 \
	 -v /work/:/work/  \
	 -v "/work/yphp/php/etc/php.ini":/usr/local/php/etc/php.ini  \
	 -v "/work/yphp/nginx/conf/nginx.conf":/usr/local/nginx/conf/nginx.conf  \
	 -v "/work/yphp/nginx/conf/vhost/":/usr/local/nginx/conf/vhost/  \
	 -v "/work/yphp/nginx/logs/":/usr/local/nginx/logs/  \
	 php71-fpm-centos68-phalcon-withext
```

nginx.conf����Ĭ�ϻ����vhostĿ¼���ã�Ҳ����ֻӳ��`/usr/local/nginx/conf/vhost/`��
``` bash
docker run -d --name ysphp -p 9001:9000 -p 8082:80 \
	 -v /work/:/work/  \
	 -v "/work/yphp/nginx/conf/vhost/":/usr/local/nginx/conf/vhost/  \
	 php71-fpm-centos68-phalcon-withext
```

ע�⣺`/yphp/php/etc/php.ini`Ĭ����7.1.12�汾�ġ������������������汾���ļ����һ���ϰ汾�š�

yphp�ṩ��php71-fpm-centos68������php��nginx�����ļ�Ŀ¼�Ŀ��������ṩ��yphp.sh�ű���

yphp.sh�ű��ṩ�˳������

``` bash
$ sh yphp.sh
Usage: yphp.sh init | ps | ssh | rm | rm_all | nginx_reload | php_m | ip
```

- init һ����������������
- ps �鿴������״̬
- ssh ��������
- rm ֹͣ��ɾ����ǰ����
- rm_all ֹͣ��ɾ����������
- nginx_reload ������nginx�����������޸���nginx����
- php_m �鿴������php����չ
- ip �鿴��ǰ����IP��ַ�����������ڣ�

��ǰ����ָ�����������ƴ���`phalcon-withext`�����������������ơ�

