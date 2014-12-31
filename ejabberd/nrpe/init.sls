{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Dang Tung Lam <lam@robotinfra.com>
Maintainer: Van Pham Diep <favadi@robotinfra.com>
-#}
{%- set formula = 'ejabberd' -%}
{%- from 'nrpe/passive.jinja2' import passive_check with context %}
include:
  - apt.nrpe
  - erlang.nrpe
  - nginx.nrpe
  - nrpe
  - pip
  - postgresql.server.nrpe
{%- if salt['pillar.get'](formula + ':ssl', False) %}
  - ssl.nrpe
{%- endif %}

{{ passive_check(formula, check_ssl_score=True) }}

extend:
  check_psql_encoding.py:
    file:
      - require:
        - file: nsca-{{ formula }}
  /usr/lib/nagios/plugins/check_pgsql_query.py:
    file:
       - require:
         - file: nsca-{{ formula }}

check_xmpp-requirements:
  file:
    - managed
    - name: {{ opts['cachedir'] }}/pip/nagios-xmpp
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://ejabberd/nrpe/requirements.txt
    - require:
      - virtualenv: nrpe-virtualenv
      - file: {{ opts['cachedir'] }}/pip
  module:
    - wait
    - name: pip.install
    - upgrade: True
    - bin_env: /usr/local/nagios
    - requirements: {{ opts['cachedir'] }}/pip/nagios-xmpp
    - require:
      - virtualenv: nrpe-virtualenv
    - watch:
      - file: check_xmpp-requirements

check_xmpp.py:
  file:
    - managed
    - name: /usr/lib/nagios/plugins/check_xmpp.py
    - source: salt://ejabberd/nrpe/check.py
    - user: nagios
    - group: nagios
    - mode: 550
    - require:
      - module: check_xmpp-requirements
      - module: nrpe-virtualenv
      - pkg: nagios-nrpe-server
    - require_in:
      - service: nagios-nrpe-server
      - service: nsca_passive
