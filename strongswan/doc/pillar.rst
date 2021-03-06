Pillar
======

.. include:: /doc/include/add_pillar.inc

- :doc:`/apt/doc/index` :doc:`/apt/doc/pillar`
- :doc:`/rsyslog/doc/index` :doc:`/rsyslog/doc/pillar`
- :doc:`/ssl/doc/index` :doc:`/ssl/doc/pillar`

sysctl
------

:doc:`/sysctl/doc/index` :doc:`/sysctl/doc/pillar` need to have at least the
following::

  sysctl:
    net.ipv4.ip_forward: 1

Mandatory
---------

Example::

  strongswan:
    ca:
      name: example
      days: 365
      common_name: example-ca
      country: US
      state: California
      locality: Redwood City
      organization: My Company Ltd
      organizational_unit: IT
      email: info@example.com
    secret_types:
      eap:
        user: pass
    rightsourceip:
      android_pools:
        - 192.168.10.0/24
      ios_pools:
        - 192.168.11.0/24
    dns_servers:
      - 208.67.222.222

.. _pillar-strongswan-ca-name:

strongswan:ca:name
~~~~~~~~~~~~~~~~~~

Name of the :ref:`glossary-CA`.

.. _pillar-strongswan-ca-days:

strongswan:ca:days
~~~~~~~~~~~~~~~~~~

Number of days the :ref:`glossary-CA` will be valid.

.. _pillar-strongswan-ca-country:

strongswan:ca:country
~~~~~~~~~~~~~~~~~~~~~

Country name.

.. _pillar-strongswan-ca-state:

strongswan:ca:state
~~~~~~~~~~~~~~~~~~~

State or Province Name.

.. _pillar-strongswan-ca-locality:

strongswan:ca:locality
~~~~~~~~~~~~~~~~~~~~~~

Locality Name.

.. _pillar-strongswan-ca-organization:

strongswan:ca:organization
~~~~~~~~~~~~~~~~~~~~~~~~~~

Organization Name.

.. _pillar-strongswan-ca-organizational_unit:

strongswan:ca:organizational_unit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Organizational Unit Name.

.. _pillar-strongswan-ca-common_name:

strongswan:ca:common_name
~~~~~~~~~~~~~~~~~~~~~~~~~

The certificate `Common Name <http://info.ssl.com/article.aspx?id=10048>`_.

.. _pillar-strongswan-ca-email:

strongswan:ca:email
~~~~~~~~~~~~~~~~~~~

Email Address that will be put into the :ref:`glossary-CA` certificate's
subject.

.. _pillar-strongswan-secret_types:

strongswan:secret_types
~~~~~~~~~~~~~~~~~~~~~~~

A dict of secret types with key is the type and value is another dict of
username and password.

.. _pillar-strongswan-secret_types-type:

strongswan:secret_types:{{ type }}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A dict of username and password of the ``{{ type }}`` of secret.

.. _pillar-strongswan-rightsourceip-android_pools:

strongswan:rightsourceip:android_pools
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

List of pools in :ref:`glossary-CIDR` notation that will be used for android
devices.

.. _pillar-strongswan-rightsourceip-ios_pools:

strongswan:rightsourceip:ios_pools
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

List of pools in :ref:`glossary-CIDR` notation that will be used for iOS
devices.

.. note::

   In :doc:`index` 4.x, two :ref:`glossary-IKE` protocol versions were handled
   by two separate :ref:`glossary-IKE` daemons. They both have their own state,
   so this must be different from
   :ref:`pillar-strongswan-rightsourceip-android_pools`.

.. _pillar-strongswan-dns_servers:

strongswan:dns_servers
~~~~~~~~~~~~~~~~~~~~~~

List of :ref:`glossary-DNS` servers that will be assigned to peer via
mode-config (IKEv1) or configuration payload (IKEv2).

.. note::

   This list must not include a client named ``server`` which will override
   the server certificate.

Optional
--------

Example::

  strongswan:
    ca:
      bits: 2048
    public_interface: eth0
    clients:
      ios: 456

.. _pillar-strongswan-ca-bits:

strongswan:ca:bits
~~~~~~~~~~~~~~~~~~

The number of bits in the :ref:`glossary-RSA` key.

Default: ``2048`` bit :ref:`glossary-RSA`.

.. _pillar-strongswan-public_interface:

strongswan:public_interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The network interface which will be used for connecting from other end.

Default: use the value from :ref:`pillar-network-interface` (``False``).

.. _pillar-strongswan-clients:

strongswan:clients
~~~~~~~~~~~~~~~~~~

Data formed as a dictionary with key is the name of the client certificate and
value is the password of :ref:`glossary-pkcs12` certificate file.

Default: just support Android, no extra clients (``{}``).
