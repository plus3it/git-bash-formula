# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}
{%- set config = git_bash.get('config') or {} %}
{%- set pkg = git_bash.get('pkg') or {} %}

{%- set install_prefix = config.get(
      'install_root', 'C:\\Program Files\\Git'
    ) %}
{%- set skip_verify = false if pkg.get('download_sig') else true %}
{%- set archive_ext = pkg.get('archive_type') or 'exe' %}
{%- set match_suffix = "-64-bit." ~ archive_ext %}
{%- set url_ns = {
      'source_url': pkg.get('download_uri', '')
    } %}

{%- if not url_ns.source_url %}
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
      {%- if asset_name.endswith(match_suffix) %}
        {%- do url_ns.update({
              'source_url': asset.get('browser_download_url')
            }) %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{%- if url_ns.source_url and url_ns.source_url.endswith('tar.bz2') %}
Configure Installation Directory:
  file.directory:
    - makedirs: true
    - name: {{ install_prefix | json }}

Extract Git Bash Archive:
  archive.extracted:
    - archive_format: tar
    - enforce_toplevel: false
    - force: true
    - if_missing: {{ [install_prefix, 'git-bash.exe'] | join('\\') | json }}
    - name: {{ install_prefix | json }}
    - overwrite: true
    - require:
      - file: Configure Installation Directory
    - skip_verify: {{ skip_verify }}
    - source: {{ url_ns.source_url | json }}
{%- elif url_ns.source_url and url_ns.source_url.endswith('exe') %}
  {%- set temp_dir = salt['environ.get'](
        'TEMP', 'C:\\Windows\\Temp'
      ) %}
  {%- set installer_path = [
        temp_dir, "git-bash-installer.exe"
      ] | join("\\") %}
  {%- set cmd_args = [
        "/VERYSILENT",
        "/NORESTART",
        "/CLOSEAPPS",
        "/SUPPRESSMSGBOXES",
        ['/DIR=', '"', install_prefix, '"'] | join
      ] | join(" ") %}
  {%- set cmd_exec = [
        "Start-Process",
        "-FilePath '" ~ installer_path ~ "'",
        "-ArgumentList '" ~ cmd_args ~ "'",
        "-NoNewWindow",
        "-Wait"
      ] | join(" ") %}
  {%- set check_path = [
        install_prefix, "git-bash.exe"
      ] | join("\\") %}
  {%- set unless_cmd = [
        "if (Test-Path",
        "'" ~ check_path ~ "') { exit 0 } else { exit 1 }"
      ] | join(" ") %}

Download Git Bash Installer:
  file.managed:
    - name: {{ installer_path | json }}
    - skip_verify: {{ skip_verify }}
    - source: {{ url_ns.source_url | json }}

Run Git Bash Installer:
  cmd.run:
    - name: {{ cmd_exec | json }}
    - require:
      - file: Download Git Bash Installer
    - shell: powershell
    - unless: {{ unless_cmd | json }}
{%- else %}
Unsupported Install Type:
  test.show_notification:
    - text: |
        -----------------------------------
        Support for other installation-
        types not yet available
        -----------------------------------
{%- endif %}
