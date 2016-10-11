My personal Anaconda setup, built on top of the official miniconda image.

It contains only the python packages I need.

## Build the image
```
cd dockerfiles/Anaconda
docker build -t diego/miniconda .
```

## Start the container

###Jupyter Notebook
```
# docker run -p 8888:8888 -i -t --rm --name="anaconda" diego/miniconda jupyter-notebook --no-browser --ip=0.0.0.0
```
For mounting a shared folder inside the container, add
```
# docker run -p 8888:8888 -i -t --rm -v /host/folder/:/container/ -w /container/folder --name="anaconda" diego/miniconda jupyter-notebook --no-browser --ip=0.0.0.0
```
Then, visit `http://localhost:8888` on the host machine

### Share X11
```
# docker run -i -t --rm -w /container/folder --privileged -e "DISPLAY" --security-opt="label:disable" -v /tmp/.X11-unix:/tmp/.X11-unix:rw --name="anaconda" diego/miniconda bash
```

## Open an additional console
```
# docker exec -it anaconda bash
```
