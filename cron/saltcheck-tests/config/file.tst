# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set cron = salt['pillar.get']('cron', {}) %}

{%- for task, task_options in cron.get('tasks', {}).items() %}
{%-   set cron_type = task_options.type|d('present') %}

validate_cron.{{ task }}_{{ cron_type }}:
  module_and_function: cron.get_entry
  args:
    - {{ task_options.user|d('root') }}
    - {{ task }}
  {%- if cron_type == 'absent' %}
  assertion: assertFalse
  {%- else %}
  assertion: assertEqual
  assertion_section: identifier
  expected-return: {{ task }}
  {%- endif %}

{%-   if cron_type == 'present' %}
validate_cron.{{ task }}_commented:
  module_and_function: cron.get_entry
  args:
    - {{ task_options.user|d('root') }}
    - {{ task }}
  assertion: {{ 'assertTrue' if task_options.commented|d(False) else 'assertFalse' }}
  assertion_section: commented

{#-     Note: `special` is `spec` in the module #}
{%-     for section in ['minute', 'hour', 'daymonth', 'month', 'dayweek', 'comment', 'spec'] %}
{%-       if section in task_options %}
{%-         set expected = task_options[section] %}
validate_cron.{{ task }}_{{ section }}:
  module_and_function: cron.get_entry
  args:
    - {{ task_options.user|d('root') }}
    - {{ task }}
  assertion: {{ 'assertLessEqual' if expected == 'random' else 'assertEqual' }}
  assertion_section: {{ section }}
  expected-return: '{{ 0 if expected == 'random' else expected }}'
{%-       endif %}
{%-     endfor %}
{%-   endif %}

{%- endfor %}

{%- for env, env_options in cron.get('env', {}).items() %}
{%-   set env_type = env_options.type|d('present') %}

validate_cron.{{ env }}_{{ env_type }}:
  module_and_function: cron.raw_cron
  args:
    - {{ env_options.user|d('root') }}
  assertion: {{ 'assertNotIn' if env_type == 'absent' else 'assertIn' }}
  expected-return: '{{ env_options.name }}={{ env_options.value }}'

{%- endfor %}
