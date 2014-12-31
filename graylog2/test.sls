{#-
Use of this source code is governed by a BSD license that can be found
in the doc/license.rst file.

Author: Bruno Clermont <bruno@robotinfra.com>
Maintainer: Van Pham Diep <favadi@robotinfra.com>
-#}
{%- from 'cron/test.jinja2' import test_cron with context -%}
{%- from 'diamond/macro.jinja2' import diamond_process_test with context %}
include:
  - doc
  - elasticsearch
  - elasticsearch.diamond
  - elasticsearch.nrpe
  - graylog2.server
  - graylog2.server.backup
  - graylog2.server.backup.diamond
  - graylog2.server.backup.nrpe
  - graylog2.server.diamond
  - graylog2.server.nrpe
  - graylog2.web
  - graylog2.web.diamond
  - graylog2.web.nrpe

{%- call test_cron() %}
- sls: elasticsearch
- sls: elasticsearch.diamond
- sls: elasticsearch.nrpe
- sls: graylog2.server
- sls: graylog2.server.backup
- sls: graylog2.server.backup.nrpe
- sls: graylog2.server.diamond
- sls: graylog2.server.nrpe
- sls: graylog2.web
- sls: graylog2.web.diamond
- sls: graylog2.web.nrpe
{%- endcall %}

graylog2_log_one_msg:
  cmd:
    - run
    - name: logger test
    - require:
      - service: graylog2-server

test:
  monitoring:
    - run_all_checks
    - order: last
    - wait: 60
    - exclude:
      - elasticsearch_cluster
      - graylog2_server-es_cluster
      - graylog2_incoming_logs
    - require:
      - cmd: test_crons
      - cmd: graylog2_log_one_msg
  diamond:
    - test
    - map:
        ProcessResources:
    {{ diamond_process_test('graylog2-web') }}
    {{ diamond_process_test('graylog2') }}
    - require:
      - sls: graylog2.server
      - sls: graylog2.server.diamond
      - sls: graylog2.web
      - sls: graylog2.web.diamond

test_graylog2_server:
  qa:
    - test
    - name: graylog2.server
    - pillar_doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - monitoring: test
      - cmd: doc

test_graylog2_web:
  qa:
    - test
    - name: graylog2.web
    - pillar_doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - monitoring: test
      - cmd: doc

graylog2_server-es_cluster:
  monitoring:
    - run_check
    - accepted_failure: 1 nodes in cluster (outside range 2:2)
    - require:
      - monitoring: test
