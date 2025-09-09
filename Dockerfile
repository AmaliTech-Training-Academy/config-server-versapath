# Use a lightweight base image with Java 21 JDK for building the application
FROM maven:3.8.7-eclipse-temurin-21 AS builder

# Set the working directory inside the container
WORKDIR /application

# Copy the Maven project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use a lightweight base image with Java 21 JRE for running the application
FROM bellsoft/liberica-runtime-container:jre-21-slim-musl

# Set the working directory inside the container
WORKDIR /application

# Copy the built Jar file from the builder stage
COPY --from=builder /application/target/*-SNAPSHOT.jar app.jar

# Switch to non-root user
USER apigateway

# Expose the port that the application will run on
EXPOSE 8080

# Set JVM options for optimal container performance
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Run the application
CMD ["java", "-jar", "app.jar"]
