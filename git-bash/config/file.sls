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

{%- set bash_target = [install_prefix, 'bin', 'bash.exe'] | join('\\') %}
{%- set icon_target = [
      install_prefix, 'mingw64', 'share', 'git', 'git-for-windows.ico'
    ] | join('\\') %}

{%- set desktop_lnk = [
      'C:\\Users\\Public\\Desktop', 'Git Bash.lnk'
    ] | join('\\') %}
{%- set start_lnk = [
      'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs',
      'Git Bash.lnk'
    ] | join('\\') %}

Configure Corporate Shell Profile:
  file.managed:
    - context:
        git_bash: {{ git_bash | json }}
    - name: {{ profile_path | json }}
    - require:
      - sls: {{ sls_package_install }}
    - source: {{ files_switch(['corporate.sh.tmpl'],
                              lookup='Configure Corporate Shell Profile'
                  )
              }}
    - template: jinja

Configure System Gitconfig File:
  ini.options_present:
    - name: {{ gitconfig_path | json }}
    - require:
      - sls: {{ sls_package_install }}
    - sections:
        core:
          autocrlf: true
          longpaths: true
        http:
          sslBackend: schannel

Create Git Bash Desktop Shortcut:
  shortcut.present:
    - arguments: '--login -i'
    - icon_index: 0
    - icon_location: {{ icon_target | json }}
    - name: {{ desktop_lnk | json }}
    - require:
      - sls: {{ sls_package_install }}
    - target: {{ bash_target | json }}
    - working_dir: {{ install_prefix | json }}

Create Git Bash Start Menu Shortcut:
  shortcut.present:
    - arguments: '--login -i'
    - icon_index: 0
    - icon_location: {{ icon_target | json }}
    - name: {{ start_lnk | json }}
    - require:
      - sls: {{ sls_package_install }}
    - target: {{ bash_target | json }}
    - working_dir: {{ install_prefix | json }}
