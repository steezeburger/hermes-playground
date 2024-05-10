# justfile for building various things

# download and build cometbft
build-cometbft:
  #!/bin/sh
  git clone https://github.com/cometbft/cometbft
  cd cometbft
  # git checkout origin/v0.38.6
  git checkout 1519562
  export GOPATH=~/go
  make install

# download and untar celestia-appd
build-celestia:
  #!/bin/sh
  mkdir celestia-app
  cd celestia-app
  curl -LO https://github.com/celestiaorg/celestia-app/releases/download/v1.9.0/celestia-app_Darwin_arm64.tar.gz
  tar -zxvf celestia-app_Darwin_arm64.tar.gz

# get hermes
get-hermes:
  git clone git@github.com:astriaorg/hermes.git
  cd hermes && git checkout noot/bump-deps

# build hermes binary
build-hermes:
  cd hermes && cargo build --bin hermes
