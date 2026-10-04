# Use Alpine Linux as the base image
FROM alpine:latest

# Update package lists and install necessary dependencies
RUN apk update && \
    apk add --no-cache \
    git \
    cmake \
    openssl-dev \
    build-base

# Set the working directory inside the container
WORKDIR /MicroOcppSimulator

# Clone the repository with all submodules (with retry for submodules)
RUN git clone --recurse-submodules --depth=1 https://github.com/Ramikaspa/MicroOcppSimulator222.git . && \
    git submodule update --init --recursive && \
    rm -rf .git

# Verify submodules are present
RUN ls -la lib/ && \
    [ -d lib/MicroOcpp ] || (echo "MicroOcpp submodule missing" && exit 1) && \
    [ -d lib/mbedtls ] || (echo "mbedtls submodule missing" && exit 1)

# Build the project
RUN cmake -S . -B ./build
RUN cmake --build ./build -j 16 --target mo_simulator

# Grant execute permissions
RUN chmod +x /MicroOcppSimulator/build/mo_simulator

# Expose port 8000
EXPOSE 8000

# Run the simulator
CMD ["./build/mo_simulator"]
