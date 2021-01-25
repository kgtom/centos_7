

## 1.docker  搭建

~~~
docker pull ghost  （ ghostv1.24.5）

docker images  
[root@iz2ze71m2nxbuwib8avpwsz ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker.io/ghost     1.24.5              05e39d0596d1        2 years ago         571 MB

 docker run --name newblogs -p 2368:2368 -d 05e39d0596d1

~~~

2. 配置nginx,  vi /etc/nginx/conf.d/ghost.conf

~~~
server {
listen 88;
server_name 39.106.173.209;
location / {
proxy_set_header   X-Real-IP $remote_addr;
proxy_set_header   Host      $http_host;
proxy_pass         http://127.0.0.1:2368;
	}
}

~~~

## 3. 进入容器，修改ghost默认数据库
[root@iz2ze71m2nxbuwib8avpwsz ~]# docker exec -it fd4b7008ea62 bash

### 3.1 安装vim 
apt-get update 
apt-get intall vim

### 3.2  	
默认使用的dev开发模式，修改为prod生产模式
~~~
 cd /var/lib/ghost/current/core
    vim index.js

process.env.NODE_ENV = process.env.NODE_ENV || 'production';


进入DB配置文件目录: cd /var/lib/ghost/current/core/server/config/env ，	修改vi config.production.json

Ip:= 在宿主机，使用 docker inspect fd4b7008ea62，即："Gateway": "172.17.0.1", 或者使用宿主机内网ip 192.168.1.245
 
"database": {
        "client": "mysql",
        "connection": {
            "host"     : "192.168.1.245",
            "user"     : "tom",
            "password" : "abc@123",
            "database" : "ghost"
        }
    },
~~~

### 3.3 停掉 容器，重新启动

~~~
root@fd4b7008ea62:/var/lib/ghost/current/core/server/config/env#  cd /var/lib/ghost/current/core
root@fd4b7008ea62:/var/lib/ghost/current/core# ls
built  index.js  server
root@fd4b7008ea62:/var/lib/ghost/current/core# vi index.js
root@fd4b7008ea62:/var/lib/ghost/current/core# exit
exit
[root@iz2ze71m2nxbuwib8avpwsz ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
fd4b7008ea62        05e39d0596d1        "docker-entrypoint..."   About an hour ago   Up About an hour    0.0.0.0:2368->2368/tcp   newblogs
[root@iz2ze71m2nxbuwib8avpwsz ~]# docker stop fd4b7008ea62
fd4b7008ea62
[root@iz2ze71m2nxbuwib8avpwsz ~]# docker start fd4b7008ea62
fd4b7008ea62

~~~
