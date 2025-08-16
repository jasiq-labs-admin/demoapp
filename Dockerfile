# Base image with Java 17
FROM eclipse-temurin:17-jdk-alpine

# Copy your JAR into the container
COPY target/demoapp-1.0.0.jar app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
