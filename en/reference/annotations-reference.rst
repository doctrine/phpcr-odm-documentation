Annotations Reference
=====================

In this chapter a reference of every PHPCR-ODM annotation is given with short
explanations on their context and usage.

Note on usage
-------------

Note that the code examples are given without their namespaces, however it is
normally necessary to import the annotation namespace into your class, and to
prefix each annotation with the namespace as demonstrated in the following example:

.. code-block:: php

    <?php
    namespace MyProject\Bundle\BlogBundle\Document;
    use Doctrine\ODM\PHPCR\Mapping\Annotations as PHPCR;

    /**
     * @PHPCR\Document()
     */
    class Post
    {
        /**
         * @PHPCR\Id()
         */
        protected $id;

        /**
         * @PHPCR\ParentDocument()
         */
        protected $parent;

        /**
         * @PHPCR\NodeName
         */
        protected $title;
    }

Document
--------

.. _annref_document:

@Document
~~~~~~~~~

Optional attributes:

-  **nodeType**: PHPCR type for this node, default ``nt:unstructured``.
-  **repositoryClass**: Name of the repository to use for this document.
-  **versionable**: Set to true to enable versioning, implies *referenceable*.
-  **referenceable**: Set to true to allow this node to be referenced.
-  **translator**: Determines how translations are stored, one of ``attribute`` or ``child``. See :ref:`langauge mapping <multilang_mapping>`

Minimal example:

.. code-block:: php

   <?php
   /**
    * @Document()
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

.. _annref_mappedsuperclass:

@MappedSuperclass
~~~~~~~~~~~~~~~~~

A mapped superclass is an abstract or concrete class that provides
persistent document state and mapping information for its subclasses
but which is not itself a document.

.. note::

    Contrary to ORM, the PHPCR-ODM with its NoSQL nature can handle documents
    that extend each other just like any other document, so you only need mapped
    superclasses in special situations. See also :doc:`Inheritance Mapping <inheritance-mapping>`.


Optional attributes:

-  **nodeType**: PHPCR type for this node. Default ``nt:unstructured``.
-  **repositoryClass**: Fully qualified name of the repository to use for
   documents extending this superclass.
-  **translator**: Determines how translations are stored, one of ``attribute``
   or ``child``. See :ref:`language mapping <multilang_mapping>`.

.. code-block:: php

    <?php
    /**
     * @MappedSuperclass()
     */
    class MappedSuperclassBase
    {
        // ... fields and methods
    }

    /**
     * @Document()
     */
    class DocumentSubClassFoo extends MappedSuperclassBase
    {
        // ... fields and methods
    }


Value Fields
------------

These mappings mark the annotated instance variable as "persistent". They need to be
specified inside the instance variables associated PHP DocBlock comment. Any value
held inside these variables will be saved to and loaded from the storage layer as part
of the lifecycle of the instance variables document class.

.. _annref_valuefieldattribs:

Common optional attributes:

- **assoc**: Specify that this attribute should be an associative array. The value should
  be a string which will be used by the PHPCR node. Set to an empty string to automatically
  use the name of the annotated variable appended by "Keys".
- **multivalue**: ``true`` to specify that this property should be treated as a simple array.
  See :ref:`Mapping multivalue properties <basicmapping_mappingmultivalueproperties>`.
- **translated**: ``true`` to specify that the property should be translatable, requires the
  ``translator`` attribute to be specified in :ref:`@Document<annref_document>`.
- **nullable**: ``true`` to specifiy that this property doesn't have a required value, used 
  when loading a translation, to allow loading a node with a missing translated property.

Examples:

.. code-block:: php

   <?php

   /**
    * @String(translated=true)
    */
   protected $title;

   /**
    * @String(translated=true, nullable=true)
    */
   protected $subTitle;

   /**
    * @Boolean()
    */
   protected $enabled;

   /**
    * @String(multivalue=true)
    */
   protected $keywords; // e.g. array('dog', 'cat', 'mouse')

   /**
    * @Double(assoc="")
    */
   protected $exchangeRates; // e.g. array('GBP' => 0.810709, 'EUR' => 1, 'USD' => 1.307460)


.. _annref_binary:

@Binary
~~~~~~~

Sets the type of the annotated instance variable to binary.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_boolean:

@Boolean
~~~~~~~~

Sets the type of the annotated instance variable to boolean.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_date:

@Date
~~~~~

Sets the type of the annotated instance variable to DateTime.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_decimal:

@Decimal
~~~~~~~~

Sets the type of the annotated instance variable to decimal. The decimal field
uses the BCMath library which supports numbers of any size or precision.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_double:

@Double
~~~~~~~

Sets the type of the annotated instance variable to double. The PHP type will be **float**.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_long:

@Long
~~~~~

Sets the type of the annotated instance variable to long. The PHP type will be **integer**.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_name:

@Name
~~~~~

The annotated instance variable must be a valid XML CNAME value and
can be used to store a valid node name.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_path:

@Path
~~~~~

The annotated instance variable must be a valid PHPCR node path and can be used to
store an arbitrary reference to another node.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_string:

@String
~~~~~~~

Sets the type of the annotated instance variable to string.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

.. _annref_uri:

@Uri
~~~~

The annotated instance variable will be validated as an URI.

Attributes:

- Inherits :ref:`value field attributes <annref_valuefieldattribs>`.

Hierarchy
---------

These mappings mark the annotated instance variables to contain instances of Documents
above or below the current Document in the document hierarchy. They need to be
specified inside the instance variables associated PHP DocBlock comment.

.. _annref_child:

