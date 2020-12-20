FROM balenalib/raspberrypi3:buster

# Install Required Dependencies
RUN install_packages git build-essential pkg-config cmake \
gpiod libgpiod-dev libsystemd-dev libinput-dev libudev-dev libxkbcommon-dev \
libgl1-mesa-dev libgles2-mesa-dev libegl-mesa0 libdrm-dev libgbm-dev \
ttf-mscorefonts-installer fontconfig

# Update font cache for newly installed fonts
RUN fc-cache

# Install Temporary Dependencies
RUN install_packages wget unzip

# Clone RasPi Flutter Project
RUN git clone https://github.com/ardera/flutter-pi.git

# Build RasPi Flutter Project
WORKDIR flutter-pi

RUN git clone --depth 1 --branch engine-binaries https://github.com/ardera/flutter-pi.git
RUN cp ./flutter-pi/arm/libflutter_engine.so.* ./flutter-pi/arm/icudtl.dat /usr/lib
RUN cp ./flutter-pi/flutter_embedder.h /usr/include

RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j`nproc`
RUN make install

# Get Flutter Application
COPY build/flutter_assets flutter_assets
# RUN wget https://github.com/llanx/phixed_ph_monitor/raw/app/app.zip
# RUN unzip app.zip

# Run Flutter Application
CMD ["flutter-pi", "flutter_assets"]
