{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

{%- from "upstart/absent.sls" import upstart_absent with context -%}

{{ upstart_absent("graylog-server")}}

extend:
  graylog-server:
    user:
      - absent
      - name: graylog
      - require:
        - service: graylog-server
    group:
      - absent
      - name: graylog
      - require:
        - user: graylog-server
    pkg:
      - purged

/etc/graylog/server:
  file:
    - absent
    - require:
      - service: graylog-server

graylog-alarmcallback-jabber:
  pkg:
    - purged
    - require:
      - service: graylog-server
