FROM alpine:3.6

MAINTAINER shenggangshu <shenggangshu7276@qq.com>

ENV HOME /root

#安装准备
RUN apk update \
    && apk add --no-cache  git gcc libc-dev make automake autoconf libtool pcre pcre-dev zlib zlib-dev openssl-dev wget vim --repository https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.6/main


#下载fastdfs.libfastcommon.nginx插件源码
RUN cd /root \
    && git clone https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && git clone https://github.com/happyfish100/fastdfs.git --depth 1 \
    && wget http://nginx.org/download/nginx-1.15.4.tar.gz \
    && git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1

 # 安装libfastcommon
 RUN cd ${HOME}/libfastcommon/ \
    && ./make.sh  \
    && ./make.sh install

# 安装fastdfs
RUN cd ${HOME}/fastdfs/ \
    && ./make.sh \
    && ./make.sh install \
    && cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf \
    && cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf \
    && cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf \
    && cp ${HOME}/fastdfs/conf/http.conf /etc/fdfs/ \
    && cp ${HOME}/fastdfs/conf/mime.types /etc/fdfs/ \
    && sed -i "s|/home/yuqing/fastdfs|/var/local/fdfs/tracker|g" /etc/fdfs/tracker.conf \
    && sed -i "s|/home/yuqing/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/storage.conf \
    && sed -i "s|/home/yuqing/fastdfs|/var/local/fdfs/storage|g" /etc/fdfs/client.conf

# 获取nginx源码
RUN cd ${HOME} \
    && tar -zxvf nginx-1.15.4.tar.gz  \
    && cd nginx-1.15.4/ \
    && ./configure --add-module=${HOME}/fastdfs-nginx-module/src/ \
    && make \
    && make install

# 设置nginx和fastdfs联合环境，并配置nginx
RUN cp ${HOME}/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs \
    && sed -i "s|^store_path0.*$|store_path0=/var/local/fdfs/storage|g" /etc/fdfs/mod_fastdfs.conf \
    && sed -i "s|^url_have_group_name =.*$|url_have_group_name = true|g" /etc/fdfs/mod_fastdfs.conf \
    && cd ${HOME}/fastdfs/conf/ \
    && echo -e "\
    events {\n\
        worker_connections  1024;\n\
    }\n\
    http {\n\
        include       mime.types;\n\
        default_type  application/octet-stream;\n\
        server {\n\
            listen 8888;\n\
            server_name localhost;\n\
            location ~ /group[0-9]/M00 {\n\
                ngx_fastdfs_module;\n\
            }\n\
        }\n\
    }">/usr/local/nginx/conf/nginx.conf

# 清理文件
RUN rm -rf ${HOME}/*
RUN apk del gcc libc-dev make openssl-dev
# 配置启动脚本，在启动时中根据环境变量替换nginx端口、fastdfs端口
# 默认nginx端口
ENV WEB_PORT 8888
# 默认fastdfs端口
ENV FDFS_PORT 22122

# 创建启动脚本
RUN     echo -e "\
mkdir -p /var/local/fdfs/storage/data /var/local/fdfs/tracker; \n\
ln -s /var/local/fdfs/storage/data/ /var/local/fdfs/storage/data/M00; \n\n\
sed -i \"s/listen\ .*$/listen\ \$WEB_PORT;/g\" /usr/local/nginx/conf/nginx.conf; \n\
sed -i \"s/http.server_port=.*$/http.server_port=\$WEB_PORT/g\" /etc/fdfs/storage.conf; \n\n\
if [ \"\$IP\" = \"\" ]; then \n\
    IP=`ifconfig eth0 | grep inet | awk '{print \$2}'| awk -F: '{print \$2}'`; \n\
fi \n\
sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/client.conf; \n\
sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/storage.conf; \n\
sed -i \"s/^tracker_server=.*$/tracker_server=\$IP:\$FDFS_PORT/g\" /etc/fdfs/mod_fastdfs.conf; \n\n\
/etc/init.d/fdfs_trackerd start; \n\
/etc/init.d/fdfs_storaged start; \n\
/usr/local/nginx/sbin/nginx; \n\
tail -f /usr/local/nginx/logs/access.log \
">/start.sh \
&& chmod u+x /start.sh

# 暴露端口。改为采用host网络，不需要单独暴露端口
# EXPOSE 80 22122

ENTRYPOINT ["/bin/bash","/start.sh"]
