# Python TensorFlow Lite 2.8.0 for Amazonlinux 2

In this repo everything is provided to create the python dependencies nessessary to use Tensorflow Lite 2.8.0 with Python 3.9.10 on amazonlinux2, including support for aws lambda.

## Docker

First, if you dont already have it, install Docker. https://www.docker.com/

## Dockerfile

Then create this Dockerfile (also available in the repo).

```dockerfile
    # Set this to the amout of cores/threads you want to use for building cmake
    ARG amountOfCPUCores=24

    FROM amazonlinux

    # OpenSSL-devel needed for building cmake
    RUN yum groupinstall -y "Development Tools"
    # OpenSSL needed for building cmake with openssl-Support,
    # which in turn is needed so the tflite build script can download dependencies.
    # Numpy and libffi installs the development headers needed by tensorflow.
    RUN yum install -y openssl-devel libffi libffi-devel numpy wget

    # Install Python 3.9.10 from source
    WORKDIR /pythonInstall
    RUN wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz
    RUN tar xzf Python-3.9.10.tgz 
    WORKDIR  /pythonInstall/Python-3.9.10
    RUN ./configure --enable-optimizations
    RUN make install

    # Build cmake from source, since yum doesn't include a new enough version for TF2.8.0
    WORKDIR /cmakeInstall
    RUN wget https://cmake.org/files/v3.22/cmake-3.22.0.tar.gz
    RUN tar -xvzf cmake-3.22.0.tar.gz
    WORKDIR /cmakeInstall/cmake-3.22.0
    RUN ./bootstrap
    RUN make -j${amountOfCPUCores}
    RUN make install

    # Install Tensorflow
    WORKDIR /tflite
    RUN pip3 install numpy wheel pybind11
    RUN git clone --branch v2.8.0 https://github.com/tensorflow/tensorflow.git
    RUN PYTHON=python3 ./tensorflow/tensorflow/lite/tools/pip_package/build_pip_package_with_cmake.sh
    RUN pip3 install tensorflow/tensorflow/lite/tools/pip_package/gen/tflite_pip/python3/dist/tflite_runtime-2.8.0-cp39-cp39-linux_x86_64.whl

    CMD tail -f /dev/null
```
## Commands

You can either build it yourself, or use my prebuild versions.

### Build

Run the following commands (or use [build.bat](build.bat) on windows or [build.sh](build.sh) on linux/mac) in the same directory where you created the Dockerfile.
```
    docker build -t tflite_amazonlinux .
    docker run -d --name=tflite_amazonlinux tflite_amazonlinux
    docker cp tflite_amazonlinux:/usr/local/lib/python3.9/site-packages .
    docker stop tflite_amazonlinux
```
This is gonna need a lot of ram and some time. Build failed on my work machine with 12gb of ram, but it succeeded on my personal machine with 32gb of ram.

### Use prebuild version:

Either clone this repo via
```
    git clone https://github.com/teicherus/python_tflite_for_amazonlinux.git
```
or download the latest release from the release page.

Copy the contents of the [site-packages](site-packages) folder to your lambda layer, inside your lambda docker or where you want to use them. 

## Site-Packages

In the directory where you ran the commands there should now be a folder called *site-packages*. In that folder are the correctly compiled tflite python dependencies for amazonlinux. Copy them into your environment in your docker or add them to a lambda layer.

Warning: These packages will probably not work with other linux distributions or other architectures than amazonlinux. They are specificly created for amazonlinux.

## Sources

https://www.tensorflow.org/lite/guide/python
https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite/tools/pip_package

And probably many more :D 
