import ConfigParser
import sys
import getopt
from lib.LabelManager import LabelManager


def print_help():
    print
    print 'This program copies all labels from the server repository to another repository, defined as argument.'
    print 'Existig Labels get updated to the values given my the server repository.'
    print
    print 'Usage:', sys.argv[0], '-r <repository>'
    print
    print 'Optional Arguments:'
    print '    -r, --repository=<repository>: repository which should be updated'
    print '    --init: this means you want to initialize an new repository, existing labels will be deleted'
    print

initialize = False

try:
    opts, args = getopt.getopt(sys.argv[1:], "hr:", ["init","repository="])
except getopt.GetoptError:
    print_help()
    sys.exit(2)

repository = ''

for opt, arg in opts:
    if opt == '-h':
        print_help()
        sys.exit()
    elif opt in ("-r", "--repository"):
        repository = arg
    elif opt == '--init':
        initialize = True
    else:
        print_help()
        sys.exit()

if repository == '' and initialize:
    print_help()
    sys.exit()

config = ConfigParser.RawConfigParser()
labels = LabelManager(config)

if initialize:
    labels.delete_all_labels(repository)
    serverLabels = labels.get_all_labels()
    labels.create_labels(repository, serverLabels)

elif repository == '':
    serverLabels = labels.get_all_labels()
    labels.create_labels('activity', serverLabels)
    labels.create_labels('files_accesscontrol', serverLabels)
    labels.create_labels('files_automatedtagging', serverLabels)
    labels.create_labels('files_pdfviewer', serverLabels)
    labels.create_labels('files_retention', serverLabels)
    labels.create_labels('files_texteditor', serverLabels)
    labels.create_labels('files_videoplayer', serverLabels)
    labels.create_labels('firstrunwizard', serverLabels)
    labels.create_labels('gallery', serverLabels)
    labels.create_labels('networkconfig', serverLabels)
    labels.create_labels('nextcloud_announcements', serverLabels)
    labels.create_labels('notifications', serverLabels)
    labels.create_labels('password_policy', serverLabels)
    labels.create_labels('serverinfo', serverLabels)
    labels.create_labels('survey_client', serverLabels)
    labels.create_labels('templateeditor', serverLabels)
    labels.create_labels('user_saml', serverLabels)

else:
    serverLabels = labels.get_all_labels()
    labels.create_labels(repository, serverLabels)
