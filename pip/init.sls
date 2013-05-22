{#
 # Install python-pip, a cache for downloaded archive and a config file
 # to force root user to use the cache folder.
 #}
include:
  - ssh.client
  - git
  - mercurial
  - apt
  - python

{% set root_user_home = salt['user.info']('root')['home'] %}

{{ root_user_home }}/.pip:
  file:
    - directory
    - user: root
    - group: root
    - mode: 700

/var/cache/pip:
  file:
    - directory
    - user: root
    - group: root
    - mode: 700

pip-cache:
  file:
    - managed
    - name: {{ root_user_home }}/.pip/pip.conf
    - template: jinja
    - source: salt://pip/config.jinja2
    - user: root
    - group: root
    - require:
      - file: {{ root_user_home }}/.pip
      - file: /var/cache/pip

python-pip:
  pkg:
    - purged

python-setuptools:
  pkg:
    - installed
    - require:
      - cmd: apt_sources

{% set version='1.3.1' %}
pip:
  archive:
    - extracted
    - name: {{ opts['cachedir'] }}
    - source: https://pypi.python.org/packages/source/p/pip/pip-{{ version }}.tar.gz
    - source_hash: md5=cbb27a191cebc58997c4da8513863153
    - archive_format: tar
    - tar_options: z
    - if_missing: {{ opts['cachedir'] }}/pip-{{ version }}
  module:
    - wait
    - name: cmd.run
    - cmd: /usr/bin/python setup.py install
    - cwd: {{ opts['cachedir'] }}/pip-{{ version }}
    - require:
      - pkg: python-pip
      - file: pip-cache
      - pkg: python
      - pkg: python-setuptools
    - watch:
      - archive: pip

{#
 Upgrade distribute to avoid the following error:
 $ pip freeze
 Warning: cannot find svn location for distribute==0.6.24dev-r0
 [snip]
 ## FIXME: could not find svn URL in dependency_links for this package:
 distribute==0.6.24dev-r0
 [snip]
#}
distribute:
  module:
    - wait
    - name: pip.install
    - pkgs: distribute
    - upgrade: True
    - watch:
      - module: pip
