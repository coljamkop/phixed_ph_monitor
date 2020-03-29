FROM balenalib/raspberrypi3:buster

# Install Required Dependencies
RUN install_packages git build-essential pkg-config \
gpiod libgpiod-dev \
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
RUN cp ./flutter-pi/libflutter_engine.so ./flutter-pi/icudtl.dat /usr/lib
RUN cp ./flutter-pi/flutter_embedder.h /usr/include

RUN make

# Get Flutter Application
COPY build/flutter_assets flutter_assets
# RUN wget https://github.com/llanx/phixed_ph_monitor/raw/app/app.zip
# RUN unzip app.zip

# Run Flutter Application
CMD ["./out/flutter-pi", "flutter_assets"]
