#! /usr/bin/env python
# vim: fileencoding=utf-8 :

import os
import sys
import time
import thread


STDOUT_FLUSH_INTERVAL = 1


def import_eggs():
  for root, dirs, files in os.walk('/Library/MakerBot/python/', False):
    for filename in files:
      if not filename.endswith('.egg'): continue
      sys.path.insert(0, os.path.join(root, filename))


def flush_buffer_forever(interval):
  try:
    while True:
      sys.stdout.flush()
      time.sleep(interval)
  except:
    pass


import_eggs()
thread.start_new_thread(flush_buffer_forever, (STDOUT_FLUSH_INTERVAL,))


import conveyor.client.__main__


if '__main__' == __name__:
    sys.exit(conveyor.client.__main__._main(sys.argv))

