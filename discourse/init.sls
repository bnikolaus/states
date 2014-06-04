{#-
Copyright (C) 2013 the Institute for Institutional Innovation by Data
Driven Design Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE  MASSACHUSETTS INSTITUTE OF
TECHNOLOGY AND THE INSTITUTE FOR INSTITUTIONAL INNOVATION BY DATA
DRIVEN DESIGN INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the names of the Institute for
Institutional Innovation by Data Driven Design Inc. shall not be used in
advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from the
Institute for Institutional Innovation by Data Driven Design Inc.

Author: Lam Dang Tung <lamdt@familug.org>
Maintainer: Lam Dang Tung <lamdt@familug.org>

Install Discourse - Discussion Platform.
#}

include:
  - apt
  - build
  - git
  - logrotate
  - nginx
  - postgresql
  - postgresql.server
  - redis
  - rsyslog
  - ruby
{%- if salt['pillar.get']('discourse:ssl', False) %}
  - ssl
{%- endif %}
  - ssl.dev
  - uwsgi.ruby
  - web
  - xml

{%- set version = "0.9.6.3" %}
{%- set web_root_dir = "/usr/local/discourse-" + version %}
{%- set dbuserpass = salt['password.pillar']('discourse:db:password', 10) %}
{%- set dbuser = salt['pillar.get']('discourse:db:username', 'discourse') %}
{%- set dbname = salt['pillar.get']('discourse:db:name', 'discourse') %}

discourse_deps:
  pkg:
    - installed
    - pkgs:
      - build-essential
      - libtool
      - gawk
      - curl
      - pngcrush
      - imagemagick
      - postgresql-contrib-9.2
    - require:
      - pkg: xml-dev
      - pkg: postgresql-dev
      - pkg: ruby
      - pkg: git
      - pkg: ssl-dev

discourse_tar:
  archive:
    - extracted
    - name: /usr/local/
{%- if 'files_archive' in pillar %}
    - source: {{ pillar['files_archive'] }}/mirror/discourse/v{{ version }}.tar.gz
{%- else %}
    - source: https://github.com/discourse/discourse/archive/v{{ version }}.tar.gz
{%- endif %}
    - source_hash: md5=7e608572bfa2902aaa53cb229cf56516
    - archive_format: tar
    - tar_options: z
    - if_missing: {{ web_root_dir }}
    - require:
      - file: /usr/local
  file:
    - directory
    - name: {{ web_root_dir }}
    - user: discourse
    - group: discourse
    - mode: 750
    - recurse:
      - user
      - group
    - require:
      - user: discourse
      - archive: discourse_tar

{%- set ruby_version = "1.9.3" %}
discourse:
  user:
    - present
    - name: discourse
    - groups:
      - www-data
    - shell: /bin/bash
    - require:
      - pkg: discourse_deps
      - group: web
  postgres_user:
    - present
    - name: {{ dbuser }}
    - password: {{ dbuserpass }}
    - runas: postgres
    - require:
      - service: postgresql
  postgres_database:
    - present
    - name: {{ dbname }}
    - owner: {{ dbuser }}
    - runas: postgres
    - require:
      - postgres_user: discourse
  cmd:
    - wait
    - name: rake{{ ruby_version }} db:migrate
    - cwd: {{ web_root_dir }}
    - user: discourse
    - env:
        RAILS_ENV: production
        RUBY_GC_MALLOC_LIMIT: "90000000"
    - require:
      - file: discourse_tar
      - file: {{ web_root_dir }}/config/database.yml
      - file: {{ web_root_dir }}/config/redis.yml
      - file: {{ web_root_dir }}/config/environments/production.rb
      - user: discourse
      - service: postgresql
      - service: redis
      - postgres_database: discourse
    - watch:
      - cmd: discourse_add_psql_extension_hstore
      - cmd: discourse_add_psql_extension_pg_trgm
      - archive: discourse_tar
  file:
    - managed
    - name: {{ web_root_dir }}/config.ru
    - user: discourse
    - group: discourse
    - mode: 440
    - source: salt://discourse/config.jinja2
    - template: jinja
    - require:
      - file: discourse_tar
      - user: discourse
  uwsgi:
    - available
    - enabled: True
    - name: discourse
    - user: www-data
    - group: www-data
    - template: jinja
    - source: salt://discourse/uwsgi.jinja2
    - mode: 440
    - require:
      - service: uwsgi_emperor
      - cmd: discourse_bundler
      - cmd: discourse
      - gem: discourse_rack
      - postgres_database: discourse
      - cmd: discourse_assets_precompile
    - context:
      web_root_dir: {{ web_root_dir }}
    - watch:
      - user: discourse
      - file: discourse
      - file: {{ web_root_dir }}/config/environments/production.rb
      - file: {{ web_root_dir }}/config/database.yml
      - file: {{ web_root_dir }}/config/redis.yml
      - file: discourse_tar

{{ web_root_dir }}/public/uploads:
  file:
    - symlink
    - target: /var/lib/deployments/discourse/uploads
    - user: discourse
    - group: discourse
    - mode: 750
    - makedirs: True
    - require:
      - user: discourse
      - file: discourse_tar
      - file: /var/lib/deployments/discourse/uploads

discourse_rack:
  gem:
    - installed
    - name: rack
    - version: 1.4.5
    - runas: root
    - require:
      - pkg: ruby
      - pkg: build

{{ web_root_dir }}/config/database.yml:
  file:
    - managed
    - source: salt://discourse/database.jinja2
    - template: jinja
    - user: discourse
    - group: discourse
    - mode: 440
    - require:
      - user: discourse
      - file: discourse_tar
    - context:
      dbuserpass: {{ dbuserpass }}
      dbname: {{ dbname }}
      dbuser: {{ dbuser }}

{{ web_root_dir }}/config/environments/production.rb:
  file:
    - managed
    - user: discourse
    - group: discourse
    - mode: 440
    - template: jinja
    - source: salt://discourse/production.jinja2
    - require:
      - user: discourse
      - file: discourse_tar

{{ web_root_dir }}/config/redis.yml:
  file:
    - managed
    - source: salt://discourse/redis.jinja2
    - template: jinja
    - user: discourse
    - group: discourse
    - mode: 440
    - require:
      - user: discourse
      - file: discourse_tar

discourse_bundler:
  gem:
    - installed
    - name: bundler
    - require:
      - pkg: ruby
      - pkg: build
  cmd:
    - run
    - name: bundle install --deployment --without test
    - user: discourse
    - cwd: {{ web_root_dir }}
    - require:
      - gem: discourse_bundler
      - file: discourse_tar
      - user: discourse

discourse_upstart:
  service:
    - running
    - name: discourse
    - watch:
      - file: discourse_upstart
      - user: discourse
  file:
    - managed
    - name: /etc/init/discourse.conf
    - source: salt://discourse/upstart.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - require:
      - uwsgi: discourse
    - context:
      web_root_dir: {{ web_root_dir }}
      user: discourse
      home: /home/discourse

{% from 'rsyslog/upstart.sls' import manage_upstart_log with context %}
{{ manage_upstart_log('discourse') }}

/etc/logrotate.d/discourse:
  file:
    - managed
    - source: salt://discourse/logrotate.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - require:
      - pkg: logrotate
      - file: discourse_upstart
    - context:
      web_root_dir: {{ web_root_dir }}

/etc/nginx/conf.d/discourse.conf:
  file:
    - managed
    - user: www-data
    - group: www-data
    - template: jinja
    - source: salt://discourse/nginx.jinja2
    - mode: 440
    - require:
      - pkg: nginx
      - uwsgi: discourse
{%- if salt['pillar.get']('discourse:ssl', False) %}
      - cmd: ssl_cert_and_key_for_{{ pillar['discourse']['ssl'] }}
{%- endif %}
    - watch_in:
      - service: nginx
    - context:
      web_root_dir: {{ web_root_dir }}

discourse_add_psql_extension_hstore:
  cmd:
    - wait
    - name: psql discourse -c "CREATE EXTENSION IF NOT EXISTS hstore;"
    - user: postgres
    - require:
      - service: postgresql
    - watch:
      - postgres_database: discourse

discourse_add_psql_extension_pg_trgm:
  cmd:
    - wait
    - name: psql discourse -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    - user: postgres
    - require:
      - service: postgresql
    - watch:
      - postgres_database: discourse

discourse_assets_precompile:
  cmd:
    - wait
    - name: rake{{ ruby_version }} assets:precompile
    - cwd: {{ web_root_dir }}
    - user: discourse
    - env:
        RAILS_ENV: production
        RUBY_GC_MALLOC_LIMIT: "90000000"
    - require:
      - user: discourse
      - file: discourse_tar
    - watch:
      - cmd: discourse

{{ web_root_dir }}/Gemfile:
  file:
    - managed
    - source: salt://discourse/gem.jinja2
    - template: jinja
    - user: discourse
    - group: discourse
    - mode: 440
    - require:
      - file: discourse_tar
    - require_in:
      - cmd: discourse_bundler

{{ web_root_dir }}/Gemfile.lock:
  file:
    - managed
    - source: salt://discourse/gemlock.jinja2
    - template: jinja
    - user: discourse
    - group: discourse
    - mode: 440
    - require:
      - file: discourse_tar
    - require_in:
      - cmd: discourse_bundler

/var/lib/deployments/discourse/uploads:
  file:
    - directory
    - mode: 750
    - user: discourse
    - group: discourse
    - makedirs: True
    - require:
      - user: discourse

extend:
  web:
    user:
      - groups:
        - discourse
      - require:
        - user: discourse
      - watch_in:
        - uwsgi: discourse
{%- if salt['pillar.get']('discourse:ssl', False) %}
  nginx:
    service:
      - watch:
        - cmd: ssl_cert_and_key_for_{{ pillar['discourse']['ssl'] }}
{%- endif %}
