FROM openjdk:17-alpine

VOLUME /tmp
RUN mkdir /deployment
WORKDIR /deployment

COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/deployment/app.jar"]




