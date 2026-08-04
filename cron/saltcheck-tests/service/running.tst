# -*- coding: utf-8 -*-
# vim: ft=sls
#
# Debian/Ubuntu only - both use the `cron` service.

verify_cron.service_available:
  module_and_function: service.available
  args:
    - cron
  assertion: assertTrue

verify_cron.service_enabled:
  module_and_function: service.enabled
  args:
    - cron
  assertion: assertTrue

verify_cron.service_running:
  module_and_function: service.status
  args:
    - cron
  assertion: assertTrue
