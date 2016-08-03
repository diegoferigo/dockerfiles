FROM continuumio/miniconda3
MAINTAINER Diego Ferigo <dgferigo@gmail.com>

RUN conda install -y scipy matplotlib jupyter jupyter_console &&\
    conda install -y -c spyder-ide spyder &&\
    conda install -y -c jjhelmus tensorflow=0.9.0 &&\
    conda clean -i -l -t -y

EXPOSE 8888
