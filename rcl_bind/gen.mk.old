DST = source/rcl/package.d
SRC = source/rcl/package.dpp

$(DST): $(SRC)
	CC=clang dub run -y dpp -- --preprocess-only --include-path /opt/ros/${ROS_DISTRO}/include source/rcl/package.dpp
	sed -i -e '/struct _IO_FILE/,/}/d' source/rcl/package.d
	sed -i -e '/module rcl/a import core.stdc.stdio;' source/rcl/package.d
