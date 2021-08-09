#!py

def _ACTION(IDENTITY, PIP):
    actions = {}
    actions['include'] = ['packages']

    for group,packs in PIP.iteritems():
        for pack in packs:
            saltstate_id = '{0}_{1}'.format(group, pack)
            actions[saltstate_id] = {
                'pip.installed': [
                    {'name': pack},
                    {'require': [
                        {'sls': 'packages'}
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

    if 'pip' in __pillar__:
        return _ACTION(identity, __pillar__['pip'])
    else:
        message = "pillar missing pip"
        return _FAIL(identity, message)
