# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import cron with context %}

cron-service-running:
{%- if cron.enabled %}
  service.running:
    - name: {{ cron.service }}
    - enable: true
{%- else %}
  service.dead:
    - name: {{ cron.service }}
    - enable: false
{%- endif %}
    - require:
      - pkg: cron-package-install
