#!/usr/bin/env bash
# Copyright (c) 2016-present Sven Greb <development@svengreb.de>
# This source code is licensed under the MIT license found in the license file.

# nounset: Treat unset variables and parameters as an error when performing parameter expansion
# errexit: Exit immediately if any command exits with a non-zero status
set -o nounset -o errexit

_ct_error="\e[0;31m"
_ct_success="\e[0;32m"
_ct_warning="\e[0;33m"
_ct_highlight="\e[0;34m"
_ct_primary="\e[0;36m"
_ct="\e[0;37m"
_ctb_subtle="\e[1;30m"
_ctb_error="\e[1;31m"
_ctb_success="\e[1;32m"
_ctb_warning="\e[1;33m"
_ctb_highlight="\e[1;34m"
_ctb_primary="\e[1;36m"
_ctb="\e[1;37m"
_c_reset="\e[0m"

__help() {
  printf "${_ctb}Usage: ${_ct_primary}install.sh ${_ctb_subtle}[OPTIONS]\n"
  printf "  ${_ctb_highlight}-h${_ct},${_ctb_highlight} --help                      ${_ct}Help\n"
  printf "  ${_ctb_highlight}-v${_ct},${_ctb_highlight} --verbose                   ${_ct}Verbose output\n${_c_reset}"
  printf "  ${_ctb_highlight}-t${_ct},${_ctb_highlight} --themefile <THEME_FILE>  \
${_ct}Use the specified color theme file\n${_c_reset}"
}

__cleanup() {
  trap '' SIGINT SIGTERM
  unset -v _ct_error _ct_success _ct_warning _ct_highlight _ct_primary _ct
  unset -v _ctb_error _ctb_success _ctb_warning _ctb_highlight _ctb_primary _ctb _c_reset
  unset -v NORD_XFCE_TERMINAL_SCRIPT_OPTS THEME_FILE VERBOSE LOCAL_INSTALL NORD_XFCE_TERMINAL_VERSION
  unset -f __help __cleanup __log_error __log_success __log_warning __log_info
  unset -f __validate_file __local_install
}

__log_error() {
  printf "${_ctb_error}[ERROR] ${_ct}$1${_c_reset}\n"
}

__log_success() {
  printf "${_ctb_success}[OK] ${_ct}$1${_c_reset}\n"
}

__log_warning() {
  printf "${_ctb_warning}[WARN] ${_ct}$1${_c_reset}\n"
}

__log_info() {
  printf "${_ctb}[INFO] ${_ct}$1${_c_reset}\n"
}

__summary_success() {
  __log_success "Local installation completed"
  __cleanup
  exit 0
}

__summary_error() {
  __log_error "An error occurred during the installation!"
  __log_error "Exit code: $1"
  __cleanup
  exit 1
}

__local_install() {
  __validate_file
  if [ ! -d $LOCAL_INSTALL_DIR ]; then
    mkdir -p $LOCAL_INSTALL_DIR
    if [ $? -eq 0 ]; then
      if [ $VERBOSE = true ]; then __log_info "Created local directory $LOCAL_INSTALL_DIR"; fi
    else
      __log_error "Could not create local directory $LOCAL_INSTALL_DIR"
      __summary_error 1
    fi
  fi
  cp -f $THEME_FILE $LOCAL_INSTALL_DIR
  if [ $? -eq 0 ]; then
    if [ $VERBOSE = true ]; then __log_success "Copied color theme file to $LOCAL_INSTALL_DIR"; fi
    __summary_success
  else
    __log_error "Could not copy color theme file to $LOCAL_INSTALL_DIR"
    __summary_error 1
  fi
}

__validate_file() {
  if [ ! -f $THEME_FILE ]; then
    __log_error "Color theme file not found: $THEME_FILE"
    __summary_error 1
  fi
}

trap "printf '${_ctb_error}User aborted.${_c_reset}\n' && exit 1" SIGINT SIGTERM

NORD_XFCE_TERMINAL_SCRIPT_OPTS=$(getopt -o vht: --long verbose,help,themefile: -n 'install.sh' -- "$@")
THEME_FILE=src/nord.theme
VERBOSE=false
LOCAL_INSTALL_DIR=~/.local/share/xfce4/terminal/colorschemes
NORD_XFCE_TERMINAL_VERSION=0.1.0

eval set -- "$NORD_XFCE_TERMINAL_SCRIPT_OPTS"
while true; do
  case "$1" in
    -v | --verbose)
      VERBOSE=true
      shift
      ;;
    -h | --help)
      __help
      exit 0
      break
      ;;
    -t | --themefile)
      THEME_FILE="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *) break ;;
  esac
done

__local_install

__cleanup
exit 0
