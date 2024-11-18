FROM openjdk:17-jdk
# 컨테이너 내부에서의 작업 디렉토리 설정
WORKDIR /home/app
# build/libs의 jar파일을 컨테이너 내부의 app.jar로 복사
COPY build/libs/*.jar app.jar
#컨테이너가 사용할 포트
EXPOSE 5000
# app.jar  실행
ENTRYPOINT ["java","-jar","./app.jar","--spring.profiles.active=secret"]