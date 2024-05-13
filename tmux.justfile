SESSION_NAME := "bridgetest"

# clean up data then kill and create a new tmux session
tmux-session:
  just clean
  tmux kill-session -t {{SESSION_NAME}} 2>/dev/null || true
  tmux new-session -d -s {{SESSION_NAME}} -n 0

tmux-celestia:
  tmux send-keys -t {{SESSION_NAME}}:0.1 \
    'just init-celestia' C-m \
    'just start-celestia-node' C-m

tmux-astria:
  tmux split-window -v -t {{SESSION_NAME}}
  tmux send-keys -t {{SESSION_NAME}}:0.2 \
    'just setup-astria' C-m  \
    'just start-astria' C-m

tmux-cometbft:
  tmux split-window -v -t {{SESSION_NAME}}
  tmux send-keys -t {{SESSION_NAME}}:0.3 \
    'just start-cometbft' C-m

tmux-hermes:
  tmux split-window -v -t {{SESSION_NAME}}
  tmux send-keys -t {{SESSION_NAME}}:0.4 \
    'just setup-hermes' C-m \
    'just setup-hermes-ibc' C-m \
    'just start-hermes' C-m

# attach to the tmux session
tmux-attach:
  tmux attach-session -t {{SESSION_NAME}}

# Run all commands in tmux
run-tmux:
  #!/bin/sh
  just tmux-session
  just tmux-celestia
  sleep 3
  just tmux-astria
  sleep 5
  just tmux-cometbft
  sleep 3
  just tmux-hermes
  just tmux-attach
