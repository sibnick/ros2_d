module test_helper.ament;

import std.path : buildPath, dirName;

enum amentPrefixPath = buildPath(__FILE_FULL_PATH__.dirName.dirName.dirName, "ament", "install", "test_msgs");
