# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as git_bash with context %}

{%- set config = git_bash.get('config') or {} %}
{%- set install_prefix = config.get(
      'install_root', 'C:\\Program Files\\Git'
    ) %}
{%- set temp_dir = salt['environ.get'](
      'TEMP', 'C:\\Windows\\Temp'
    ) %}
{%- set installer_path = [
      temp_dir, 'git-bash-installer.exe'
    ] | join('\\') %}

{%- set uninstaller_cmd = [
      "$local_unins = Get-ChildItem -Path '" ~ install_prefix ~ "'",
      "-Filter 'unins*.exe' | Select-Object -First 1;",
      "if ($local_unins) {",
      "Start-Process -FilePath $local_unins.FullName",
      "-ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART'",
      "-NoNewWindow -Wait } else {",
      "Remove-Item -Path '" ~ install_prefix ~ "'",
      "-Recurse -Force -ErrorAction SilentlyContinue }"
    ] | join(' ') %}
{%- set onlyif_cmd = [
      "if (Test-Path '" ~ install_prefix ~ "') { exit 0 } else { exit 1 }"
    ] | join(' ') %}

include:
  - {{ sls_config_clean }}

Remove Git Bash Cached Installer:
  file.absent:
    - name: {{ installer_path | json }}
    - require:
      - sls: {{ sls_config_clean }}

Remove Git Bash Installation Directory:
  cmd.run:
    - name: {{ uninstaller_cmd | json }}
    - onlyif: {{ onlyif_cmd | json }}
    - require:
      - sls: {{ sls_config_clean }}
    - shell: powershell
