# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

git-bash-config-file-file-managed:
  file.managed:
    - name: {{ git_bash.config }}
    - source: {{ files_switch(['example.tmpl'],
                              lookup='git-bash-config-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ git_bash.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        git_bash: {{ git_bash | json }}
