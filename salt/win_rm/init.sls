{% set RM = pillar['feature_rm'] %}

uninstall_features:
    win_servermanager.removed:
        - features: {{ RM }}
        - restart: True
