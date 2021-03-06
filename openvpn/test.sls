{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from 'diamond/macro.jinja2' import diamond_process_test with context -%}
{%- from 'macros.jinja2' import dict_default with context %}
include:
  - doc
  - openvpn.server
  - openvpn.server.backup
  - openvpn.server.backup.diamond
  - openvpn.server.backup.nrpe
  - openvpn.server.diamond
  - openvpn.server.nrpe
  - openvpn.server.backup
  - openvpn.server.backup.nrpe
  - openvpn.server.backup.diamond
  - salt.minion.deps

test:
  monitoring:
    - run_all_checks
    - order: last
  qa:
    - test
    - name: openvpn.server
    - additional:
      - openvpn.server.backup
    - doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - monitoring: test
      - cmd: doc
  diamond:
    - test
    - map:
        ProcessResources:
          {{ diamond_process_test('openvpn') }}
    - require:
      - sls: openvpn.server.diamond
      - sls: openvpn.server

{%- set servers = salt['pillar.get']('openvpn:servers', {}) -%}
{%- if servers is iterable and servers | length > 0 -%}
    {%- for instance in servers -%}
        {%- set mode = servers[instance]['mode'] %}
        {{ dict_default(servers[instance], 'clients', []) }}
        {{ dict_default(servers[instance], 'revocations', []) }}
test_openvpn_{{ instance }}:
  diamond:
    - test
    - map:
        OpenVPN:
          openvpn.{{ instance }}.clients.connected: True
        {%- if mode == 'static' %}
          openvpn.{{ instance }}.global.auth_read_bytes: True
          openvpn.{{ instance }}.global.tcp-udp_read_bytes: True
          openvpn.{{ instance }}.global.tcp-udp_write_bytes: True
          openvpn.{{ instance }}.global.tun-tap_read_bytes: True
          openvpn.{{ instance }}.global.tun-tap_write_bytes: True
        {%- else %}
          openvpn.{{ instance }}.global.max_bcast-mcast_queue_length: True
        {%- endif %}
    - require:
      - sls: openvpn.server.diamond
      - sls: openvpn.server

        {%- if mode == 'tls' -%}
        {#-
        Testing conectivity by:
          - copy the client cert
          - starting the client
          - grep the status file for the client's common name
        #}
            {%- for client in servers[instance]['clients'] -%}
                {%- if client not in servers[instance]['revocations'] -%}
                    {%- if client is mapping -%}
                        {%- set cn, ip = servers[instance]['clients'][loop.index0].items()[0] -%}
                    {%- else -%}
                        {%- set cn = client -%}
                    {%- endif %}
test_openvpn_tls_{{ instance }}_{{ cn }}:
  file:
    - directory
    - name: /tmp/openvpn_{{ instance }}_{{ cn }}
    - user: root
    - group: root
    - mode: 750
    - require:
      - monitoring: test
  module:
    - run
    - name: archive.unzip
    - zipfile: /etc/openvpn/{{ instance }}/clients/{{ cn }}.zip
    - dest: /tmp/openvpn_{{ instance }}_{{ cn }}
    - require:
      - file: test_openvpn_tls_{{ instance }}_{{ cn }}
  cmd:
    - wait
    - name: nohup openvpn {{ cn }}.conf > /dev/null 2>&1 &
    - cwd: /tmp/openvpn_{{ instance }}_{{ cn }}
    - watch:
      - module: test_openvpn_tls_{{ instance }}_{{ cn }}

test_openvpn_tls_connect_{{ instance }}_{{ cn }}:
  cmd:
    - wait
    {#- Wait 10 seconds for OpenVPN client to connect
    The status file is updated every second if the __test__ pillar key is True #}
    - name: sleep 11 && grep ^{% if client is mapping %}{{ ip }},{% endif %}{{ cn }} /var/log/openvpn/{{ instance }}.log
    - watch:
      - cmd: test_openvpn_tls_{{ instance }}_{{ cn }}

test_openvpn_tls_cleanup_{{ instance }}_{{ cn }}:
  module:
    - run
    - name: ps.pkill
    - pattern: 'openvpn {{ cn }}.conf'
    - user: nobody
    - full: True
    - require:
      - cmd: test_openvpn_tls_connect_{{ instance }}_{{ cn }}
      - pkg: salt_minion_deps
  file:
    - absent
    - name: /tmp/openvpn_{{ instance }}_{{ cn }}
    - require:
      - module: test_openvpn_tls_cleanup_{{ instance }}_{{ cn }}

                {%- endif %}{#- client not in revocations list -#}
            {%- endfor %}{#- clients #}
        {%- endif %}{#- tls mode -#}
    {%- endfor %}{#- instances -#}
{%- endif %}{#- servers is iterable #}

extend:
  openvpn_diamond_collector:
    file:
      - require:
        - sls: openvpn.server
