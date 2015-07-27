influxdb:
  service:
    - dead
  pkg:
    - purged
    - require:
      - service: influxdb

/var/opt/influxdb:
  file:
    - absent
    - require:
      - pkg: influxdb

{{ opts["cachedir"] }}/pip/influxdb:
  file:
    - absent
