DST = source/rcl/package.d
SRC = source/rcl/package.dpp

$(DST): $(SRC)
	CC=clang dub run -y dpp -- --preprocess-only --include-path /opt/ros/${ROS_DISTRO}/include source/rcl/package.dpp
