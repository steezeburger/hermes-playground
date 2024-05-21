SESSION_NAME := "bridgetest"

# kill and create a new tmux session
tmux-session:
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

tmux-attach:
  tmux attach-session -t {{SESSION_NAME}}

tmux-kill:
  tmux kill-session -t {{SESSION_NAME}} 2>/dev/null || true
  ps aux | grep -v grep | grep -E 'composer|conductor|sequencer|cometbft|celestia|hermes' | awk '{print $2}' | xargs kill -9

# clean then run everything in tmux session. this might fail if sequencer is being built the first time.
run-tmux:
  #!/bin/sh
  just clean
  just tmux-session
  just tmux-celestia
  sleep 5
  just tmux-astria
  sleep 10
  just tmux-cometbft
  sleep 5
  just tmux-hermes
  just tmux-attach
