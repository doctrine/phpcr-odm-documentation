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

The query builder is a tree structure composed of two different categories of
nodes. *Factory nodes* and *Leaf nodes*. Factory nodes create and
add new nodes to the query builder tree and then return the newly created node. Factory methods
accept no arguments and always have *children*. A factory node has zero
arguments.

Leaf nodes have no children and always return the parent node after adding
themselves to the query builder tree. The parent node is always a factory
node and the leaf node always has arguments.

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

Fluent Interface
~~~~~~~~~~~~~~~~

The API makes use of a fluent API which enables an entire query to be
constructed in a single, unbroken, statement.

Factory node methods append nodes as children to themselves and return either
other factory nodes or, if the factory method returns a leaf, the method will
return its owning class instance.

.. code-block:: php

    <?php
    $qb->where()->eq()->field('p.title', 'p')->literal('My Post');

In the example above:

* The ``where`` method of the ``QueryBuilder`` adds and returns a
  ``ConstraintFactory`` which provides the ``eq()`` method. 

* The ``eq()`` method adds and returns an ``OperandFactory`` which contains the
  ``field()`` and ``literal()`` methods. 

Up to this point the return values have all been factory classes. 

* The ``field()`` and ``literal()`` methods add leaf nodes and they return the
  same class of which they are part - the ``OperandFactory`` - the same node
  which provides the ``eq()`` method.

This model presents a problem when we want to proceed to a previous node
without breaking the chain, this is where the ``end()`` method comes in.

The ``end()`` method is a special method that will always return the parent of the
current node, allowing us to construct the query in full without breaking the
chain. A practical application of this is when we do more complicated things,
such as chaining operands:

.. code-block:: php

    <?php
    $qb->wwhere()->eq()->lowerCase()->field('p.title')->end()->literal('my post');

Here the ``lowerCase()`` method would return the ``LowerCase`` operand, which will
transform the value of its child member to lowercase. Because ``field()`` will
return its parent we need to call ``end()`` to go back once more to the
``ConstraintFactory`` (as returned by ``eq()``).

.. note::

    It is only necessary to add an ``end()`` terminator when you wish to
    append additional leaf nodes in the *same statement*. In this document we
    will not add ``end()`` terminators where they are not required.

Types and Cardinality
~~~~~~~~~~~~~~~~~~~~~

Each node has an associated node type:

.. code-block:: php

    <?php
    $qb->getNodeType(); // returns "builder"
    $qb->where()->getNodeType(); // returns "where"
    $qb->andWhere()->getNodeType(); // returns "where"
    $qb->where()->eq()->getNodeType(); // returns "constraint"
    $qb->where()->eq()->field()->getNodeType(); // returns "operand"

Node types (not to be confused with PHPCR node types) are used to validate the
query builder trees structure. Each factory node declares how many children of
each type it is allowed, this is the node child cardinality map. The
:doc:`query-builder-reference` document lists the cardinalities of all the
factory nodes.

Exceeding or not achieving the minimum or maximum child cardinality for a
given node type will cause an exception to be thrown when retrieving the
query, for example:

.. code-block:: php

    <?php
    // throws exception, query builder node needs at least one "from".
    $qb->getQuery(); 

    // throws exception, eq() needs one dynamic and one static operand
    $qb->where()->eq()->field('p.title');
    $qb->getQuery();

    // throws exception, eq() needs one dynamic and one static operand
    $qb->where()->eq()->field('p.title')->field('p.name');
    $qb->getQuery();

    // ok
    $qb->where()->eq()->field('p.title')->litreal('My Post');
    $qb->getQuery();

The cardinality for each node is documented in the
:doc:`query-builder-reference`, for an example see
:ref:`qbref_node_querybuilder`.

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
    requires however that you specify a single document source - this is because the
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
        ->condition()->equi('p.username', 'u.username');

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

You can specify fields to populate with values using the ``select`` factory
node, this is currently only useful when :ref:`hydrating to PHPCR nodes
<queryref_hydration>`. The default (object) hydration will *always* hydrate
all fields regardless of what you specify.

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

   // setup our document source with selector "u"
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
