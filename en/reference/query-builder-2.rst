.. _qbref:

The QueryBuilder
================

The PHPCR-ODM query builder enables you to create queries at the abstraction
level of the ODM using a fluent interface.

An example query:

.. code-block:: php

    <?php
    $qb = $documentManager->createQueryBuilder();

    $qb->from()->document('Blog\User', 'u');
    $qb->where()->eq()->field('u.name')->literal('dtl');

    $query = $qb->getQuery();

This query will select all documents of class ``Blog\User`` which
have a value of ``dtl`` for the field ``name``.

The first line retrieves a new instance of the query builder from the document
manager.

The second specifies that we want documents of type ``Blog\User`` and that
the string "u" will be used as the selector name.

The third line says that we want only documents where the value of the
field "name" from the selector named "u" is equal (eq) to the
literal string "dtl".

The forth and final line retrieves the :ref:`query <queryref>` object.

Alternatively the above query can be written more fluently by the using
``end()`` terminators as follows:

.. code-block:: php

    <?php
    $qb = $documentManager->createQueryBuilder();
    $qb->from()
        ->document('Blog\User')
      ->end()
      ->where()
        ->eq()
          ->field('a.name')
          ->literal('dtl')
        ->end()
      ->end();


Concepts
--------

Leaf and Factory Nodes
~~~~~~~~~~~~~~~~~~~~~~

The query builder is a tree structure composed of two different types of
nodes. *Factory nodes* and *Leaf nodes*. Factory node methods create and
add new nodes to the query builder tree and then return the newly created node. Factory methods
accept no arguments and always have *children*. 

Leaf nodes have no children and always return the parent node after adding
themselves to the query builder tree. The parent node is always a factory
node.

.. code-block:: php

    <?php
    // the query builder is a factory node
    $qb = $dm->createQueryBuilder();

    // from() returns a new factory node
    $from = $qb->from();

    // document() is a leaf node, it returns the parent factory
    $from = $from->document('Post', 'p');

    // end() returns the parent, in this case the query builder.
    $qb = $from->end();   

Retrieving a query builder instance
-----------------------------------

You can create instances of the query builder in one of two ways, either via
the ``DocumentManager`` or via a ``DocumentRepository``.

Via the document manager
~~~~~~~~~~~~~~~~~~~~~~~~

You can instantiate the ``QueryBuilder`` with the ``DocumentManager`` using the 
``createQueryBuilder`` method.

.. code-block:: php

    <?php
    $qb = $documentManager->createQueryBuilder();

Via a document repository
~~~~~~~~~~~~~~~~~~~~~~~~~

You can also instantiate a ``QueryBuilder`` from a ``DocumentRepsitory``
instance, doing so will automatically select only those records which are
associated with the ``DocumentRepository``.

.. code-block:: php

   <?php
   $postsRepository = $dm->getRepository('Blog\Post');
   $qb = $postsRepository->createQueryBuilder('p');
   $posts = $qb->getQuery()->execute();

The above code block will select all documents in the document tree of class
``Blog\Post``. This feature is especially useful within a document repository
class. 

Example showing the use of the query builder in a ``DocumentRepository``:

.. code-block:: php

   <?php

   namespace Blog;
   use Doctrine\ODM\PHPCR\DocumentRepository;

   class PostRepository extends DocumentRepository
   {
       public function getPostsByAuthor($authorName)
       {
           $qb = $this->createQueryBuilder('p');
           $qb->where()->eq()->field('p.author')->literal('dtl');

           return $qb->getQuery()->execute();
       }
   }

Note that we specify the string "a" as an argument to
``createQueryBuilder`` - this is the selector name (analagous to "alias" in
Doctrine ORM terms), more on these later.

Working with the QueryBuilder
-----------------------------

.. _qbref_from:

Specifying the document source - from
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ODM query builder requires you to specify a source from which records
should be selected. This source can either be a specified document or a
"join". Joins join two sources using a given "join condition".

.. note::

    A raw PHPCR query will allow you to select from ALL records and to hydrate
    a result set of mixed document classes, the PHPCR-ODM query builder
    requires however that you specify a single source - this is because the
    PHPCR query builder is not bound to the field mappings of the ODM.

From Single Source
""""""""""""""""""

.. code-block:: php

    <?php

    // select documents of class Foo\Bar.
    $qb->from()->document('Blog\Post', 'p');

The above example will setup the query builder to select documents only of class
``Blog\Post`` using the *selector name* "p". The selector name is the alias used
in subsequent references to this document source or properties within this
document.

From Joined Source
""""""""""""""""""

Joins allow you to take other documents into account when selecting records.

.. code-block:: php

    <?php

    // select documents from a join
    $qb->from()->joinInner()
        ->left()->document('Blog\Post', 'p')->end()
        ->right()->document('Blog\User', 'u')->end()
        ->condition()->equi('p.username', 'u.username')->end();

    $qb->where()
        ->eq()->field('u.username')->literal('dantleech');

Join two document sources using an inner join. We use an "equi" (equality)
join condition where the property named "username" from selector "p"
(``Blog\Post``) is equal to the property "username" from selector "u"
(``Blog\User``). We can then reference the user document in a constraint as
demonstrated.

