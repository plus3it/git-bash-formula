# -*- coding: utf-8 -*-
# vim: ft=sls
---
{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata with context %}

{%- set _mapdata = {
      "values": mapdata,
    } %}
{%- do salt["log.debug"]("### MAP.JINJA DUMP ###\n" ~ _mapdata | yaml(False)) %}

{%- set output_dir = "C:\\temp" if grains.os_family == "Windows" else "/tmp" %}
{%- set output_file = output_dir ~ "\\salt_mapdata_dump.yaml"
      if grains.os_family == "Windows"
      else output_dir ~ "/salt_mapdata_dump.yaml" %}

Dump Formula Map Data To File:
  file.managed:
    - context:
        map: {{ _mapdata | yaml }}
    - makedirs: true
    - name: {{ output_file }}
    - source: salt://{{ tplroot }}/_mapdata/_mapdata.jinja
    - template: jinja
