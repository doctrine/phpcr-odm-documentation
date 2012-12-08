Annotations Reference
=====================

In this chapter a reference of every PHPCR-ODM Annotation is given with short
explanations on their context and usage.

Index
-----

-  :ref:`@Binary <annref_binary>`
-  :ref:`@Boolean <annref_boolean>`
-  :ref:`@Child <annref_child>`
-  :ref:`@Children <annref_children>`
-  :ref:`@Date <annref_date>`
-  :ref:`@Decimal <annref_decimal>`
-  :ref:`@Document <annref_document>`
-  :ref:`@Double <annref_double>`
-  :ref:`@Id <annref_id>`
-  :ref:`@Locale <annref_locale>`
-  :ref:`@Long <annref_long>`
-  :ref:`@MappedSuperclass <annref_mappedsuperclass>`
-  :ref:`@Name <annref_name>`
-  :ref:`@Node <annref_node>`
-  :ref:`@Nodename <annref_nodename>`
-  :ref:`@ParentDocument <annref_parentdocument>`
-  :ref:`@Path <annref_path>`
-  :ref:`@PostLoad <annref_postload>`
-  :ref:`@PostPersist <annref_postpersist>`
-  :ref:`@PostRemove <annref_postremove>`
-  :ref:`@PostUpdate <annref_postupdate>`
-  :ref:`@PrePersist <annref_prepersist>`
-  :ref:`@PreRemove <annref_preremove>`
-  :ref:`@PreUpdate <annref_preupdate>`
-  :ref:`@ReferenceMany <annref_referencemany>`
-  :ref:`@ReferenceOne <annref_referenceone>`
-  :ref:`@Referrers <annref_referrers>`
-  :ref:`@String <annref_string>`
-  :ref:`@Uri <annref_uri>`
-  :ref:`@Uuid <annref_uuid>`
-  :ref:`@VersionCreated <annref_versioncreated>`
-  :ref:`@VersionName <annref_versionname>`

Reference
---------

.. _annref_binary:

@Binary
~~~~~~~

Sets the type of the annotated instance variable to binary.

.. _annref_boolean:

@Boolean
~~~~~~~~

Sets the type of the annotated instance variable to boolean.

.. _annref_child:

@Child
~~~~~~

Required attributes:

- **name**: Node name of the child document to map, this should be a string.

.. _annref_children:

@Children
~~~~~~~~~

Optional attributes:

- **filter**: Child name filter.
- **fetchDepth**: Performance optimisation, number of levels to prefetch and cache, 
  this should be an integer.
- **ignoreUntranslated**: Set to false to *not* throw exceptions on untranslated child
  documents.

.. code-block:: php

   <?php
    /** 
     * @Children(filter="a*", fetchDepth=3)
     */
    private $children;

.. _annref_date:

@Date
~~~~~

Sets the type of the annotated instance variable to DateTime.

.. _annref_decimal:

@Decimal
~~~~~~~~

Sets the type of the annotated instance variable to decimal. The decimal field 
uses the BCMath library which supports numbers of any size or precision.

.. _annref_document:

@Document
~~~~~~~~~

Optional attributes:

-  **nodeType**: PHPCR type for this node, default `nt:unstructured`.
-  **repositoryClass**: Name of the repository to use for this document.
-  **versionable**: Set to true to enable versioning, implies `referenceable`.
-  **referenceable**: Set to true to allow this node to be referenced.
-  **translator**: Determines how translations are stored, one of `attribute` or `child`. See :ref:`langauge mapping <multilang_mapping>`

Minimal example:

.. code-block:: php

   <?php
   /**
    * @Document(repositoryClass="MyProject\UserRepository")
    */
   class User
   {
     // ...
   }

Full example:

.. code-block:: php

   <?php
   /**
    * @Document(
    *   repositoryClass="MyProject\UserRepository",
    *   versionable=true,
    *   referenceable=true,
    *   translator="child"
    * )
    */
   class SomeDocument
   {
     // ...
   }

.. _annref_double:

@Double
~~~~~~~

Sets the type of the annotated instance variable to double. The PHP type will be **float**.

.. _annref_id:

@Id
~~~

The annotated instance variable will be marked as the document identifier.
See :ref:`identifiers <basicmapping_identifiers>`.

Required attributes:

- **strategy**: How to generate IDs, one of NONE, REPOSITORY, ASSIGNED or PARENT, default
  ASSIGNED. See :ref:`generation strategies <basicmapping_identifier_generation_strategies>`.


.. code-block:: php

   <?php
   /**
    * @Id(strategy="PARENT")
    */
   protected $id;

.. _annref_locale:

@Locale
~~~~~~~

Identifies the annotated instance variable as the field in which to store
the documents current locale. This field applies only to translated documents.

.. _annref_long:

@Long
~~~~~

Sets the type of the annotated instance variable to long. The PHP type will be **integer**.

.. _annref_mappedsuperclass:

@MappedSuperclass
~~~~~~~~~~~~~~~~~

A mapped superclass is an abstract or concrete class that provides
persistent document state and mapping information for its subclasses
but which is not itself an entity.

Optional attributes:

