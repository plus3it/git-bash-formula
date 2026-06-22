# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}

include:
  - {{ sls_config_clean }}

git-bash-package-clean-pkg-removed:
  pkg.removed:
    - name: {{ git_bash.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
