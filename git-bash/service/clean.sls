# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}

git-bash-service-clean-service-dead:
  service.dead:
    - name: {{ git_bash.service.name }}
    - enable: False
