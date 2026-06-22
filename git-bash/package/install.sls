# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}

git-bash-package-install-pkg-installed:
  pkg.installed:
    - name: {{ git_bash.pkg.name }}
