# Containerize the go application that we have created
# This is the Dockerfile that we will use to build the image
# and run the container

# Start with a base image(set alice)
#Assigns an alias (base) to this stage of the multi-stage build.
#This alias allows you to reference this stage later in the Dockerfile, such as copying files or artifacts from it.
FROM golang:1.21 as base

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the working directory(dependencies of application included in this mod file like pom.xml in java project)
COPY go.mod ./

# Download all the dependencies
RUN go mod download

# Copy the source code to the working directory
COPY . .

# Build the application(artifact by the name main created )
RUN go build -o main .

# EXPOSE 8080
# CMD ["./main"]
#######################################################
# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application
#A distroless image in a multistage Docker build refers to a Docker image that does not include a complete Linux distribution.
#Instead, it contains only the minimal runtime dependencies required for an application to run. 
#This approach helps reduce image size, improve security, and reduce attack surface by excluding unnecessary packages, shell binaries, or tools.

#final stage - distroless image
FROM gcr.io/distroless/base

# Copy the binary from the previous stage
COPY --from=base /app/main .

# Copy the static files from the previous stage (static content is outside binary file so need to copy static bundle also)
COPY --from=base /app/static ./static

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["./main"]
