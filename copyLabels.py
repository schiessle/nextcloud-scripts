import ConfigParser
import sys

from lib.LabelManager import LabelManager

if len(sys.argv) != 2:
    print 'This program copies all labels from the server repository to another repository, defined as argument'
    print 'Usage:', sys.argv[0], '<repository>'
    sys.exit(0)
else:
    repo = sys.argv[1]

config = ConfigParser.RawConfigParser()
labels = LabelManager(config)
serverLabels = labels.get_server_labels()
labels.create_labels(repo, serverLabels)
