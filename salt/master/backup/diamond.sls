{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

include:
  - backup.diamond
  - cron.diamond

salt_master_backup_diamond_resources:
  file:
    - accumulated
    - name: processes
    - template: jinja
    - filename: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - require_in:
      - file: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - text:
      - |
        [[backup-saltmaster-file]]
        cmdline = ^\/usr\/local\/bin\/backup-file saltmaster
