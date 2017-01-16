#!/usr/bin/env bash

# Get Arch Linux Bootstrap

set -e

declare version
declare arch
declare cache
declare remove
declare trust
declare fix

dependency() {
  for executable in "$@"; do
    ! type ${executable} >/dev/null 2>&1 && \
    printf "Dependency not installed: ${executable}\n" 1>&2 && return 1
  done; return 0
}

cache() {
  [[ ${cache} ]] || return 1
  [[ -f ${1} ]] || return 1
  printf "Found in cache: ${1} \n"
}

remove() {
  [[ ${remove} ]] || return 0
  for file in "$@"; do
    [[ -f ${file} ]] || return 0
    rm ${file} && printf "Removed from cache: ${file}\n"
  done;
}

download() {
  printf "Downloading: ${2}\n"
  curl "${1}/${2}" -# -O -f --stderr -
}

verify() {
  [[ ! ${trust} ]] || return 0
  dependency gpg || return 0
  printf "Verifying signature: "
  gpg --keyserver-options auto-key-retrieve --verify ${1} >/dev/null 2>&1 && \
  printf "verified\n" && return 0; printf "invalid\n" && return 1
}

latest() {
  [[ ! ${version} ]] || return 0

  local this_year=`date +%Y`
  local this_month=`date +%m`
  local today=`date +%d`
  local last_year=$((this_year-1))
  local last_month=`printf "%02d" $((this_month-1))`

  local range1="$this_year.$this_month.[00-$today]"
  local range2="$this_year.$last_month.[01-31]"
  local range3="$this_year.[00-$this_month].[01-31]"
  local range4="$last_year.[01-12].[01-31]"
  local ranges=(${range1} ${range2} ${range3} ${range4})

  local latest
  local counter=0
  while [[ ! ${latest} && ${counter} -lt 4 ]]; do
    local url="https://archive.archlinux.org/iso/${ranges[$counter]}/md5sums.txt"
    local options="-I --compressed --stderr -"
    local filter='/Last-Modified/ {print $3,$4,$5;}'
    latest=`curl "${url}" ${options} | awk "${filter}" | tail -1`
    let counter+=1
  done

  local platform="`uname`"
  case ${platform} in
    ('Linux')   version=`date -d "${latest}" +%Y.%m.%d` ;;
    ('Darwin')  version=`date -jf "%d %b %Y" "${latest}" +"%Y.%m.%d"` ;;
    (*)         exit 1 ;;
  esac

  printf "$version\n"
}

fix() {
  [[ ${fix} ]] || return 0
  dependency python3.5
  local fix="tar_fix.py"
  local output="archlinux-bootstrap.tar.gz"
  remove ${output}
  printf "Removing prefix root.${arch} from archive: "
  python3 ${fix} --input=${1} --output=${output} && printf "${output}\n"
}

logo() {
  dependency cat && cat logo || \
  printf "Get Arch Linux Bootstrap\n"
}

usage() {
  printf "
  Usage: ${0} [options...]

  Options:
  -v [version]  Download a specific version. Format: YYYY.MM.DD
  -a [arch]     Download a specific architecture. Supported: x86_64, i686
  -c            Use local cache. If found skip download
  -r            Remove old files before downloading
  -t            Trust the signature. Skip verifying the signature
  -f            Fix archive. Removes prefix directory from archive
  -l            Show latest version
  -h            Show this help
  \n"
}

options() {
  [[ "$@" ]] || return 0
  local OPTIND=1
  while getopts "v:a:crtflh" OPTIND; do
    case $OPTIND in
      v) version=$OPTARG ;;
      a) arch=$OPTARG ;;
      c) cache=1 ;;
      r) remove=1 ;;
      t) trust=1 ;;
      f) fix=1 ;;
      l) latest && exit 0 ;;
      h) usage && exit 0 ;;
      *) usage && exit 1 ;;
    esac
  done
}

main() {
  options "$@"
  logo
  dependency awk curl date tail uname

  printf "Version: "
  local latest=`latest`
  local version="${version:-${latest}}"
  local arch="${arch:-x86_64}"
  printf "$version-$arch\n"

  local base_url="https://archive.archlinux.org/iso/${version}"
  local bootstrap="archlinux-bootstrap-${version}-${arch}.tar.gz"
  local signature="${bootstrap}.sig"

  remove ${bootstrap} ${signature}
  cache ${bootstrap} || download ${base_url} ${bootstrap}
  cache ${signature} || download ${base_url} ${signature}
  verify ${signature}
  fix ${bootstrap}

  printf "Finished\n" && exit 0
}

main "$@"