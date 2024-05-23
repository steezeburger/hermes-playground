## Running
```bash
# start celestia, astria, cometbft, hermes
just run-tmux
# fund address being used with keplr wallet for development
just fund-keplr-address
# init bridge account on sequencer
just init-bridge-account
# deploy evm helm chart
just deploy-evm
```

## Manual testing playbook

```bash
# spin up everything
just run-tmux
# deploy geth
just deploy-evm
# bridge from celestia to astria account. this is just to get funds in the astria account
just bridge-c-2-a
# ensure astria account has utia balance
just get-astria-balance edf770a8915cd3f70309c918c3d16671f59161e2
# init bridge account
just init-bridge-account
# bridge lock tokens from astria to evm
just bridge-lock-tokens
# check evm account balance
cast balance --ether --rpc-url http://executor.astria.localdev.me 0x811b103446760C22b7386af8712d60AAF983F055
```
