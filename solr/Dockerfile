FROM tomcat:7.0.93
MAINTAINER gmsoft-pyb

WORKDIR /usr/local/tomcat

RUN set -ex; \
   mkdir -p /usr/local/tomcat/conf/Catalina/localhost; \
   mkdir -p /var/solrhome; \
   wget https://raw.githubusercontent.com/cldrag/k8simages/master/solr/solr.war -P /usr/local/tomcat/webapps; \
   wget https://raw.githubusercontent.com/cldrag/k8simages/master/solr/solr.xml -P /usr/local/tomcat/conf/Catalina/localhost/ ; \
   sed -i "s/@solrwarpath/\/usr\/local\/tomcat\/webapps/g" /usr/local/tomcat/conf/Catalina/localhost/solr.xml; \
   sed -i "s/@solrhomepath/\/var\/solrhome/g" /usr/local/tomcat/conf/Catalina/localhost/solr.xml

EXPOSE 8080
CMD ["catalina.sh", "run"]