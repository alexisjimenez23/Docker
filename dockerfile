# Run RStudio in a container
#
# docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw -e DISPLAY=unix$DISPLAY -v $HOME/rscripts:/training/rscripts --device /dev/dri --name rstudio ebitraining/rstudio:alpha /bin/bash
#
#
# docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix:rw -e DISPLAY=unix$DISPLAY -v $HOME/rscripts:/training/rscripts -v /usr/lib/nvidia-340:/usr/lib/nvidia-340 -v /usr/lib32/nvidia-340:/usr/lib32/nvidia-340 --device /dev/dri --name rstudio ebitraining/rstudio:alpha /bin/bash
#
#
#
# USAGE:
#	# Build cytoscape image
#	docker build -f ./Dockerfile -t rstudio .
#

# Base docker image
FROM ubuntu:16.04
LABEL maintainer "Mohamed Alibi <alibimohamed@gmail.com>"

ADD https://download1.rstudio.org/rstudio-xenial-1.1.442-amd64.deb /src/rstudio.deb

# Install Rstudio
RUN apt-get update && apt-get install -y \
	ca-certificates \
	fcitx-frontend-qt5 \
	fcitx-modules \
	fcitx-module-dbus \
	libedit2 \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libgstreamer0.10-0 \
	libgstreamer-plugins-base0.10-0 \
	libjpeg-dev \
	libpresage-data \
	libqt5core5a \
	libqt5dbus5 \
	libqt5gui5 \
	libqt5network5 \
	libqt5printsupport5 \
	libqt5webkit5 \
	libqt5widgets5 \
	libtiff5 \
	libxcomposite1 \
	libxslt1.1 \
	littler \
	locales \
	libjpeg62 \
	r-base \
	r-base-dev \
	r-recommended \
	--no-install-recommends \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8 \
	&& dpkg -i '/src/rstudio.deb' \
	&& apt-get install -fy \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /src/*.deb \
	&&  ln -f -s /usr/lib/rstudio/bin/rstudio /usr/bin/rstudio

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Set default CRAN repo
RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r \
	&& ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
	&& ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
	&& ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	&& ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
	&& echo '"\e[5~": history-search-backward' >> /etc/inputrc \
	&& echo '"\e[6~": history-search-backward' >> /etc/inputrc

# nvidia-docker hooks
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/lib/nvidia-340/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/nvidia-340:/usr/lib32/nvidia-340:${LD_LIBRARY_PATH}

ENV HOME /home/training

RUN useradd --create-home --home-dir $HOME training \
	&& chown -R training:training $HOME \
	&& usermod -a -G audio,video training

WORKDIR $HOME
USER training

# Autorun Rstudio
ENTRYPOINT [ "rstudio" ]
