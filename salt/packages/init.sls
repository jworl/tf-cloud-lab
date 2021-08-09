#!py

def _ACTION(PACKAGES):
    actions = {}

    if 'repos' in __pillar__:
        actions['include'] = ['repos']

    for group, packs in PACKAGES.items():
        saltstate_id = '{0}_packages'.format(group)
        actions[saltstate_id] = {
            'pkg.installed': [
                {'pkgs': packs}
            ]
        }

        if 'repos' in __pillar__:
            requisite = [{'require':[{'sls':'repos'}]}]
            actions[saltstate_id]['pkg.installed'].extend(requisite)

    if 'services' in __pillar__:
        actions['service_packages'] = {
            'pkg.installed': [
                {'pkgs': list(__pillar__['services'])}
            ]
        }

        if 'repos' in __pillar__:
            requisite = [{'require':[{'sls':'repos'}]}]
            actions['service_packages']['pkg.installed'].extend(requisite)

        # for pack, service in __pillar__['services'].iteritems():
        #     saltstate_id = '{0}_service'.format(pack)
        #     actions[saltstate_id] = {
        #         'service.dead': [
        #             {'name': service},
        #             {'watch': [
        #                 {'pkg': 'service_packages'}
        #             ]}
        #         ]
        #     }

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

def run():
    if 'packages' in __pillar__:
        return _ACTION(__pillar__['packages'])
    else:
        identity = __grains__['localhost']
        message = "pillar missing packages"
        return _FAIL(identity, message)
