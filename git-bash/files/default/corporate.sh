# -*- coding: utf-8 -*-
# vim: ft=sh
###############################################################################
# File managed by Salt at <{{ source }}>.
# Your changes will be overwritten.
###############################################################################

# Enforce enterprise environment configurations inside Git BASH
export HOME="/c/Users/$USER"

{%- set config = git_bash.get('config') or {} %}
{%- set banner = config.get('banner_text', '') %}
{%- if banner %}
echo "======================================================================="
{%- for line in banner.splitlines() %}
echo {{ line | json }}
{%- endfor %}
echo "======================================================================="
{%- endif %}

{%- set extra_lines = config.get('extra_profile_lines') or [] %}
{%- if extra_lines %}

# Site-specific environment additions
{%- for line in extra_lines %}
{{ line }}
{%- endfor %}
{%- endif %}
