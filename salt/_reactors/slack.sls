#version 1
slackchannel_notification:
  local.state.sls:
    - tgt: salt
    - arg:
      - slack
    - kwarg:
        pillar:
          slack:
            message: "{{ data['data']['message'] }}"
            from_name: {{ data['id'] }}
