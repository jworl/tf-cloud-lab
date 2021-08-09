packages:
    base:
        - firefox_x64
        - chrome
{% if grains['osfinger'] == 'Windows-2019Server' %}
        - chocolatey
{% endif %}

feature_rm:
    - Windows-Defender
