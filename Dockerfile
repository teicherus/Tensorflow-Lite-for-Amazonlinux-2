# Set this to the amout of cores/threads you want to use for building cmake
ARG amountOfCPUCores=24

FROM amazonlinux

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