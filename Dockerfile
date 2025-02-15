ARG UBUNTU_VERSION=20.04

ARG ARCH=
ARG CUDA=11.2.2
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA=11.2
ARG CUDNN=8.1.0.77-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=7.2.2-1
ARG LIBNVINFER_MAJOR_VERSION=7

# Let us install tzdata painlessly
ENV DEBIAN_FRONTEND=noninteractive

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies

# libgl1-mesa-dev is need for use OpenCV
# https://cocoinit23.com/docker-opencv-importerror-libgl-so-1-cannot-open-shared-object-file/

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
    apt update && apt install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        libcublas-${CUDA/./-} \
        cuda-nvrtc-${CUDA/./-} \
        libcufft-${CUDA/./-} \
        libcurand-${CUDA/./-} \
        libcusolver-${CUDA/./-} \
        libcusparse-${CUDA/./-} \
        curl \
        libcudnn8=${CUDNN}+cuda${CUDA} \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip \
        git \
        vim \
        eog \
        wget \
        libgl1-mesa-dev

# Install TensorRT if not building for PowerPC
# NOTE: libnvinfer uses cuda11.1 versions
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt update && \
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub && \
        echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /"  > /etc/apt/sources.list.d/tensorRT.list && \
        apt update && \
        apt install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.0 \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.0 \
        && apt clean \
        && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda-11.2/targets/x86_64-linux/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

###############################################################################################################
# start install python
# https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/

RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt update
RUN apt install -y python3.8
RUN apt install -y python3.8-dbg python3.8-dev python3.8-distutils \
                   python3.8-lib2to3 python3.8-tk


# Set alias
RUN echo 'alias python=python3' >> ~/.bashrc
RUN echo 'alias pip=pip3' >> ~/.bashrc
RUN . ~/.bashrc

RUN apt autoremove -y

# end install python
###############################################################################################################
###############################################################################################################
# setup pip
# https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3.8 get-pip.py
RUN python3.8 -m pip install --upgrade pip

# end setup pip
###############################################################################################################

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
# Set --build-arg TF_PACKAGE_VERSION=1.11.0rc0 to install a specific version.
# Installs the latest version by default.
ARG TF_PACKAGE=tensorflow
ARG TF_PACKAGE_VERSION=2.11.0
RUN python3 -m pip install --no-cache-dir ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc


#RUN echo 'export DISPLAY=:0.0' >> ~/.bashrc 
#RUN echo 'export LIBGL_ALWAYS_INDIRECT=0' >> ~/.bashrc
RUN echo 'export PYTHONPATH="${PYTHONPATH}:/programs/YOLOX/"' >> ~/.bashrc
RUN echo 'export PATH="/usr/local/cuda/bin:$PATH"' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
RUN source ~/.bashrc



RUN python3 -m pip install --no-cache-dir jupyter matplotlib
# Pin ipykernel and nbformat; see https://github.com/ipython/ipykernel/issues/422
# Pin jedi; see https://github.com/ipython/ipython/issues/12740
RUN python3 -m pip install --no-cache-dir jupyter_http_over_ws ipykernel==5.1.1 nbformat==5.10.4 jedi==0.17.2 nbconvert==6.4.3
RUN jupyter serverextension enable --py jupyter_http_over_ws

RUN mkdir -p /home/user/code && chmod -R a+rwx /home/user/code/
RUN mkdir /.local && chmod a+rwx /.local
RUN apt update && apt install -y --no-install-recommends wget git
RUN apt autoremove -y
WORKDIR /home/user/code
EXPOSE 8887

RUN python3 -m ipykernel.kernelspec

RUN python3 -m pip install --no-cache-dir opencv-python

###############################################################################################################
# Install VSCodium
# https://itsfoss.com/install-vscodium-ubuntu/
RUN wget https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        -O /usr/share/keyrings/vscodium-archive-keyring.asc
RUN echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.asc ]  \ 
        https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' |  \
        tee /etc/apt/sources.list.d/vscodium.list
RUN apt update
RUN apt install -y codium
###############################################################################################################


#CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
#CMD ["bash", "-c", "source /etc/bash.bashrc"]
