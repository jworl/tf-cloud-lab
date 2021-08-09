#!py

# victim:
#     user.present:
#         - fullname: Scare Crow
#         - password: dummyMcv!ct1m
# {% if grains['os_family'] == 'Windows' %}
#         - groups:
#             - Users
#             - Remote Desktop Users
# {% endif %}


def _ACTION(IDENTITY, VICTIMS, OS):
    actions = {}


    for victim, data in VICTIMS.items():
        saltstate_id = "{}_{}".format(IDENTITY, victim)
        actions[saltstate_id] = {
            'user.present': [
                {'name': victim},
                {'fullname': data['fullname']},
                {'password': data['password']}
            ]
        }

        if OS == "Windows":
            actions[saltstate_id]['user.present'].extend([{'groups':['Users', 'Remote Desktop Users']}])
        elif OS == "Linux":
            actions[saltstate_id]['user.present'].extend([{'hash_password': True}])

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

    if 'victims' in __pillar__:
        return _ACTION(identity, __pillar__['victims'], __grains__['kernel'])
    else:
        message = "pillar missing victims"
        return _FAIL(identity, message)
