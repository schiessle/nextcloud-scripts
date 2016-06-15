import requests
import json
import ConfigParser


class LabelManager:
    def __init__(self, config):
        """
        :param ConfigParser.RawConfigParser config: read config file
        """
        self.urlServerLabels = 'https://api.github.com/repos/nextcloud/server/labels'
        self.nextcloudBaseUrl = 'https://api.github.com/repos/nextcloud/'
        config.read('labels.cfg')
        self.authToken = config.get('auth', 'token')

    def get_server_labels(self):
        """
        get all labels from the Nextcloud server repository
        :return: list of all server labels
        """
        response = requests.get(self.urlServerLabels)
        data = json.loads(response.content)
        return data

    def create_labels(self, repo, labels):
        """
        create labels on the given Nextcloud repository
        :param string repo:
        :param string labels:
        """
        for label in labels:
            # skip the feature: labels because they are server specific
            if not label['name'].startswith('feature:'):
                print 'Create label: "' + label['name'] + '" (Color: #' + label['color'] + ')'
                url = self.nextcloudBaseUrl + repo + '/labels'
                payload = {
                    'name': label['name'],
                    'color': label['color'],
                }
                # Adding empty header as parameters are being sent in payload
                headers = {'Authorization': 'token ' + self.authToken}
                print 'Header:', headers
                print 'URL:', url
                requests.post(url, data=json.dumps(payload), headers=headers)
