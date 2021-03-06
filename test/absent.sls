{%- set local = {
  "services": [],
  "requisites": [],
  "passive_absents": [],
  "nagios_plugins": [],
  "diamond_collectors": [],
  } -%}

{%- do local.passive_absents.extend([
  "amavis",
  "apt",
  "apt_cache",
  "backup.server",
  "bind",
  "carbon",
  "carbon.backup",
  "clamav.server",
  "cron",
  "denyhosts",
  "diamond",
  "djangopypi2",
  "djangopypi2.backup",
  "dovecot",
  "dovecot.backup",
  "ejabberd",
  "ejabberd.backup",
  "elasticsearch",
  "elasticsearch.backup",
  "erlang",
  "etherpad",
  "etherpad.backup",
  "firewall",
  "gitlab",
  "gitlab.backup",
  "graphite",
  "graphite.backup",
  "graylog2.server",
  "graylog2.server.backup",
  "graylog2.web",
  "jenkins",
  "jenkins.backup",
  "mysql.server",
  "memcache",
  "mongodb",
  "nginx",
  "ntp",
  "openerp",
  "openerp.backup",
  "openldap",
  "openldap.backup",
  "openvpn.server",
  "openvpn.server.backup",
  "postfix",
  "postfix.backup",
  "postgresql.common",
  "proftpd",
  "proftpd.backup",
  "rabbitmq",
  "redis",
  "redis.backup",
  "roundcube",
  "roundcube.backup",
  "rsync",
  "rsyslog",
  "salt.api",
  "salt.archive",
  "salt.cloud",
  "salt.master",
  "salt.master.backup",
  "salt.minion",
  "sentry",
  "sentry.backup",
  "squid",
  "ssh.server",
  "statsd",
  "terracotta",
  "tomcat.6",
  "tomcat.7",
  "uwsgi",
  "varnish",
  "xinetd",
  ]) %}

{%- do local.services.extend([
  "amavis",
  "apt_cache",
  "clamav-daemon",
  "cron",
  "denyhosts",
  "dovecot",
  "ejabberd",
  "elasticsearch",
  "etherpad",
  "gitlab",
  "graylog-server",
  "graylog-web",
  "jenkins",
  "mysql-server",
  "memcached",
  "mongodb",
  "nginx",
  "ntp",
  "slapd",
  "pgbouncer",
  "postfix_stats",
  "postfix",
  "postgresql",
  "proftpd",
  "rabbitmq-server",
  "redis",
  "salt-api",
  "salt-master",
  "shinken-arbiter",
  "shinken-broker",
  "shinken-poller",
  "shinken-reactionner",
  "shinken-receiver",
  "shinken-scheduler",
  "squid3",
  "openerp",
  "openssh-server",
  "statsd",
  "terracotta",
  "tomcat6",
  "tomcat7",
  "uwsgi",
  "varnish",
  "xinetd",
  ]) %}

{%- do local.nagios_plugins.extend([
  "/usr/lib/nagios/plugins/check_backups.py",
  "/usr/local/nagios/lib/python2.7/check_backup_base.py",
  "check_backup.py",
  "/usr/lib/nagios/plugins/check_backup_s3lite.py",
  "/usr/lib/nagios/plugins/check_psql_encoding.py",
  "/usr/lib/nagios/plugins/check_postgres",
  "/usr/lib/nagios/plugins/check_pgsql_query.py",
  "/usr/lib/nagios/plugins/check_mine_minions.py",
  "/usr/lib/nagios/plugins/check_git_branch.py",
  "/usr/lib/nagios/plugins/check_saltcloud_images.py",
  "/usr/lib/nagios/plugins/check_mail_stack.py",
  "/usr/lib/nagios/plugins/check_robots.py",
  "/usr/lib/nagios/plugins/check_firewall.py",
  "/usr/lib/nagios/plugins/check_apt-rc.py",
  "/usr/lib/nagios/plugins/check_mysql_query.py",
  "/usr/lib/nagios/plugins/check_uwsgi",
  "/usr/lib/nagios/plugins/check_uwsgi_nostderr",
  "/usr/lib/nagios/plugins/check_dns_caching.py",
  "/usr/lib/nagios/plugins/check_new_logs.py",
  "/usr/lib/nagios/plugins/check_elasticsearch_cluster.py",
  ]) %}

{%- do local.diamond_collectors.extend([
  "memcached_diamond_collector",
  "postgresql_diamond_collector",
  "diamond_rabbitmq",
  "diamond_ntp",
  "/etc/diamond/collectors/RedisCollector.conf",
  "mysql_diamond_collector",
  "postfix_diamond_collector",
  "/etc/diamond/collectors/ElasticSearchCollector.conf",
  "/etc/diamond/collectors/AmavisCollector.conf",
  "diamond_mongodb",
  "nginx_diamond_collector",
  "openvpn_diamond_collector",
  "varnish_diamond_VarnishCollector",
  ]) %}

