{#
 Remove Nagios NRPE check for StatsD
#}
{% if 'shinken_pollers' in pillar %}
include:
  - nrpe

extend:
  nagios-nrpe-server:
    service:
      - watch:
        - file: /etc/nagios/nrpe.d/statsd.cfg
{% endif %}

/etc/nagios/nrpe.d/statsd.cfg:
  file:
    - absent
