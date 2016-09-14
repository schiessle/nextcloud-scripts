import requests
import json
import ConfigParser


class LabelManager:

    def __init__(self, config):
        """
        :param ConfigParser.RawConfigParser config: read config file
        """
        self.nextcloudBaseUrl = 'https://api.github.com/repos/nextcloud/'
        config.read('github.cfg')
        self.authToken = config.get('auth', 'token')
        self.headers = {'Authorization': 'token ' + self.authToken}

    def get_all_labels(self, repo='server'):
        """
        get all labels from the Nextcloud server repository
        :return: list of all server labels
        """
        url = self.nextcloudBaseUrl + repo + '/labels?per_page=100'
        response = requests.get(url)
        data = json.loads(response.content)
        return data

    def create_labels(self, repo, labels):
        """
        create labels on the given Nextcloud repository
        :param string repo:
        :param string labels:
        """
        url = self.nextcloudBaseUrl + repo + '/labels'

        for label in labels:
            # skip the feature: labels because they are server specific
            if not label['name'].startswith('feature:'):
                payload = {
                    'name': label['name'],
                    'color': label['color'],
                }
                response = requests.get(url + '/' + label['name'], headers=self.headers)
                if response.status_code == 403:
                    print '[' + repo + '] Rate limit reached'
                    return


                # if the label already exists we update it, otherwise we create a new one
                if response.status_code == 200:
                    checkLabel = json.loads(response.content)
                    if not label['color'] == label['color']:
                        print '[' + repo + '] Update label: "' + label['name'] + '" (Color: #' + label['color'] + ')'
                        requests.patch(url + '/' + label['name'], data=json.dumps(payload), headers=self.headers)
                    else:
                        print '[' + repo + '] Skip unchanged label: "' + label['name'] + '"'

                else:
                    print '[' + repo + '] Create label: "' + label['name'] + '" (Color: #' + label['color'] + ')'
                    requests.post(url, data=json.dumps(payload), headers=self.headers)
            else:
                print '[' + repo + '] Skip feature label: "' + label['name'] + '"'

    def delete_all_labels(self, repo):
        """
        delete all labels from a give repository
        :param repo:
        :return:
        """
        if repo == 'server':
            return

        url = self.nextcloudBaseUrl + repo + '/labels/'
        labels = self.get_all_labels(repo)

        for label in labels:
            print 'Delete label: "' + label['name']
            requests.delete(url + label['name'], headers=self.headers)
