#!py

def _ACTION(IDENTITY, REPOS):
    actions = {}

    for r in REPOS:
        if r == '_RPM-GPG-KEYS':
            for path, specs in REPOS[r].items():
                gpg_id = '{0}_{1}'.format(IDENTITY, path)
                actions[gpg_id] = {
                    'file.managed': [
                        {'name': path},
                        {'contents': specs['content']}
                    ]
                }

                if 'permissions' in specs:
                    actions[gpg_id]['file.managed'].extend(specs['permissions'])
        else:
            actions[r + '_repository'] = {
                'pkgrepo.managed': REPOS[r]
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
    if 'repos' in __pillar__:
        return _ACTION(identity, __pillar__['repos'])
    else:
        message = "pillar missing repos"
        return _FAIL(identity, message)
