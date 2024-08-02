#!/bin/bash

# get the distribution and version information
DISTRO=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

# check if the user is root
if [ "$(id -u)" -ne 0 ]; then
    # print error message and exit if not root
    echo "error: this script must be run as root."
    exit 1
fi

# determine installation method based on distribution and version
if [ "$DISTRO" = "ubuntu" ]; then
    case "$VERSION" in
    "20.04" | "18.04" | "16.04")
        INSTALL_METHOD="direct"
        ;;
    *)
        INSTALL_METHOD="ppa"
        ;;
    esac
elif [ "$DISTRO" = "debian" ]; then
    case "$VERSION" in
    "12" | "11" | "10" | "9" | "8")
        INSTALL_METHOD="direct"
        ;;
    *)
        INSTALL_METHOD="apt"
        ;;
    esac
else
    INSTALL_METHOD="direct"
fi

# install fastfetch directly for other distros with apt / debian 12 or older / ubuntu 20.04 or older
if [ "$INSTALL_METHOD" = "direct" ]; then
    curl -Lso /tmp/package.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
    DEBIAN_FRONTEND=noninteractive apt install -y /tmp/package.deb
else
    # add ppa for ubuntu 22.04 or newer
    if [ "$INSTALL_METHOD" = "ppa" ]; then
        # check if the 'add-apt-repository' command is available
        if ! command -v add-apt-repository >/dev/null 2>&1; then
            # print a message if 'add-apt-repository' command is not found
            echo "'add-apt-repository' command is not available."
            exit 1
        fi

        add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    fi
    # install fastfetch from ppa / directly (debian 13 or newer)
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y fastfetch
fi
