# get celestia address
get-celestia-address:
  ./celestia-app/celestia-appd keys show validator -a --keyring-backend="test" --home=~/.celestia

# get celestia balance
get-celestia-balance:
  ./celestia-app/celestia-appd query bank balances \
    $(./celestia-app/celestia-appd keys show validator -a --keyring-backend="test" --home=~/.celestia) \
    --home=~/.celestia \
    --node tcp://localhost:27050

# send tx on celestia
send-celestia-balance from to amount:
  ./celestia-app/celestia-appd tx bank send \
    {{from}} \
    {{to}} \
    {{amount}} \
    --home=~/.celestia \
    --node tcp://localhost:27050 \
    --chain-id celestia-local \
    --fees 420utia

# get astria balance
get-astria-balance address:
    ~/code/astria/repos/astria/target/debug/astria-cli sequencer balance get \
        {{address}} \
        --sequencer-url=http://localhost:26657

# bridge funds from celestia to astria
bridge-c-2-a:
  ./hermes/target/debug/hermes tx ft-transfer \
    --timeout-seconds 1000 \
    --dst-chain astria \
    --src-chain celestia-local \
    --src-port transfer \
    --src-channel channel-0 \
    --amount 1000000 \
    --denom=utia

# bridge funds from astria to celestia
bridge-a-2-c:
  ./hermes/target/debug/hermes tx ft-transfer \
    --timeout-seconds 1000 \
    --dst-chain celestia-local \
    --src-chain astria \
    --src-port transfer \
    --src-channel channel-0 \
    --amount 500000 \
    --denom=transfer/channel-0/utia

# query hermes channel
query-hermes-channel:
  ./hermes/target/debug/hermes query channels \
    --show-counterparty \
    --chain celestia-local
