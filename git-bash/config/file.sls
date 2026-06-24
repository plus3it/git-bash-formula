# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

{%- set config = git_bash.get('config') or {} %}
{%- set install_prefix = config.get(
      'install_root', 'C:\\Program Files\\Git'
    ) %}
{%- set gitconfig_path = [install_prefix, 'etc', 'gitconfig'] | join('\\') %}
{%- set profile_path = [
      install_prefix, 'etc', 'profile.d', 'corporate.sh'
    ] | join('\\') %}

Configure Corporate Shell Profile:
  file.managed:
    - context:
        git_bash: {{ git_bash | json }}
    - name: {{ profile_path | json }}
    - require:
      - sls: {{ sls_package_install }}
    - source: {{ files_switch(['corporate.sh'],
                              lookup='Configure Corporate Shell Profile'
                 )
              }}
    - template: jinja

Configure System Gitconfig File:
  file.managed:
    - context:
        git_bash: {{ git_bash | json }}
    - name: {{ gitconfig_path | json }}
    - require:
      - sls: {{ sls_package_install }}
    - source: {{ files_switch(['gitconfig'],
                              lookup='Configure System Gitconfig File'
                 )
              }}
    - template: jinja
