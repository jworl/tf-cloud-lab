#!py

# slack-message:
#   slack.post_message:
#     - channel: '#general'
#     - from_name: SuperAdmin
#     - message: 'This state was executed successfully.'
#     - api_key: {{ pillar['slack'] }}

def _ACTION(IDENTITY, SLACK):
    actions = {}

    saltstate_id = '{0}_{1}'.format(IDENTITY, SLACK['channel'])
    actions[saltstate_id] = {
        'slack.post_message': [
            {'channel': SLACK['channel']},
            {'from_name': SLACK['from_name']},
            {'message': SLACK['message']},
            {'api_key': SLACK['api_key']}
        ]
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
    identity = __grains__['localhost']
    if 'slack' in __pillar__:
        return _ACTION(identity, __pillar__['slack'])
    else:
        message = "missing slack data in pillar"
        return _FAIL(identity, message)
