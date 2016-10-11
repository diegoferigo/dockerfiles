FROM continuumio/miniconda3
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

RUN apt-get update &&\
    apt-get install -y cmake libboost-all-dev swig zlib1g libsdl2-dev g++ &&\
    apt-get clean

RUN conda install -y scipy matplotlib jupyter jupyter_console &&\
    conda install -y -c spyder-ide spyder &&\
    conda install -y -c conda-forge tensorflow=0.10.0 &&\
    conda clean -i -l -t -y

RUN pip install --no-cache-dir 'gym[all]'

EXPOSE 8888
