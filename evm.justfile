# just commands to aid in running the evm

deploy-evm:
  #!/bin/sh
  cd ~/code/astria/repos/astria/charts
  echo "Deploying ingress controller..." && just deploy-ingress-controller > /dev/null
  just wait-for-ingress-controller > /dev/null
  helm install -n astria-dev-cluster evm-chain-chart ./evm-rollup \
    -f ~/code/astria/projects/get-hermes-running/configs/evm-chart-values.yaml

delete-evm:
  helm uninstall evm-chain-chart -n astria-dev-cluster

init-bridge-account:
  #!/bin/sh
  cd ~/code/astria/repos/astria-cli-go
  just run sequencer bridge init astria \
    --url http://localhost:26657 \
    --keyfile /Users/jessesnyder/.astria/keyfiles/UTC--2024-05-09T19:29:48-06:00--edf770a8915cd3f70309c918c3d16671f59161e2
