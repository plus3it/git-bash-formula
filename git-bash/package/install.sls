# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}
{%- set config = git_bash.get('config', {}) %}
{%- set pkg = git_bash.get('pkg', {}) %}
{%- set install_prefix = config.get(
      'install_root', 'C:\\Program Files\\Git'
    ) %}
{%- set source_url = pkg.get('download_uri') %}
{%- set skip_verify = false if pkg.get('download_sig') else true %}

{%- if not source_url %}
  {%- set api_path = "git-for-windows/git/releases/latest" %}
  {%- set api_url = [
        "https://api.github.com/repos", api_path
      ] | join("/") %}
  {%- set headers = {"User-Agent": "SaltStack"} %}
  {%- set res = salt["http.query"](api_url, headers=headers) %}
  {%- if res and res.get("body") %}
    {%- set release_data = res["body"] | load_json %}
    {%- for asset in release_data.get("assets", []) %}
      {%- set asset_name = asset.get("name", "") %}
      {%- if asset_name.endswith("-64-bit.tar.bz2") %}
        {%- set source_url = asset.get("browser_download_url") %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{%- if source_url and source_url.endswith('tar.bz2') %}
Configure Installation Directory:
  file.directory:
    - makedirs: true
    - name: {{ install_prefix | json }}

Extract Git Bash Archive:
  archive.extracted:
    - archive_format: tar
    - enforce_toplevel: false
    - force: true
    - name: {{ install_prefix | json }}
    - overwrite: true
    - require:
      - file: Configure Installation Directory
    - skip_verify: {{ skip_verify }}
    - source: {{ source_url | json }}
{%- else %}
Unsupported Install-type:
  test.show_notification:
    - text: |
        -----------------------------------
        Support for other installation-
        types not yet available
        -----------------------------------
{%- endif %}
