#!/usr/bin/env sh
# shellcheck shell=sh
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202308271918-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  install.sh --help
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Sunday, Aug 27, 2023 19:18 EDT
# @@File             :  install.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  shell/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC2016
# shellcheck disable=SC2031
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# shellcheck disable=SC2317
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# BASH_SET_SAVED_OPTIONS=$(set +o)
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -x || set +x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set default exit code
INSTALL_SH_EXIT_STATUS=0
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# check for command
__cmd_exists() { command "$1" >/dev/null 2>&1 || return 1; }
__function_exists() { command -v "$1" 2>&1 | grep -q "is a function" || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Relative find functions
__find_file_relative() { find "$1"/* -not -path '*env/*' -not -path '.git*' -type f 2>/dev/null | sed 's|'$1'/||g' | sort -u | grep -v '^$' | grep '^' || false; }
__find_directory_relative() { find "$1"/* -not -path '*env/*' -not -path '.git*' -type d 2>/dev/null | sed 's|'$1'/||g' | sort -u | grep -v '^$' | grep '^' || false; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# custom functions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define Variables
TEMPLATE_NAME="nodejs"
CONFIG_CHECK_FILE=""
OVER_WRITE_INIT="yes"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TMP_DIR="/tmp/config-$TEMPLATE_NAME"
CONFIG_DIR="/usr/local/share/template-files/config"
INIT_DIR="/usr/local/etc/docker/init.d"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
GIT_REPO="https://github.com/templatemgr/$TEMPLATE_NAME"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "$TEMPLATE_NAME" = "sample-template" ] && exit 1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d "$TMP_DIR" ] && rm -Rf "$TMP_DIR"
git clone -q "$GIT_REPO" "$TMP_DIR" || exit 1
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main application
mkdir -p "$CONFIG_DIR" "$INIT_DIR"
find "$TMP_DIR/" -iname '.gitkeep' -exec rm -f {} \;
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# custom pre execution commands
get_dir_list="$(__find_directory_relative "$TMP_DIR/config" || false)"
if [ -n "$get_dir_list" ]; then
  for dir in $get_dir_list; do
    mkdir -p "$CONFIG_DIR/$dir" /etc/$dir
  done
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
get_file_list="$(__find_file_relative "$TMP_DIR/config" || false)"
if [ -n "$get_file_list" ]; then
  for conf in $get_file_list; do
    if [ -f "/etc/$conf" ]; then
      rm -Rf /etc/${conf:?}
    fi
    if [ -d "$TMP_DIR/config/$conf" ]; then
      cp -Rf "$TMP_DIR/config/$conf/." "/etc/$conf/"
      cp -Rf "$TMP_DIR/config/$conf/." "$CONFIG_DIR/$conf/"
    elif [ -e "$TMP_DIR/config/$config" ]; then
      cp -Rf "$TMP_DIR/config/$conf" "/etc/$conf"
      cp -Rf "$TMP_DIR/config/$conf" "$CONFIG_DIR/$conf"
    fi
  done
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -d "$TMP_DIR/init-scripts" ]; then
  init_scripts="$(ls -A "$TMP_DIR/init-scripts/" | grep '^' || false)"
  if [ -n "$init_scripts" ]; then
    mkdir -p "$INIT_DIR"
    for init_script in $init_scripts; do
      if [ "$OVER_WRITE_INIT" = "yes" ] || [ ! -f "$INIT_DIR/$init_script" ]; then
        echo "Installing  $INIT_DIR/$init_script"
        cp -Rf "$TMP_DIR/init-scripts/$init_script" "$INIT_DIR/$init_script" &&
          chmod -Rf 755 "$INIT_DIR/$init_script" || true
      fi
    done
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d "$TMP_DIR/bin" ] && chmod -Rf 755 "$TMP_DIR/bin/" && cp -Rf "$TMP_DIR/bin/." "/usr/local/bin/"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d "$INIT_DIR" ] && chmod -Rf 755 "$INIT_DIR"/*.sh || true
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -d "$TMP_DIR" ] && rm -Rf "$TMP_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ -n "$CONFIG_CHECK_FILE" ] && [ ! -f "$CONFIG_DIR/$CONFIG_CHECK_FILE" ]; then
  echo "Can not find a config file: $CONFIG_DIR$CONFIG_CHECK_FILE"
  INSTALL_SH_EXIT_STATUS=1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# custom operations
[ -d "/etc/node" ] || mkdir -p /etc/node
[ -f "/etc/node/.env" ] && rm -Rf "/etc/node/.env"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cat <<EOF >"/etc/node/.env"
[ -n "\$NODE_MANAGER" ] || NODE_MANAGER="\$NODE_MANAGER" 
[ -n "\$NODE_VERSION" ] || NODE_VERSION="\$NODE_VERSION" 

EOF
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Install fnm
echo NODE_MANAGER: $NODE_MANAGER
echo NODE_VERSION: $NODE_VERSION
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$NODE_MANAGER" = "fnm" ]; then
  curl -q -LSsf "https://fnm.vercel.app/install" -o /tmp/install-fnm && chmod 755 /tmp/install-fnm
  /tmp/install-fnm --skip-shell --install-dir "/usr/share/node-managers/fnm" && rm -Rf "/tmp/install-fnm"
  [ -f "/usr/share/node-managers/fnm/fnm" ] && export PATH="/usr/share/node-managers/fnm:$PATH" && chmod +x "/usr/share/node-managers/fnm/fnm" && ln -sf "/usr/share/node-managers/fnm/fnm" "/usr/bin/fnm"
  [ -n "$(command -v fnm 2>/dev/null)" ] && eval "$(fnm env)" && fnm use --install-if-missing ${NODE_VERSION:-latest} || { echo "Failed to install fnm" && exit 1; }
elif [ "$NODE_MANAGER" = "nvs" ]; then
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  git clone --depth 1 "https://github.com/jasongin/nvs" "/usr/share/node-managers/nvs"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup node
[ -z "$(command -v node -v 2>/dev/null)" ] && echo "failed to install node" && exit 2 || node -v | grep ${NODE_VERSION:-latest}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
git clone --depth 1 "https://github.com/devenvmgr/express-cors-api" "/usr/share/webapps/expressjs"
[ -f "/usr/share/webapps/expressjs/.env.sample" ] && cp "/usr/share/webapps/expressjs/.env.sample" "/usr/share/webapps/expressjs/.env"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "$TMP_DIR/config/bashrc" ] && mv -fv "$TMP_DIR/config/bashrc" "$HOME/.bashrc"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# End application
# eval "$BASH_SET_SAVED_OPTIONS"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# lets exit with code
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit $INSTALL_SH_EXIT_STATUS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
