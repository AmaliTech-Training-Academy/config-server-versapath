# Build stage: Compile the application
FROM maven:3.9-eclipse-temurin-21 AS builder

# Set the working directory inside the container
WORKDIR /build

# Copy pom.xml first for better caching
COPY pom.xml .
# Download dependencies (will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src/

# Build the application
RUN mvn package -DskipTests

# Use a lightweight base image with Java 21 JRE for running the application
FROM bellsoft/liberica-runtime-container:jre-21-slim-musl

# Set the working directory inside the container
WORKDIR /application

# Copy the built Jar file from the builder stage
COPY --from=builder /build/target/*-SNAPSHOT.jar app.jar

# Switch to non-root user
USER configserver

# Expose the port that the application will run on
EXPOSE 8888

# Set JVM options for optimal container performance
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Run the application
CMD ["java", "-jar", "app.jar"]
