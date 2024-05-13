# just commands to aid in running the evm

deploy-cluster:
  #!/bin/sh
  cd ~/code/astria/repos/astria/charts
  just deploy-cluster

delete-cluster:
  #!/bin/sh
  cd ~/code/astria/repos/astria/charts
  just delete-all

deploy-evm:
  #!/bin/sh
  cd ~/code/astria/repos/astria/charts
  echo "Deploying ingress controller..." && just deploy-ingress-controller > /dev/null
  just wait-for-ingress-controller > /dev/null
  helm install -n astria-dev-cluster evm-chain-chart ./evm-rollup \
    -f ~/code/astria/projects/get-hermes-running/configs/evm-chart-values.yaml

delete-evm:
  rm -rf ~/.astriageth
  helm uninstall evm-chain-chart -n astria-dev-cluster
