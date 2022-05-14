ARG LDC_VERSION=1.29.0
ARG ROS_DISTRO=galactic

FROM nonanonno/ldc:${LDC_VERSION} AS ldc

FROM ros:${ROS_DISTRO}

# Setup LDC and clang
COPY --from=ldc /usr/local /usr/local
COPY --from=ldc /etc/ld.so.conf.d/0-openssl-1.1.1k.conf /etc/ld.so.conf.d/

RUN ldconfig

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
	libxml2 \
	clang-12 \
	lld-12 \
	curl \
	python3-pip \
	libclang-12-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/*

RUN ln -s /lib/x86_64-linux-gnu/libclang-12.so /lib/x86_64-linux-gnu/libclang.so \
	&& update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 100 \
	&& update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 100 \
	&& update-alternatives --install /usr/bin/ld ld /usr/bin/lld-12 100

# Install utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
	bash-completion \
	neovim \
	fzf \
	ros-galactic-example-interfaces \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/*
