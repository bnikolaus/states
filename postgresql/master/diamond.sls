{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

include:
  - postgresql.common.diamond
  - postgresql.master
  - postgresql.server.diamond
  - rsyslog.diamond

extend:
  postgresql_monitoring:
    postgres_user:
      - require:
        - service: postgresql
