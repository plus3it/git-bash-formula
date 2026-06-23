# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}

{%- set pkg = git_bash.get('pkg', {}) %}
{%- set prefix_path = pkg.get('prefix', 'C:\\Program Files\\Git') %}
{%- set version = pkg.get('version', '2.54.0') %}

{%- set base = "https://github.com/git-for-windows/git/releases/download" %}
{%- set release_dir = "v" ~ version ~ ".windows.1" %}
{%- set file_name = "Git-" ~ version ~ "-64-bit.tar.bz2" %}
{%- set source_url = [base, release_dir, file_name] | join("/") %}

Configure Installation Directory:
  file.directory:
    - makedirs: true
    - name: {{ prefix_path | json }}

Extract Git Bash Archive:
  archive.extracted:
    - archive_format: tar
    - enforce_toplevel: false
    - name: {{ prefix_path | json }}
    - overwrite: true
    - require:
      - file: Configure Installation Directory
    - source: {{ source_url }}
