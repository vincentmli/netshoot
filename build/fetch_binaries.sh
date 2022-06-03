#!/usr/bin/env bash
set -euo pipefail

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH=amd64
        ;;
    aarch64)
        ARCH=arm64
        ;;
esac

#https://github.com/ehids/ecapture/releases/download/v0.2.2/ecapture-v0.2.2-linux-x86_64.tar.gz
get_ecapture() {
  VERSION=$(get_latest_release ehids/ecapture | sed -e 's/^v//')
  ARCHX86="linux-x86_64"
  LINK="https://github.com/ehids/ecapture/releases/download/v${VERSION}/ecapture-v${VERSION}-${ARCHX86}.tar.gz"
  wget "$LINK" -O /tmp/ecapture-v${VERSION}-${ARCHX86}.tar.gz && tar zxvf /tmp/ecapture-v${VERSION}-${ARCHX86}.tar.gz && cp  ecapture-v${VERSION}-${ARCHX86}/ecapture /tmp/ecapture && chmod +x /tmp/ecapture
}

get_ctop() {
  VERSION=$(get_latest_release bcicen/ctop | sed -e 's/^v//')
  LINK="https://github.com/bcicen/ctop/releases/download/v${VERSION}/ctop-${VERSION}-linux-${ARCH}"
  wget "$LINK" -O /tmp/ctop && chmod +x /tmp/ctop
}

get_calicoctl() {
  VERSION=$(get_latest_release projectcalico/calicoctl)
  LINK="https://github.com/projectcalico/calicoctl/releases/download/${VERSION}/calicoctl-linux-${ARCH}"
  wget "$LINK" -O /tmp/calicoctl && chmod +x /tmp/calicoctl
}

get_termshark() {
  case "$ARCH" in
    "arm"*)
      echo "echo termshark does not yet support arm" > /tmp/termshark && chmod +x /tmp/termshark
      ;;
    *)
      VERSION=$(get_latest_release gcla/termshark | sed -e 's/^v//')
      if [ "$ARCH" == "amd64" ]; then
        TERM_ARCH=x64
      else
        TERM_ARCH="$ARCH"
      fi
      LINK="https://github.com/gcla/termshark/releases/download/v${VERSION}/termshark_${VERSION}_linux_${TERM_ARCH}.tar.gz"
      wget "$LINK" -O /tmp/termshark.tar.gz && \
      tar -zxvf /tmp/termshark.tar.gz && \
      mv "termshark_${VERSION}_linux_${TERM_ARCH}/termshark" /tmp/termshark && \
      chmod +x /tmp/termshark
      ;;
  esac
}

get_ecapture
get_ctop
get_calicoctl
get_termshark
