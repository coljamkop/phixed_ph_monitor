FROM balenalib/raspberrypi3:buster
MAINTAINER Colton Kopsa <coljamkop@gmail.com>

RUN install_packages git build-essential pkg-config \
gpiod libgpiod-dev \
libgl1-mesa-dev libgles2-mesa-dev libegl-mesa0 libdrm-dev libgbm-dev

RUN git clone https://github.com/ardera/flutter-pi.git

WORKDIR flutter-pi

RUN git clone --depth 1 --branch engine-binaries https://github.com/ardera/flutter-pi.git
RUN cp ./flutter-pi/libflutter_engine.so ./flutter-pi/icudtl.dat /usr/lib
RUN cp ./flutter-pi/flutter_embedder.h /usr/include

RUN make

COPY build/flutter_assets app
CMD ["flutter-pi", "app"]


