git-bash:
  lookup:
    pkg:
      download_uri: 'https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe'
      name: 'git-bash'
    config:
      banner_text: |
        This banner-text is for testing-purposes only

        Do not use for live/production systems
      extra_profile_lines:
      - 'export AWS_REGION="us-west-1"'
      - 'export HTTP_PROXY="http://proxy.my-company.tld:8080"'
      - 'alias ll="ls -la --color=auto"'
