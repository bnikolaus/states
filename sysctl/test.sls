{#- Usage of this is governed by a license that can be found in doc/license.rst -#}

include:
  - doc
  - sysctl

test:
  qa:
    - test_pillar
    - name: sysctl
    - pillar_doc: {{ opts['cachedir'] }}/doc/output
    - require:
      - cmd: doc
