{#- Usage of this is governed by a license that can be found in doc/license.rst
Install a Salt Management Master (server).
If you install a salt master from scratch, check and run bootstrap_archive.py
and use it to install the master.
-#}

{%- from 'upstart/rsyslog.jinja2' import manage_upstart_log with context -%}

{%- set use_ext_pillar = salt['pillar.get']('salt_master:pillar:branch', False) and salt['pillar.get']('salt_master:pillar:remote', False) -%}
{%- set xmpp = salt["pillar.get"]("salt_master:xmpp", {}) %}

include:
  - bash
  - cron
  - local
  - git
{%- if use_ext_pillar %}
  - pip
{%- endif %}
  - pysc
  - python.dev
  - rsyslog
  - salt
  - ssh.client
  - salt.minion.deps
{%- if xmpp %}
  - sleekxmpp
{%- endif %}

{%- for dirname in ('salt', 'reactor') %}
/srv/{{ dirname }}:
  file:
    - directory
    - user: root
    - group: root
    {#- jenkins user needs execute permission on this folder, thus set bit 1 for
        ``other`` #}
    - mode: 555
    - require_in:
      - file: /etc/salt/master
{%- endfor %}

{%- for dirname in ('create', 'destroy', 'job', 'reaction') %}
/srv/reactor/{{ dirname }}:
  file:
    - directory
    - user: root
    - group: root
    - mode: 550
    - require:
      - file: /srv/reactor
    - require_in:
      - file: /etc/salt/master
{%- endfor %}

/srv/reactor/create/highstate.sls:
  file:
    - managed
    - source: salt://salt/master/reactor/highstate.jinja2
    - user: root
    - group: root
    - template: jinja
    - mode: 440
    - require:
      - file: /srv/reactor/create
    - require_in:
      - file: /etc/salt/master
    - watch_in:
      - service: salt-master

/srv/reactor/alert:
  file:
    - absent
    - require_in:
      - file: /etc/salt/master
    - watch_in:
      - service: salt-master

/srv/reactor/reaction/reaction.sls:
  file:
    - managed
    - source: salt://salt/master/reactor/reaction.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - require:
      - file: /srv/reactor/reaction
    - require_in:
      - file: /etc/salt/master
    - watch_in:
      - service: salt-master

/srv/reactor/job/xmpp.sls:
  file:
{%- if xmpp and "highstate" in xmpp["events"] %}
    - managed
    - template: jinja
    - source: salt://salt/master/reactor/xmpp.jinja2
    - user: root
    - group: root
    - mode: 440
    - context:
        recipients: {{ xmpp["recipients"]|default([]) }}
        rooms: {{ xmpp["rooms"]|default([]) }}
    - require:
      - file: /srv/reactor/job
      - file: /etc/salt/master.d/xmpp.conf
    - require_in:
      - file: /etc/salt/master
    - watch_in:
      - service: salt-master
{%- else %}
    - absent
{%- endif %}

/etc/salt/master.d/xmpp.conf:
  file:
{%- if xmpp %}
    - managed
    - user: root
    - group: root
    - mode: 400
    - contents: |
        salt-master-xmpp:
          xmpp.jid: {{ xmpp["jid"] }}
          xmpp.password: {{ xmpp["password"] }}
    - require:
      - pkg: salt-master
    - watch_in:
      - service: salt-master
{%- else %}
    - absent
{%- endif %}

{%- if use_ext_pillar %}
/srv/pillars:
  file:
    - absent

salt-master-requirements:
  file:
    - managed
    - name: {{ opts['cachedir'] }}/pip/salt.master
    - source: salt://salt/master/requirements.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - require:
      - module: pip
  module:
    - wait
    - name: pip.install
    - requirements: {{ opts['cachedir'] }}/pip/salt.master
    - watch:
      - file: salt-master-requirements
      - pkg: python-dev
    - watch_in:
      - service: salt-master
    - require_in:
      - pkg: salt-master
{%- else %}
/srv/pillars:
  file:
    - directory
    - user: root
    - group: root
    - mode: 550
    - require:
      - pkg: salt-master
    - require_in:
      - service: salt-master
{%- endif %}

/srv/salt/top.sls:
  file:
    - absent
    - require:
      - file: /srv/salt

/srv/salt/top/top.sls:
  file:
    - managed
    - user: root
    - group: root
    - makedirs: True
    - mode: 440
    - source: salt://salt/master/top.jinja2
    - require:
      - file: /srv/salt

{%- for prefix in ('job_changes', 'event_debug') %}
salt-master-{{ prefix }}.py:
  file:
    - managed
    - name: /usr/local/bin/salt-master-{{ prefix }}.py
    - user: root
    - group: root
    - mode: 550
    - source: salt://salt/master/{{ prefix }}.py
    - require:
      - file: /usr/local
      - module: pysc
{%- endfor %}

/etc/salt/master:
  file:
    - managed
    - source: salt://salt/master/config.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 400
    - require:
      - pkg: salt-master
    - context:
        use_ext_pillar: {{ use_ext_pillar }}
salt-master:
  file:
    - managed
    - name: /etc/init/salt-master.conf
    - template: jinja
    - source: salt://salt/master/upstart.jinja2
    - user: root
    - group: root
    - mode: 440
    - require:
      - pkg: salt-master
  service:
    - running
    - enable: True
    - order: 90
    - require:
      - service: rsyslog
      - pkg: git
      - file: /var/cache/salt
    - watch:
      - pkg: salt-master
      - file: /etc/salt/master
      - file: salt-master
      - cmd: salt
{#- PID file owned by root, no need to manage #}
  pkg:
    - installed
    - skip_verify: True
    - require:
      - cmd: salt

{{ manage_upstart_log('salt-master') }}

/etc/cron.daily/salt_master_highstate:
  file:
    - absent

salt_master_script_highstate:
  file:
    - managed
    - name: /usr/local/bin/salt_master_highstate.sh
    - source: salt://salt/master/highstate.jinja2
    - mode: 550
    - user: root
    - group: root
    - require:
      - file: /usr/local
      - file: bash
      - file: /usr/local/share/salt_common.sh
      - file: /etc/cron.daily/salt_master_highstate

salt_master_cron_highstate:
  file:
    - managed
    - name: /etc/cron.d/salt_master_highstate
    - source: salt://salt/master/cron_highstate.jinja2
    - template: jinja
    - user: root
    - group: root
    - mode: 500
    - require:
      - pkg: cron
      - file: bash
      - service: salt-master
      - file: salt_master_script_highstate

salt_master_masterapi_patch:
  file:
    - managed
    - name: {{ grains['saltpath'] }}/daemons/masterapi.py
    - source: salt://salt/master/masterapi.py
    - require:
      - pkg: salt-master
    - watch_in:
      - service: salt-master

salt_master_gitfs_patch:
  file:
    - managed
    - name: {{ grains['saltpath'] }}/fileserver/gitfs.py
    - source: salt://salt/master/gitfs.py
    - require:
      - pkg: salt-master
    - watch_in:
      - service: salt-master

salt_master_script_git_pull_repos:
  file:
    - managed
    - name: /usr/local/bin/salt_master_git_pull_repos.sh
    - source: salt://salt/master/git_pull_repos.sh
    - mode: 551
    - user: root
    - group: root
    - require:
      - file: /usr/local
      - file: bash
      - file: /usr/local/share/salt_common.sh

{%- set remotes = salt['pillar.get']('salt_master:gitfs_remotes', []) %}
salt_master_cron_git_pull_repos:
  file:
    - name: /etc/cron.d/salt-master-pull-repos
{%- if not remotes %}
    - absent
{%- else %}
    - managed
    - template: jinja
    - user: root
    - group: root
    - mode: 500
    - source: salt://salt/master/cron_fetch_repos.jinja2
    - require:
      - file: bash
      - pkg: git
      - file: openssh-client
      - file: salt_master_script_git_pull_repos
{%- endif %}

{%- for repo in remotes %}
salt_master_git_repo_{{ loop.index }}:
  git:
    - latest
    - name: '{{ repo }}'
{# needs prefix loop.index because 2 different repos from different sources
   can have the same name #}
{%- set dirname = loop.index ~ repo.split('/')[-1] %}
    - rev: {{ salt['pillar.get']('branch', 'master') }}
    - target: /srv/salt/states/{{ dirname }}
    - require:
      - pkg: git
      - file: /srv/salt
      - file: openssh-client
    - require_in:
      - file: salt_master_cron_git_pull_repos
{%- endfor %}
