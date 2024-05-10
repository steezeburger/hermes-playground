import 'build.justfile'
import 'evm.justfile'
import 'helpers.justfile'

logfilename := "initnode-$(date +%Y-%m-%d).log"

# list all available commands
default:
  @just --list

# delete all the config and data directories
clean:
  rm -rf ~/.celestia
  rm -rf /tmp/astria_db
  rm -rf ~/.cometbft
  rm -rf ~/.hermes

# init the celestia node. logs to a file so we can extract the mnemonic
init-celestia:
  cd celestia-app && ./initnode.sh > {{logfilename}} 2>&1

# start the celestia node
start-celestia-node:
  ./celestia-app/celestia-appd start \
    --home ~/.celestia \
    --api.enable \
    --api.enabled-unsafe-cors \
    --grpc.enable \
    --p2p.seeds="" \
    --rpc.laddr=tcp://localhost:27050 \
    --p2p.laddr=tcp://localhost:26650

# setup hermes config. add key for chain celestia-local
setup-hermes:
  #!/bin/sh
  # create needed directores
  mkdir -p ~/.hermes/keys/celestia-local/keyring-test/
  cp ./hermes/config-astria-celestia.toml ~/.hermes/config.toml
  sed -i.'bak' "s#id = 'celestia'#id = 'celestia-local'#g" ~/.hermes/config.toml
  MNEMONIC=$(sed -n '13p' ./celestia-app/{{logfilename}})
  ./hermes/target/debug/hermes keys add \
    --chain celestia-local \
    --mnemonic-file /dev/stdin <<< "$MNEMONIC"

# setup astria
setup-astria:
  # ensure directory exists
  mkdir -p ~/.hermes/keys/astria/keyring-test/
  # copy key into the keyring
  cp ./configs/astria-wallet.json ~/.hermes/keys/astria/keyring-test/

# start astria. NOTE: need to be in branch noot/ibc-host-interface
start-astria:
  #!/bin/sh
  cd ~/code/astria/repos/astria/crates/astria-sequencer
  just run

# start cometbft. NOTE: need to be in branch noot/ibc-host-interface
start-cometbft:
  #!/bin/sh
  cometbft init
  GENPATH=$HOME/.cometbft/config/genesis.json
  mv $GENPATH $GENPATH.bak
  # put contents of test-genesis-app-state.json into genesis.json as app_state key
  # set chain_id
  jq -s '.[1] * {"app_state": .[0], "chain_id": "astria"}' \
    ./configs/test-genesis-app-state.json \
    $GENPATH.bak > $GENPATH
  sed -i'.bak' 's/timeout_commit = "1s"/timeout_commit = "2s"/g' ~/.cometbft/config/config.toml
  cometbft node

# create hermes clients
create-hermes-clients:
  # client on astria, tracking celestia
  ./hermes/target/debug/hermes create client --host-chain astria --reference-chain celestia-local
  # client on celestia, tracking astria
  ./hermes/target/debug/hermes create client --host-chain celestia-local --reference-chain astria

# create hermes connection
create-hermes-connection:
  ./hermes/target/debug/hermes create connection --a-chain celestia-local --a-client 07-tendermint-0 --b-client 07-tendermint-0

# create hermes channel
create-hermes-channel:
  ./hermes/target/debug/hermes create channel --a-chain celestia-local --a-connection connection-0 --a-port transfer --b-port transfer

# init hermes. creates clients, connection, channel
init-hermes: create-hermes-clients create-hermes-connection create-hermes-channel query-hermes-channel

# start-hermes
start-hermes:
  ./hermes/target/debug/hermes start