.. _qbref_select:

Selecting specific properties - select
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can fields to populate with values using the ``select`` factory node, this is
currently only useful when :ref:`hydrating to PHPCR nodes
<queryref_hydration>`. The default (object) hydration will *always* hydrate all
fields regardless of what you specify.

.. code-block:: php

   <?php
   $qb->from('Demo\User', 'u');
   $qb->select()
     ->field('u.firstname')
     ->field('u.lastname');

   $query = $qb->getQuery();

   // field selection only used when hydrating to nodes
   $node = $query->getSingleResult(Query::HYDRATE_PHPCR);
   $node->getProperty('firstname');

.. _qbref_limiting:

Limiting the number of results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify a maximum number of results and the index of the first result
(the offset).

.. code-block:: php

   <?php
   // select a maximum of 10 records.
   $qb->from()->document('User')
      ->setMaxResults(10);

   // select a maximum of 10 records from the position of the 20th record.
   $qb->from()->document('User')
      ->setMaxResults(10)
      ->setFirstResult(20); 

.. _qbref_where:

Specifying selection criteria
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify selection criteria using the ``where`` factory node.

.. code-block:: php

   <?php

   // setup our document source with selector "a"
   $qb->from('Blog\User', 'u');

   // where name is "daniel"
   $qb->where()
     ->eq()->field('u.name')->literal('daniel');

   // where username is "dtl" AND name is "daniel"
   $qb->where()->eq()->field('u.username')->literal('dtl');
   $qb->andWhere()->eq()->field('u.name')->literal('daniel');

   // which is equivalent to
   $qb->where()->andX()
     ->eq()->field('u.username')->literal('dtl')->end()
     ->eq()->field('u.name')->literal('daniel')->end();

   // where username is "dtl" OR name is "daniel"
   $qb->where()->eq()->field('u.username')->literal('dtl');
   $qb->orWhere()->eq()->field('u.name')->literal('daniel');

   // which is equivalent to
   $qb->where()->orX()
     ->eq()->field('u.username')->literal('dtl')->end()
     ->eq()->field('u.name')->literal('daniel')->end();

   // where the lowercase value of node name is equal to dtl
   $qb->where()
       ->eq()
           ->lowercase()->documentLocalName('a')->end()
           ->literal('dtl');

   // where the lowercase value of node name is NOT equal to dtl
   $qb->where()
       ->eq()
           ->lowercase()->documentLocalName('a')->end()
           ->literal('dtl');

.. _qbref_ordering:

Ordering results
~~~~~~~~~~~~~~~~

You can specify the property or properties by which to order the queries
results with the ``orderBy`` factory node. You can specify additional
orderings with ``addOrderBy``.

Add a single ordering:

.. code-block:: php

   <?php

   $qb->orderBy()
     ->ascending()->field('username'); // username ascending

Descending:

.. code-block:: php

   <?php

   $qb->orderBy()
     ->descending()->field('username');

Add two orderings - equivilent to the SQL ``ORDER BY username, name ASC``:

.. code-block:: php

   <?php

   $qb->orderBy()
     ->ascending()->field('username');
     ->ascending()->field('name');
     ->descending()->field('website');

Adding multiple orderings using ``addOrderBy``:

.. code-block:: php

   <?php

   $qb->orderBy()->ascending()->field('username');
   $qb->addOrderBy()->ascending()->field('name');

Query Builder Reference
-----------------------

The following reference lists each factory node type starting with the query
builder itself.

Query Builder Factory
~~~~~~~~~~~~~~~~~~~~~

The query builder factory node is the root node of the query builder tree
and is the node you will initially work with.

select()
""""""""

Example:

.. code-block:: php
  
    // ...
    $qb->from('Blog\Post', 'p');
    $qb->select()
        ->field('p.title')
        ->field('p.username');

* **Type**: Factory
* **Returns**: :ref:`qbref_select`

addSelect()
"""""""""""

Example:

.. code-block:: php

    // ...
    $qb->addSelect()
        ->field('p.posted_on');

* **Type**: Factory
* **Returns**: :ref:`qbref_select`

from()
""""""

* **Type**: Factory
* **Returns**: :ref:`qbref_sourcefactory`

where()
"""""""

* **Type**: Factory
* **Returns**: :ref:`qbref_constraintfactory`

andWhere()
""""""""""

* **Type**: Factory
* **Returns**: :ref:`qbref_constraintfactory`

orWhere()
""""""""""

* **Type**: Factory
* **Returns**: :ref:`qbref_constraintfactory`

orderBy()
"""""""""

* **Type**: Factory
* **Returns**: :ref:`qbref_orderby`

addOrderBy()
""""""""""""

* **Type**: Factory
* **Returns**: :ref:`qbref_orderby`

Select Factory Reference
------------------------

The select node has only one leaf node

.. code-block:: php

    <?php
    $qb
        ->select()
            ->property('a', 'property_1')
            ->property('a', 'property_2')
        ->end()
        ->from()
            ->document('Post')
        ->end()
    ;

Source Factory Reference
------------------------


