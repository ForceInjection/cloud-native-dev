FROM eclipse-temurin:8u372-b07-jre-centos7

ADD ./target/user-service.jar /app/user-service.jar

ADD runboot.sh /app/

WORKDIR /app

RUN chmod a+x runboot.sh

CMD ["sh","-c","/app/runboot.sh"]