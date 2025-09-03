#!/usr/bin/env bash

CDIR="$(cd "$(dirname "$0")" && pwd)"
build_dir=$CDIR/build

while getopts A:K:q option
do
  case "${option}"
  in
    q) QUIET=1;;
    A) ARCH=${OPTARG};;
    K) KERNEL=${OPTARG};;
  esac
done

rm -rf $build_dir
mkdir -p $build_dir

for f in entrypoint.sh xxh-config.fish
do
    cp $CDIR/$f $build_dir/
done

# Detect architecture
if [ -z "$ARCH" ]; then
  ARCH="$(uname -m)"
fi

# If ARCH env variable is set, override detection
if [ "$ARCH" = "aarch64" ]; then
  # Download aarch64/arm version
  url='https://github.com/fish-shell/fish-shell/releases/download/4.0.2/fish-static-aarch64-4.0.2.tar.xz'
  tarname='fish-static-aarch64-4.0.2.tar.xz'
  extract_cmd="tar -xJf $tarname -C fish-portable"
else
  # Download x86_64 version
  url='https://github.com/xxh/fish-portable/releases/download/3.4.1/fish-portable-musl-alpine-Linux-x86_64.tar.gz'
  tarname='fish-portable-musl-alpine-Linux-x86_64.tar.gz'
  extract_cmd="tar -xzf $tarname -C fish-portable"
fi

cd $build_dir

[ $QUIET ] && arg_q='-q' || arg_q=''
[ $QUIET ] && arg_s='-s' || arg_s=''
[ $QUIET ] && arg_progress='' || arg_progress='--show-progress'

if [ -x "$(command -v wget)" ]; then
  wget $arg_q $arg_progress $url -O $tarname
elif [ -x "$(command -v curl)" ]; then
  curl $arg_s -L $url -o $tarname
else
  echo Install wget or curl
  exit 1
fi

mkdir fish-portable
eval "$extract_cmd"
rm $tarname
