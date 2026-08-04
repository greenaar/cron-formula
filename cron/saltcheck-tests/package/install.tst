# -*- coding: utf-8 -*-
# vim: ft=sls
#
# Debian/Ubuntu only - both use the `cron` package.

verify_cron.package:
  module_and_function: pkg.version
  args:
    - cron
  assertion: assertNotEmpty
