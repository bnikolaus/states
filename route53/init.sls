{#
 Install Route53 (Amazon Route53 client-side python library) into OS/root
 site-packages.
 #}
include:
  - pip
  - python.dev
  - xml.dev

python-lxml:
  pkg:
    - purged

route53:
  file:
    - managed
    - name: {{ opts['cachedir'] }}/salt-route53-requirements.txt
    - template: jinja
    - user: root
    - group: root
    - mode: 400
    - source: salt://route53/requirements.jinja2
  module:
    - wait
    - name: pip.install
    - upgrade: True
    - pkgs: ''
    - requirements: {{ opts['cachedir'] }}/salt-route53-requirements.txt
    - require:
      - module: pip
      - pkg: python-lxml
    - watch:
      - pkg: xml-dev
      - file: route53
      - pkg: python-dev
