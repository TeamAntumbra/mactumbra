#!/bin/sh

set -e

xcodebuild -scheme Antumbra-release DEPLOYMENT_LOCATION=YES DSTROOT="$(pwd)" INSTALL_PATH=/ clean build install
tar -czf BUILD.tar.gz Antumbra.app
