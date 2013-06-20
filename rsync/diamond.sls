{#
 Diamond statistics for rsync
#}

include:
  - diamond

rsync_diamond_resources:
  file:
    - accumulated
    - name: processes
    - filename: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - require_in:
      - file: /etc/diamond/collectors/ProcessResourcesCollector.conf
    - text:
      - |
        [[rsync]]
        exe = ^\/usr\/bin\/rsync$