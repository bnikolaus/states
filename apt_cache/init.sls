{%- from 'nginx/macro.jinja2' import ssl_default_server with context -%}
{%- set ssl = salt['pillar.get']('apt_cache:ssl', False) -%}
include:
  - apt
  - nginx
{%- if ssl %}
  - ssl
{%- endif %}

apt_cache:
  pkg:
    - installed
    - name: apt-cacher-ng
    - require:
      - cmd: apt_sources
  service:
    - running
    - name: apt-cacher-ng
    - require:
      - pkg: apt_cache

/etc/nginx/conf.d/apt_cache.conf:
  file:
    - managed
    - template: jinja
    - source: salt://apt_cache/nginx.jinja2
    - user: www-data
    - group: www-data
    - mode: 440
    - require:
      - pkg: nginx
      - service: apt_cache
    - watch_in:
      - service: nginx

{%- if ssl %}
{{ ssl_default_server('apt_cache') }}

extend:
  nginx:
    service:
      - watch:
        - cmd: ssl_cert_and_key_for_{{ ssl }}
{%- endif %}
