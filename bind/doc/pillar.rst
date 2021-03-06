Pillar
======

.. include:: /doc/include/add_pillar.inc

.. note::

  all ``TTL`` in this document has different meaning to :ref:`glossary-ttl`,
  TTL here which is the time to live of the :ref:`glossary-RR`.  This field is
  a 32 bit integer in units of seconds, an is primarily used by resolvers when
  they cache :ref:`glossary-RR` . The TTL describes how long a
  :ref:`glossary-RR` can be cached before it should be discarded.
  See http://www.ietf.org/rfc/rfc1035.txt for more details.

Mandatory
---------

Example::

  bind:
    allowed_subnets:
      - any

.. _pillar-bind-allowed_subnets:

bind:allowed_subnets
~~~~~~~~~~~~~~~~~~~~

List of IP addresses which are allowed to issue query to the server.

.. note::

   In the above example, ``any`` means that all hosts are allowed to make
   queries.

Optional
--------

.. _pillar-bind-forwarders:

bind:forwarders
~~~~~~~~~~~~~~~

Default: does not use forwarder (``[]``).

.. _pillar-bind-zones:

bind:zones
~~~~~~~~~~

Default: setting no custom zone (``{}``).

Conditional
-----------

.. _pillar-bind-zones-{{ zone_name }}:

bind:zones:{{ zone_name }}
~~~~~~~~~~~~~~~~~~~~~~~~~~

Name of the zone that this server will be authoritative server for.

.. _pillar-bind-zones-{{ zone_name }}-file:

bind:zones:{{ zone_name }}:file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Filename which will contain data for the zone.

.. _pillar-bind-zones-{{ zone_name }}-forwarders:

bind:zones:{{ zone_name }}:forwarders
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

List of forwarders that this server will forward the queries that it cannot
satisfy from its cache to another caching name server.

Default: no forward queries (``[]``).

.. _pillar-bind-zones-{{ zone_name }}-masters:

bind:zones:{{ zone_name }}:masters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

IP addresses of master server, if this server serves as a slave for this zone.

Default: this will act as a master server (``[]``).

.. _pillar-bind-zones-{{ zone_name }}-ttl:

bind:zones:{{ zone_name }}:ttl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Default TTL for all resource records in zone ``{{ zone_name }}`` in unit of
seconds.

Default: ``2560`` seconds.

.. _pillar-bind-zones-{{ zone_name }}-admin_email:

bind:zones:{{ zone_name }}:admin_email
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Email of administrator of this zone.

.. _pillar-bind-zones-{{ zone_name }}-serial:

bind:zones:{{ zone_name }}:serial
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Version number of this zone.

.. note::

  This number MUST be increased everywhen there is a change in the
  {{ zone_name }}

.. _pillar-bind-zones-{{ zone_name }}-refresh:

bind:zones:{{ zone_name }}:refresh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Time interval before the zone should be refreshed in units of seconds.

Default: ``16384`` seconds.

.. _pillar-bind-zones-{{ zone_name }}-retry:

bind:zones:{{ zone_name }}:retry
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Time interval that should elapse before a failed refresh should be retried
in units of seconds.

Default: ``2048`` seconds.

.. _pillar-bind-zones-{{ zone_name }}-expire:

bind:zones:{{ zone_name }}:expire
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Specifies the upper limit on the time interval that can
elapse before the zone is no longer authoritative.

Default: ``1048576`` seconds.

.. _pillar-bind-zones-{{ zone_name }}-minimum:

bind:zones:{{ zone_name }}:minimum
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Minimum TTL field that should be exported with any :ref:`glossary-RR`
 from this zone.

Default: ``2560`` seconds.

.. _pillar-bind-zones-{{ zone_name }}-resource_records:

bind:zones:{{ zone_name }}:resource_records
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

List of resource records. Each resource record represented by a dictionary
of keys ``name``, ``ttl``, ``type``, ``rdata``.

Default: Set no record (``[]``).
