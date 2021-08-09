#!py

def _ACTION(IDENTITY, SYSCTL):
    actions = {}

    for param,val in SYSCTL.iteritems():
        saltstate_id = '{0}_{1}'.format(IDENTITY, param)
        actions[saltstate_id] = {
            'sysctl.present': [
                {'name': param},
                {'value': val}
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

    if 'sysctl' in __pillar__:
        return _ACTION(identity, __pillar__['sysctl'])
    else:
        message = "pillar missing sysctl"
        return _FAIL(identity, message)
