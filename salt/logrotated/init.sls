#!py

def _logrotated(configs, selinux):
    actions = {}
    for key in configs:
        archive_id = 'logrotated_archive_dir_' + key
        actions[archive_id] = {
            'file.directory': [
                {'name': configs[key]['archive_dir']},
                {'user': configs[key]['user']},
                {'group': configs[key]['group']},
                {'makedirs': True},
                {'dir_mode': 755},
                {'file_mode': 644},
                {'recurse': [
                    'user', 'group', 'mode'
                ]}
            ]
        }
        name = '/etc/logrotate.d/' + key
        content = 'logrotated:logs:' + key + ':conf'
        conf_id = 'logrotated_conf_' + key
        actions[conf_id] = {
            'file.managed': [
                {'name': name},
                {'contents_pillar': content},
                {'user': 'root'},
                {'group': 'root'},
                {'mode': 644}
            ]
        }
        if selinux['enabled'] is True:
            selinux_id = 'logrotated_selinux_' + key
            actions[selinux_id] = {
                'module.wait': [
                    {'name': 'file.set_selinux_context'},
                    {'path': configs[key]['archive_dir']},
                    {'type': 'var_log_t'},
                    {'require': [{'file': archive_id}]}
                ]
            }
    return actions

def run():
    configs = __pillar__['logrotated']['logs']
    try:
        selinux = __grains__['selinux']
    except KeyError:
        selinux = {"enabled": False}
    return _logrotated(configs, selinux)