-  **nodeType**: PHPCR type for this node. Default `nt:unstructured`.
-  **repositoryClass**: Fully qualified name of the repository to use for this document.
-  **translator**: Determines how translations are stored, one of `attribute` or `child`. See :ref:`language mapping <multilang_mapping>`

.. code-block:: php

    <?php
    /** @MappedSuperclass */
    class MappedSuperclassBase
    {
        // ... fields and methods
    }

    /** @Document */
    class DocumentSubClassFoo extends MappedSuperclassBase
    {
        // ... fields and methods
    } 

.. _annref_name:

@Name
~~~~~

The annotated instance variable must be a valid XML CNAME value and
can be used to store a valid node name.

.. _annref_node:

@Node
~~~~~

The annotated instance variable will be populated with the underlying
PHPCR node. See :ref:`node field mapping <phpcraccess_nodefieldmapping>`.

.. _annref_nodename:

@Nodename
~~~~~~~~~

Mark the annotated instance variable as representing the name of the node. The name
of the node is the last part of the path. Changing the marked variable will update
the node path.

.. _annref_parentdocument:

@ParentDocument
~~~~~~~~~~~~~~~

The annotated instance variable will contain the nodes parent document. Assigning
a different parent will result in a move operation.

.. _annref_path:

@Path
~~~~~

The annotated instance variable must be a valid PHPCR node path and can be used to
store an arbitrary reference to another node.

.. _annref_postload:

@PostLoad
~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``postLoad``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`

.. code-block:: php

   <?php
    /** 
     * @PostLoad 
     */
    public function doSomethingOnPostLoad()
    {
       // ... do something after the Document has been loaded
    }

.. _annref_postpersist:

@PostPersist
~~~~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``postPersist``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`

.. code-block:: php

   <?php
    /** 
     * @PostPersist 
     */
    public function doSomethingOnPostPersist()
    {
      // ... do something after the document has been persisted
    }

.. _annref_postremove:

@PostRemove
~~~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``postRemove``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`

.. code-block:: php

   <?php
    /** 
     * @PostRemove
     */
    public function doSomethingOnPostRemove()
    {
      // ... do something after the document has been removed
    }

.. _annref_postupdate:

@PostUpdate
~~~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``postUpdate``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`

.. code-block:: php

   <?php
    /** 
     * @PostUpdate
     */
    public function doSomethingOnPostUpdate()
    {
      // ... do something after the document has been updated
    }

.. _annref_prepersist:

@PrePersist
~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``prePersist``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`

.. code-block:: php

   <?php
    /** 
     * @PrePersist
     */
    public function doSomethingOnPrePersist()
    {
      // ... do something before the document has been persisted
    }

.. _annref_preremove:

@PreRemove
~~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``preRemove``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`

.. code-block:: php

   <?php
    /** 
     * @PreRemove
     */
    public function doSomethingOnPreRemove()
    {
      // ... do something before the document has been removed
    }

.. _annref_preupdate:

@PreUpdate
~~~~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``preUpdate``
event. See :ref:`life cycle callbacks <events_lifecyclecallbacks>`


.. code-block:: php

   <?php
    /** 
     * @PreUpdate
     */
    public function doSomethingOnPreUpdate()
    {
      // ... do something before the document has been updated
    }

.. _annref_referencemany:

@ReferenceMany
~~~~~~~~~~~~~~

Optional attributes:

-  **targetDocument**: *string*, Specify type of target document class. Note that this
   is an optional parameter and by default you can associate *any* document.
-  **strategy**: *enum*, One of `weak`, `hard` or `path`. See :ref:`reference other documents <associationmapping_referenceotherdocuments>`.

.. code-block:: php

   <?php
   /**
    * @ReferenceMany(targetDocument="Phonenumber", strategy="hard")
    */
    protected $phonenumbers;

.. _annref_referenceone:

@ReferenceOne
~~~~~~~~~~~~~

Optional attributes:

-  **targetDocument**: Specify type of target document class. Note that this
   is an optional parameter and by default you can associate *any* document.
-  **strategy**: One of `weak`, `hard` or `path`. See :ref:`reference other documents <associationmapping_referenceotherdocuments>`.

.. _annref_referrers:

@Referrers
~~~~~~~~~~

Mark the annotated instance variable to contain the documents which refer to this document.

Optional attributes:

-  **filter**: Filters referrers by the referencing property name.
-  **referenceType**: One of `weak` or `hard`.

.. code-block:: 

   <?php
   /**
    * @Referrers(filter="myapp:mycustomnode | a*", referenceType="hard")
    */
   protected $myReferrers;
    
.. _annref_string:

@String
~~~~~~~

Sets the type of the annotated instance variable to string.

.. _annref_uri:

@Uri
~~~~

The annotated instance variable will be validated as an URI.

.. _annref_uuid:

@Uuid
~~~~~

The annotated instance variable will be populated with a UUID 
(Universally Unique Identifier). The UUID is immutable. For
this field to be reliably populated the document should be
*referenceable*.

.. _annref_versioncreated:

@VersionCreated
~~~~~~~~~~~~~~~

The annotated instance variable will be populated with the date
that the current document version was created. Applies only to
documents with the versionable attribute.

.. _annref_versionname:

@VersionName
~~~~~~~~~~~~

The annotated instance variable will be populated with the name
of the current version as given by PHPCR.
