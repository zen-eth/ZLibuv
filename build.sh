#!/bin/bash

if [ -n $MSVC_VERSION ]; then 
    zig build -Doptimize=$1 -Dtarget=native-native-msvc -Dcpu=native -freference-trace
else 
    zig build -Doptimize=$1 -Dtarget=native-native -Dcpu=native -freference-trace
fi

# zig build -Doptimize=ReleaetFast -Dcpu=native -Dtarget=native-native-msvc -freference-trace