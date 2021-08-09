#!py

def _ACTION(IDENTITY, SELINUX):
    actions = {}

    for app, bools in SELINUX.items():
        for b in bools:
            saltstate_id = '{0}_{1}_{2}_selinux'.format(IDENTITY, app, b)

            actions[saltstate_id] = {
                'selinux.boolean': [
                    {'name': b},
                    {'value': 1},
                    {'persist': True},
                    {'onlyif': 'getsebool {0}'.format(b)}
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

    if 'selinux' in __pillar__:
        return _ACTION(identity, __pillar__['selinux'])
    else:
        message = "pillar missing selinux, maybe selinux is not available on this box"
        return _FAIL(identity, message)
