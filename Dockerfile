FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn dependency:resolve
ADD --chmod=755 https://github.com/seal-community/cli/releases/download/latest/seal-linux-amd64-latest seal
ENV SEAL_PROJECT="sis-1832"
RUN --mount=type=secret,id=SEAL_TOKEN export SEAL_TOKEN=$(cat /run/secrets/SEAL_TOKEN) && ./seal fix --mode remote --remove-cli
RUN mvn install
RUN mvn package
RUN mvn verify

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
