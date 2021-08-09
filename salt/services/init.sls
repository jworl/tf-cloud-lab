#!py
import re

def _ACTION(IDENTITY, SERVICES):
    actions = {}

    actions['include'] = ['packages']

    if 'selinux' in __pillar__ and __grains__['selinux']['enabled'] is True:
        actions['include'].append('selinux')

    if 'pip' in __pillar__:
        actions['include'].append('pip')

    for pack, service in SERVICES.items():
        saltstate_id = '{0}_{1}'.format(IDENTITY, service)

        actions[saltstate_id] = {
            'service.running': [
                {'name': service},
                {'enable': True}
            ]
        }

        if service in __pillar__:
            for path, specs in __pillar__[service].items():
                config_id = '{0}_{1}'.format(saltstate_id, path)
                if re.match('^MKNOD_', path):
                    extention = 'file.mknod'
                    if re.match('^MKNOD_FIFO_', path):
                        mknod_type = 'p'
                    elif re.match('^MKNOD_CHAR_', path):
                        mknod_type = 'c'
                    elif re.match('^MKNOD_BLOCK', path):
                        mknod_type = 'b'
                    else:
                        MESSAGE = 'invalid MKNOD type'
                        return _FAIL(IDENTITY, MESSAGE)
                    actions[config_id] = {
                        'file.mknod': [
                            {'name': path.split('_')[2]},
                            {'ntype': mknod_type},
                            {'watch_in': [
                                {'service': saltstate_id}
                            ]}
                        ]
                    }
                else:
                    extention = 'file.managed'
                    actions[config_id] = {
                        'file.managed': [
                            {'name': path},
                            {'contents': specs['content']},
                            {'watch_in': [
                                {'service': saltstate_id}
                            ]}
                        ]
                    }

                    if re.match('.+\.service$', path):
                        actions['{0}_daemon_reload'.format(saltstate_id)] = {
                            'cmd.run': [
                                {'name': 'systemctl daemon-reload'},
                                {'watch': [
                                    {'file': config_id}
                                ]}
                            ]
                        }

                if 'permissions' in specs:
                    actions[config_id][extention].extend(specs['permissions'])

                if 'makedirs' in specs and specs['makedirs'] is True:
                    actions[config_id][extention].append({'makedirs': True})

                if '{0}_daemon_reload'.format(saltstate_id) in actions:
                    actions[saltstate_id]['service.running'].extend([{'watch': [{'cmd': '{0}_daemon_reload'.format(saltstate_id)}]}])



        fail_id = '{0}_fail'.format(saltstate_id)
        actions[fail_id] = {
            'pkg.installed': [
                {'name': pack},
                {'onfail': [
                    {'service': saltstate_id}
                ]}
            ]
        }

    return actions

def _FAIL(i, m):
    event = {}

    event_id = 'salt/' + i + '/failure'

    event['send_event'] = {
        'event.send': [
            {'name': event_id},
            {'data': {
                "message": m
            }}
        ]
    }

    return event

def run():
    identity = __grains__['localhost']

    if 'services' in __pillar__:
        return _ACTION(identity, __pillar__['services'])
    else:
        message = "pillar missing services"
        return _FAIL(identity, message)
