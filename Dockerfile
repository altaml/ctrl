# You can pull this image from 

ARG BASE_IMAGE=tensorflow/tensorflow:1.14.0-gpu-jupyter
FROM $BASE_IMAGE

LABEL maintainer="AltaML Team, mansour@altaml.com"

# Run updates, install basics and cleanup
# - build-essential: Compile specific dependencies
# - git-core: Checkout git repos
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential git-core openssl libssl-dev libffi6 libffi-dev curl gcc wget

# install fastBPE
# code available at: https://github.com/glample/fastBPE
RUN git clone https://github.com/glample/fastBPE.git && \
    cd fastBPE && \
    g++ -std=c++11 -pthread -O3 fastBPE/main.cc -IfastBPE -o fast && \
    pip install Cython && \
    python setup.py install

WORKDIR /tf

# clone CTRL and download the models
RUN git clone https://github.com/salesforce/ctrl.git && \
    cd ctrl && \
    patch -b /usr/local/lib/python2.7/dist-packages/tensorflow_estimator/python/estimator/keras.py estimator.patch && \
    pip install gsutil && \
    gsutil -m cp -r gs://sf-ctrl/seqlen256_v1.ckpt/ .

WORKDIR /tf