{%- for service in local.services %}
  {#- all services except rsyslog, nsca_passsive, nrpe-nagios-server, diamond #}
  {%- do local.requisites.append({"service": service}) %}
{%- endfor %}

{%- set prefix = '/etc/init.d/' %}
{%- set init_files = salt['file.find'](prefix, name='carbon-cache-*', type='f') %}
{%- do local.services.append('carbon-relay') %}
{%- for filename in init_files %}
  {%- set instance = filename.replace(prefix + 'carbon-cache-', '') %}
  {%- do local.services.append(instance) %}
{%- endfor %}

include:
  - amavis.absent
  - apt_cache.absent
  - carbon.absent
  - clamav.absent
  - cron.absent
  - denyhosts.absent
  - diamond.absent
  - dovecot.absent
  - ejabberd.absent
  - elasticsearch.absent
  - etherpad.absent
  - git.absent
  - gitlab.absent
  - graylog2.server.absent
  - graylog2.web.absent
  - jenkins.absent
  - mysql.server.absent
  - memcache.absent
  - mongodb.absent
  - nginx.absent
  - nrpe.absent
  - ntp.absent
  - openerp.absent
  - openldap.absent
  - pgbouncer.absent
  - postfix.diamond.absent
  - postfix.absent
  - postgresql.server.absent
  - proftpd.absent
  - rabbitmq.absent
  - redis.absent
  - rsyslog.absent
  - salt.api.absent
  - salt.master.absent
  - shinken.arbiter.absent
  - shinken.broker.absent
  - shinken.poller.absent
  - shinken.reactionner.absent
  - shinken.receiver.absent
  - shinken.scheduler.absent
  - squid.absent
  - ssh.server.absent
  - statsd.absent
  - terracotta.absent
  - tomcat.6.absent
  - tomcat.7.absent
  - uwsgi.absent
  - varnish.absent
  - xinetd.absent
  - backup.server.nrpe.absent
  - backup.client.base.nrpe.absent
  - backup.client.s3.nrpe.absent
  - mail.server.nrpe.absent
  - postgresql.nrpe.absent
  - django.absent
  - memcache.diamond.absent
  - postgresql.common.diamond.absent
  - rabbitmq.diamond.absent
  - ntp.diamond.absent
  - redis.diamond.absent
  - mysql.server.diamond.absent
  - elasticsearch.diamond.absent
  - amavis.diamond.absent
  - mongodb.diamond.absent
  - nginx.diamond.absent
  - openvpn.server.diamond.absent
  - varnish.diamond.absent
  - ssh.client.absent
{%- for formula in local.passive_absents %}
  - {{ formula }}.nrpe.absent
{%- endfor %}

extend:
  cron:
    service:
      - order: first
  postgresql:
    service:
      - require:
        - service: ejabberd
        - service: etherpad
        - service: gitlab
        - service: pgbouncer
        - service: proftpd
        - service: uwsgi
        - service: openerp
  mongodb:
    service:
      - require:
        - service: graylog-server
        - service: graylog-web
  redis:
    service:
      - require:
        - service: gitlab
  nsca_passive:
    service:
      - require_in: {{ local.requisites|yaml }}
  nagios-nrpe-server:
    service:
      - require_in: {{ local.requisites|yaml }}
  diamond:
    service:
      - require_in: {{ local.requisites|yaml }}
      - require:
        - service: nsca_passive
        - service: nagios-nrpe-server
{#- append monitoring services #}
{%- do local.requisites.extend([
  {"service": "nsca_passive"},
  {"service": "nagios-nrpe-server"},
  {"service": "diamond"},
  ]) %}
  rsyslog:
    service:
      - require: {{ local.requisites|yaml }}
  salt-master:
    service:
      - require_in:
        - pkg: git
        - file: openssh-client
{%- for formula in local.passive_absents %}
  {%- for file in [
    "/var/lib/nagios/" ~ formula ~ "_ssl_configuration.yml",
    "/etc/nagios/nrpe.d/" ~ formula ~ ".cfg",
    "nsca-" ~ formula,
    "/etc/cron.twice_daily/sslyze_check_" ~ formula|replace('.', '-')] %}
  {{ file }}:
    file:
      - require:
        - service: nsca_passive
        - service: nagios-nrpe-server
    {%- endfor %}
{%- endfor %}
{%- for plugin in local.nagios_plugins %}
  {{ plugin }}:
    file:
      - require:
        - service: nsca_passive
        - service: nagios-nrpe-server
{%- endfor %}
{%- for collector in local.diamond_collectors %}
  {{ collector }}:
    file:
      - require:
        - service: diamond
{%- endfor %}
  amavis:
    pkg:
      - require:
        - service: diamond
