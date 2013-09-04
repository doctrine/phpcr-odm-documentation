.. _qbref:

The QueryBuilder
================

The PHPCR-ODM query builder enables you to create queries at the abstraction
level of the ODM using a fluent interface.

An example query:

.. code-block:: php

    $qb = $documentManager->createQueryBuilder();

    $qb->from()->document('MyApp\Document\User', 'u');
    $qb->where()->eq()->propertyValue('u', 'name')->literal('dtl');

    $query = $qb->getQuery();

This query will select all documents of class ``MyApp\Document\User`` which
have a value of ``dtl`` for the field ``name``.

The first line retrieves a new instance of the query builder from the document
manager.

The second specifies that we want documents of type ``MyApp\User`` and that
the string "u" will be used as the selector name.

The third line says that we want only documents where the value of the
property (propertyValue) "name" from the selector named "u" is equal (eq) to the
literal string "dtl".

The forth and final line retrieves the :ref:`query <queryref>` object.

Alternatively the above query can be written more fluently by the using
"end()" terminators as follows:

.. code-block:: php

    $qb = $documentManager->createQueryBuilder();
    $qb->from()
        ->document('MyApp\User')
      ->end()
      ->where()
        ->eq()
          ->propertyValue('a', 'name')
          ->literal('dtl')
        ->end()
      ->end();


Leaf and Factory Nodes
----------------------

The query builder is a tree structure composed of two different types of
nodes. *Factory nodes* and *Leaf nodes*. Factory node methods create and
add new nodes to the query builder tree and then return the newly created node. Factory methods
accept no arguments and always have *children*. 

Leaf nodes have no children and always return the parent node after adding
themselves to the query builder tree. The parent node is always a factory
node.

.. code-block:: php

    // the query builder is a factory node
    $qb = $dm->createQueryBuilder();

    // from() returns a new factory node
    $from = $qb->from();

    // document() is a leaf node, it returns the parent factory
    $from = $from->document('MyApp\Document\Post');

    // end() returns the parent, in this case the query builder.
    $qb = $from->end();   

Retrieving a query builder instance
-----------------------------------

You can create instances of the query builder in one of two ways, either via
the ``DocumentManager`` or via a ``DocumentRepository``.

Via the document manager
~~~~~~~~~~~~~~~~~~~~~~~~

You can create the ``QueryBuilder`` with the ``DocumentManager`` using the 
``createQueryBuilder`` method.

.. code-block:: php

    <?php
    $qb = $documentManager->createQueryBuilder();

Via a document repository
~~~~~~~~~~~~~~~~~~~~~~~~~

You can also create a ``QueryBuilder`` from a ``DocumentRepsitory`` instance,
doing so will automatically select only those records which are associated
with the ``DocumentRepository``.

.. code-block:: php

   <?php

   $postsRepository = $dm->getRepository('MyVendor/Blog/Document/Post');
   $qb = $postsRepository->createQueryBuilder('a');
   $posts = $qb->getQuery()->execute();

The above code block will select all documents in the document tree of class ``Post``. This
feature is especially useful within a document repository class. Note that we
specify the string "a" as an argument to ``createQueryBuilder`` - this is the
selector, more on these later.

Example showing the use of the query builder in a ``DocumentRepository``:

.. code-block:: php

   <?php

   namespace MyVendor\Blog\Repository;
   use Doctrine\ODM\PHPCR\DocumentRepository;

   class Post extends DocumentRepository
   {
       public function getPostsByAuthor($authorName)
       {
           $qb = $this->createQueryBuilder('a');
           $qb->where()->eq()->propertyValue('a', 'author')->literal('dtl');

           return $qb->getQuery()->execute();
       }
   }

Working with the QueryBuilder
-----------------------------

.. _qbref_select:

Selecting specific properties - select
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: php

   <?php
   $qb->select()
     ->property('firstname')
     ->property('lastname');

.. note:: 
   
   Select is currently only usefull with PHPCR hydration, ODM hydration will
   hydrate all fields regardless of the column selection.

.. _qbref_from:


Specifying the document source - from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ODM query builder requires you to specify a single source from which
records should be selected. This source can either be a specified document or
a "join". Joins join two sources using a given "join condition".

.. code-block:: php

    <?php

    // select documents of class Foo\Bar.
    $qb->from()->document('Foo\Bar', 'a');

The above example setsup the query builder to select documents only of class
``Foo\Bar`` using the *selector name* "a". The selector name is the alias used
in subsequent references to this document source or properties within this
document.

