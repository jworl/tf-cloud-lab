#!py

def _ACTION(REPOS):
    actions = {}

    for r in REPOS:
        actions[r] = {
            'git.latest': REPOS[r]
        }

    return actions

def _FAIL(i, m):
    event = {}
    event_id = 'salt/' + i + '/slack'

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
    if 'git' in __pillar__:
        return _ACTION(__pillar__['git'])
    else:
        identity = __grains__['localhost']
        message = "pillar missing git"
        return _FAIL(identity, message)
