#version 1
bootrap:
  local.state.highstate:
    - tgt: {{ data['id'] }}