@Child
~~~~~~

The annotated instance variable will be populated with the named document
directly below the instance variables document class in the document hierarchy.

Required attributes:

- **name**: Node name of the child document to map, this should be a string.

.. code-block:: php

   <?php
   /**
    * @Child(name="Preferences")
    */
   protected $preferences;

.. _annref_children:

@Children
~~~~~~~~~

The annotated instance variable will be populated with Documents directly below the
instance variables document class in the document hierarchy.

Optional attributes:

- **filter**: Child name filter; only return children whose names match the given filter.
- **fetchDepth**: Performance optimisation, number of levels to pre-fetch and cache,
  this should be an integer.
- **ignoreUntranslated**: Set to false to *not* throw exceptions on untranslated child
  documents.

.. code-block:: php

   <?php
    /**
     * @Children(filter="a*", fetchDepth=3)
     */
    private $children;

.. _annref_parentdocument:

@ParentDocument
~~~~~~~~~~~~~~~

The annotated instance variable will contain the nodes parent document. Assigning
a different parent will result in a move operation.

.. code-block:: php

   <?php

   /**
    * @ParentDocument
    */
   private $parent;

Identification
--------------

These mappings help to manage the identification of the document class.

.. _annref_id:

@Id
~~~

The annotated instance variable will be marked with the documents
identifier. The ID is the **full path** to the document in the document hierarchy.
See :ref:`identifiers <basicmapping_identifiers>`.

Required attributes:

- **strategy**: How to generate IDs, one of ``NONE``, ``REPOSITORY``, ``ASSIGNED`` or ``PARENT``, default
  is ``PARENT`` See :ref:`generation strategies <basicmapping_identifier_generation_strategies>`.

.. code-block:: php

   <?php
   /**
    * @Id()
    */
   protected $id; // e.g. /path/to/mydocument

.. _annref_nodename:

@Nodename
~~~~~~~~~

Mark the annotated instance variable as representing the name of the node. The name
of the node is the last part of the :ref:`ID <annref_id>`. Changing the marked variable will update
the nodes ID.

.. code-block:: php

   <?php
   /**
    * @Id()
    */
   protected $id; // e.g. /path/to/mydocument

   /**
    * @NodeName()
    */
   protected $nodeName; // e.g. mydocument

.. _annref_uuid:

@Uuid
~~~~~

The annotated instance variable will be populated with a UUID
(Universally Unique Identifier). The UUID is immutable. For
this field to be reliably populated the document should be
*referenceable*.

.. code-block:: php

   <?php
   /**
    * @Uuid()
    */
   protected $uuid; // e.g. 508d6621-0c20-4972-bf0e-0278ccabe6e5

Lifcycle callbacks
------------------

These annotations, applied to a method, will cause the method to be called automatically
by the ODM on the :ref:`lifecycle event <events_lifecyclecallbacks>` corresponding to the name
of the annotation.

.. note::

   Unlike the Doctrine ORM it is **not** necessary to specify a ``@HasLifecycleCallbacks``
   annotation.

.. _annref_postload:

@PostLoad
~~~~~~~~~

Life cycle callback. The marked method will be called automatically on the ``postLoad``
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`

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
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`

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
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`

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
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`

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
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`

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
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`

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
event. See :ref:`lifecycle callbacks <events_lifecyclecallbacks>`


.. code-block:: php

   <?php
    /**
     * @PreUpdate
     */
    public function doSomethingOnPreUpdate()
    {
      // ... do something before the document has been updated
    }

PHPCR
-----

.. _annref_node:

@Node
~~~~~

The annotated instance variable will be populated with the underlying
PHPCR node. See :ref:`node field mapping <phpcraccess_nodefieldmapping>`.

References
----------

.. _annref_referencemany:

@ReferenceMany
~~~~~~~~~~~~~~

Optional attributes:

-  **targetDocument**: Specify type of target document class. Note that this
   is an optional parameter and by default you can associate *any* document.
-  **strategy**: One of ``weak``, ``hard`` or ``path``. See :ref:`reference other documents <associationmapping_referenceotherdocuments>`.

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

.. code-block:: php

   <?php
   /**
    * @ReferenceOne(targetDocument="Contact", strategy="hard")
    */
    protected $contact;

.. _annref_referrers:

@Referrers
~~~~~~~~~~

Mark the annotated instance variable to contain the documents which refer to this document.

Optional attributes:

-  **filter**: Filters referrers by the referencing property name.
-  **referenceType**: One of ``weak`` or ``hard``.

.. code-block:: php

   <?php
   /**
    * @Referrers(referenceType="hard")
    */
   protected $myReferrers;

Translation
-----------

These annotations only apply to documents where the ``translator`` attribute is
specified in :ref:`@Document<annref_document>`.

Example:

.. code-block:: php

    <?php
    /**
     * @Document(translator="attribute")
     */
    class MyDocument
    {
       /**
        * @Locale
        */
       protected $locale;

       /**
        * @String(translated=true)
        */
       protected $title;
    }

.. _annref_locale:

@Locale
~~~~~~~

Identifies the annotated instance variable as the field in which to store
the documents current locale.

Versioning
----------

These annotations only apply to documents where the ``versionable`` attribute is
specified in :ref:`@Document<annref_document>`.

See :ref:`versioning mappings <versioning_mappings>`.

Example:

.. code-block:: php

    <?php
    /**
     * @Document(versionable="simple")
     */
    class MyPersistentClass
    {
        /**
         * @VersionName
         */
        private $versionName;

        /**
         * @VersionCreated
         */
        private $versionCreated;
    }

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