.. code-block:: php

    <?php

    // select documents from a join
    $qb->from()->joinInner()
        ->left()->document('Foo\Bar', 'a')->end()
        ->right()->document('Foo\Bat', 'b')->end()
        ->condition()->equi('a', 'prop_1', 'b', 'prop_2')->end();

Join two document sources using an inner join. We use an "equi" (equality)
join condition where the property named "prop_1" from selector "a"
(``Foo\Bar``) is equal to the property "prop_2" from selector "b"
(``Foo\Bat``).

+++++++++++++++ TODO ++++++++++++++++

Not sure how hydration is handled here, would be good to explain it.

+++++++++++++++++++++++++++++++++++++

.. note::

    A raw PHPCR query will allow you to select from ALL records and to hydrate
    a result set of mixed document classes, the PHPCR-ODM query builder
    requires however that you specify a single source - this is because the
    PHPCR query builder is not bound to the field mappings of the ODM.

.. _qbref_limiting:

Limiting the number of results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify a maximum number of results and the index of the first result
(the offset).

.. code-block:: php

   <?php
   // select a maximum of 10 records.
   $qb->from()->document('MyVendor/Blog/Document/User')
      ->setMaxResults(10);

   // select a maximum of 10 records from the position of the 20th record.
   $qb->from()->document('MyVendor/Blog/Document/User')
      ->setMaxResults(10)
      ->setFirstResult(20); 

.. _qbref_where:

Specifying selection criteria
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify selection criteria using the ``where`` factory.

.. code-block:: php

   <?php

   // setup our document source with selector "a"
   $qb->from('Users', 'a');

   // where name is "daniel"
   $qb->where()
     ->eq()->propertyValue('a', 'name')->literal('daniel');

   // where username is "dtl" AND name is "daniel"
   $qb->where()->eq()->propertyValue('a', 'username')->literal('dtl');
   $qb->andWhere()->eq()->propertyValue('a', 'name')->literal('daniel');

   // which is equivalent to
   $qb->where()->andX()
     ->eq()->propertyValue('a', 'username')->literal('dtl')->end()
     ->eq()->propertyValue('a', 'name')->literal('daniel')->end();

   // where username is "dtl" OR name is "daniel"
   $qb->where()->eq()->propertyValue('a', 'username')->literal('dtl');
   $qb->orWhere()->eq()->propertyValue('a', 'name')->literal('daniel');

   // which is equivalent to
   $qb->where()->orX()
     ->eq()->propertyValue('a', 'username')->literal('dtl')->end()
     ->eq()->propertyValue('a', 'name')->literal('daniel')->end();

   // where the lowercase value of node name is equal to dtl
   $qb->where()
       ->eq()
           ->lowercase()->documentLocalName('a')->end()
           ->literal('dtl');

.. _qbref_ordering:

Ordering results
~~~~~~~~~~~~~~~~

You can specify the property or properties by which to order the queries
results with the ``orderBy`` factory method. You can specify additional
orderings with ``addOrderBy``.

Add a single ordering:

.. code-block:: php

   <?php

   $qb->orderBy()
     ->ascending()->propertyValue('username'); // username ascending

Descending:

.. code-block:: php

   <?php

   $qb->orderBy()
     ->descending()->propertyValue('username');

Add two orderings - equivilent to the SQL ``ORDER BY username, name ASC``:

.. code-block:: php

   <?php

   $qb->orderBy()
     ->ascending()->propertyValue('username');
     ->ascending()->propertyValue('name');

Adding multiple orderings using ``addOrderBy``:

.. code-block:: php

   <?php

   $qb->orderBy()->ascending()->propertyValue('username');
   $qb->addOrderBy()->ascending()->propertyValue('name');

Builder Reference
-----------------

+===============+==========+====================+
| Method        | Type     | Factory            |
+===============+==========+====================+
| select        | Factory  | select             |
+---------------+----------+--------------------+
| addSelect     | Factory  | select             |
+---------------+----------+--------------------+
| from          | Factory  | source             |
+---------------+----------+--------------------+
| where         | Factory  | constraint         |
+---------------+----------+--------------------+
| andWhere      | Factory  | constraint         |
+---------------+----------+--------------------+
| orWhere       | Factory  | constraint         |
+---------------+----------+--------------------+
| orderBy       | Factory  | order              |
+---------------+----------+--------------------+
| addOrderBy    | Factory  | order              |
+---------------+----------+--------------------+

Select Factory Reference
------------------------

The select node has only one leaf node

.. code-block:: php
    $qb
        ->select()
            ->property('a', 'property_1')
            ->property('a', 'property_2')
        ->end()
        ->from()
            ->document('MyApp\Document\Post')
        ->end()
    ;

Source Factory Reference
------------------------


