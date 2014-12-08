{%- from 'diamond/macro.jinja2' import diamond_process_test with context %}
include:
  - tomcat.6
  - tomcat.6.diamond
  - tomcat.6.nrpe

test:
  monitoring:
    - run_all_checks
    - order: last
    - wait: 15
  diamond:
    - test
    - map:
        ProcessResources:
    {{ diamond_process_test('tomcat', zmempct=False) }}
    - require:
      - sls: tomcat.6
      - service: diamond
