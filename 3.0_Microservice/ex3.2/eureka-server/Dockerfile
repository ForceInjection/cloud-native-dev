FROM eclipse-temurin:8u372-b07-jre-centos7

ADD ./target/eureka-server.jar /app/eureka-server.jar

ADD runboot.sh /app/

WORKDIR /app

RUN chmod a+x runboot.sh

CMD ["sh","-c","/app/runboot.sh"]

EXPOSE 8080