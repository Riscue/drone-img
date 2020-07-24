# drone-img
Drone Plugin to run [Img](https://github.com/genuinetools/img)

`drone-img` inspired from [drone-kaniko](https://github.com/banzaicloud/drone-kaniko)

### Params
```
ENV PLUGIN_DOCKERFILE=Dockerfile
ENV PLUGIN_CONTEXT=`pwd`

ENV PLUGIN_REGISTRY=docker.io
ENV PLUGIN_REPO=$DRONE_REPO

ENV PLUGIN_AUTO_TAG=false
ENV PLUGIN_TAGS=

ENV PLUGIN_USERNAME=
ENV PLUGIN_PASSWORD=

ENV PLUGIN_DEBUG=false
ENV PLUGIN_NO_CACHE=false
ENV PLUGIN_NO_CONSOLE=false
```