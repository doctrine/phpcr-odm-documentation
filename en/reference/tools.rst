Tools
=====

Doctrine Console
----------------

The Doctrine Console is a Command Line Interface tool for
simplifying common tasks during the development of a project that
uses Doctrine PHPCR-ODM.

Take a look at the last section of :doc:`Installation and Configuration <installation-configuration>` for more
information how to setup the console command.

Getting Help
~~~~~~~~~~~~

Type ``bin/phpcr`` on the command line and you should see an
overview of the available commands or use the --help flag to get
information on the available commands. If you want to know more
about the use of generate entities for example, you can call:

.. code-block:: php

    doctrine doctrine:phpcr:register-system-node-types --help

Configuration
~~~~~~~~~~~~~

To use the commands, you need to define the phpcr binary. The easiest is to copy
bin/phpcr from the phpcr-odm folder and put it into your project directory.

Command Overview
~~~~~~~~~~~~~~~~

The following Commands are currently available:


-  ``help`` Displays help for a command (?)
-  ``list`` Lists commands
-  ``doctrine:phpcr:register-system-node-types`` Register system node types in the PHPCR repository
-  ``phpcr:import``  Import xml data into the repository, either in JCR system view format or arbitrary xml
-  ``phpcr:dump`` Dump the content repository
-  ``phpcr:purge``  Remove all content from the repository
-  ``phpcr:query``  Execute a JCR SQL2 statement
-  ``phpcr:register-node-types``  Register node types in the PHPCR repository
-  ``phpcr:workspace:create``  Create a workspace in the configured repository

Note that the commands prefixed with only phpcr come from the phpcr-utils and are not
specific to Doctrine PHPCR-ODM, but helpful when interacting with a PHPCR repository.

If you are using jackalope-jackrabbit, you also have a command to start and stop the
jackrabbit server:

-  ``jackalope:run:jackrabbit``  Start and stop the Jackrabbit server

TODO: expose and mention jackalope-doctrine-dbal command

Register system node types
--------------------------

This command needs to be run once on a new repository to prepare it for use with the PHPCR-ODM.
Failing to do so will throw you errors when you try to store a document that uses a node type
different from nt:unstructured, like a file or folder.

..
    TODO: would be nice to provide this as well

    Convert Mapping Information
    ---------------------------

    Convert mapping information between supported formats.

    This is an **execute one-time** command. It should not be necessary for
    you to call this method multiple times, escpecially when using the ``--from-database``
    flag.

    Converting an existing database schema into mapping files only solves about 70-80%
    of the necessary mapping information. Additionally the detection from an existing
    database cannot detect inverse associations, inheritance types,
    entities with foreign keys as primary keys and many of the
    semantical operations on associations such as cascade.

    .. note::

        There is no need to convert YAML or XML mapping files to annotations
        every time you make changes. All mapping drivers are first class citizens
        in Doctrine 2 and can be used as runtime mapping for the ORM. See the
        docs on XML and YAML Mapping for an example how to register this metadata
        drivers as primary mapping source.

    To convert some mapping information between the various supported
    formats you can use the ``ClassMetadataExporter`` to get exporter
    instances for the different formats:

    .. code-block:: php

        <?php
        $cme = new \Doctrine\ORM\Tools\Export\ClassMetadataExporter();

    Once you have a instance you can use it to get an exporter. For
    example, the yml exporter:

    .. code-block:: php

        <?php
        $exporter = $cme->getExporter('yml', '/path/to/export/yml');

    Now you can export some ``ClassMetadata`` instances:

    .. code-block:: php

        <?php
        $classes = array(
          $em->getClassMetadata('Entities\User'),
          $em->getClassMetadata('Entities\Profile')
        );
        $exporter->setMetadata($classes);
        $exporter->export();

    This functionality is also available from the command line to
    convert your loaded mapping information to another format. The
    ``orm:convert-mapping`` command accepts two arguments, the type to
    convert to and the path to generate it:

    .. code-block:: php

        $ php doctrine orm:convert-mapping xml /path/to/mapping-path-converted-to-xml


Adding own commands
-------------------

You can also add your own commands on-top of the Doctrine supported
tools by adding them to your binary.

To include a new command on Doctrine Console, you just need to add your command to the list
of commands to provide in ``bin/phpcr``.
