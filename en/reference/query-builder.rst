The QueryBuilder
================

The ``QueryBuilder`` provides an API that is designed for
programmatically constructing an ODM query object.

It provides a set of classes and methods that is able to
programmatically build queries, and also provides a fluent API.

Creating a query builder instance
---------------------------------

You can create instances of ``QueryBuilder`` in one of two ways, either via
the ``DocumentManager`` or via a ``DocumentRepository``.

Via the document manager
~~~~~~~~~~~~~~~~~~~~~~~~

You can create the ``QueryBuilder`` with the ``DocumentManager`` using the 
``createQueryBuilder`` method.

.. code-block:: php

    <?php
    $qb = $documentManager->createQueryBuilder();

The following example gets all documents where the ``name`` property
is equal to ``daniel`` and orders the results by ``username`` in ascending order.

.. code-block:: php

   <?php

   $qb->where($qb->expr()->eq('name', 'daniel'))
      ->orderBy('username', 'ASC');

   $query = $qb->getQuery();   
   $users = $query->execute();

.. note::

   Unlike the ORM it is not nescessary to specify a source to select from, the above
   example will **any** document matching the criteria.

Via a document repository
~~~~~~~~~~~~~~~~~~~~~~~~~

You can also create a ``QueryBuilder`` from a ``DocumentRepsitory`` instance, doing so
will automatically select only those records which are associated with the ``DocumentRepository``.

.. code-block:: php

   <?php

   $postsRepository = $dm->getRepository('MyVendor/Blog/Document/Post');
   $qb = $postsRepository->createQueryBuilder();
   $posts = $qb->getQuery()->execute();

The above code block will select all documents in the document tree of class ``Post``. This
feature is especially usefull within a document repository class.

.. code-block:: php

   <?php

   namespace MyVendor\Blog\Repository;
   use Doctrine\ODM\PHPCR\DocumentRepository;

   class Post extends DocumentRepository
   {
       public function getPostsByAuthor($authorName)
       {
           $qb = $this->createQueryBuilder();
           $qb->where(
               $qb->expr('author', 'dtl')
           );

           return $qb->getQuery()->execute();
       }
   }


.. _qbref_workingwiththequerybuilder:

Working with the QueryBuilder
-----------------------------

.. _qbref_select:

Selecting specific properties - select
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: php

   <?php
   $qb->select('username')
      ->addSelect('firstname')
      ->addSelect('lastname');

.. note:: 
   
   Select is currently only usefull with PHPCR hydration, ODM hydration will
   hydrate all fields regardless of the column selection.

.. _qbref_limiting:

Limiting the number of results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify a maximum number of results and the index of the first result
(the offset).

.. code-block:: php

   <?php
   // select a maximum of 10 records.
   $qb->from('MyVendor/Blog/Document/User')
      ->setMaxResults(10);

   // select a maximum of 10 records from the position of the 20th record.
   $qb->from('MyVendor/Blog/Document/User')
      ->setMaxResults(10)
      ->setFirstResult(20); 

.. _qbref_from:
.. _qbref_nodeType:

Restrict query to document class or node type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can restrict **either** the document class **or** the node type. Attempting to
specify both will result in an Exception because by setting the document class
you are implicitly setting the node type.

.. code-block:: php

   <?php

   $dm->getQueryBuilder()
      ->from('MyVendor/Blog/Document/User'); // select only from user documents

   // or

   $dm->getQueryBuilder()
      ->nodeType('nt:mynodetype'); // select only documents with node type nt:mynodetype.

   // but not

   $dm->getQueryBuilder()
      ->nodeType('nt:mynodetype')
      ->from('MyVendor/Blog/Document/User')
      ->getQuery(); // this will throw an Exception.

.. _qbref_where:

Specifying selection criteria
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify selection criteria, or :ref:`Expressions <qbref_expressionbuilder>`, with the ``where`` method. You
can add additional Expressions with ``andWhere`` and ``orWhere``.

.. code-block:: php

   <?php

   // where name is "daniel"
   $qb->where($qb->expr()->eq('name', 'daniel'));

   // where username is "dtl" AND name is "daniel"
   $qb->where($qb->expr()->eq('username', 'dtl'));
      ->andWhere($qb->expr()->eq('name', 'daniel'));

   // which is equivalent to
   $qb->where($qb->expr()->andX(
       $qb->expr()->eq('username', 'dtl'),
       $qb->expr()->eq('name', 'daniel')
   ));

   // where username is "dtl" OR name is "daniel"
   $qb->where($qb->expr()->eq('username', 'dtl'))
      ->orWhere($qb->expr()->eq('name', 'daniel'));

   // which is equivalent to
   $qb->where($qb->expr()->orX(
       $qb->expr()->eq('username', 'dtl'),
       $qb->expr()->eq('name', 'daniel')
   ));

.. _qbref_ordering:

Ordering results
~~~~~~~~~~~~~~~~

You can specify the property or properties by which to order the queries results
with the ``orderBy`` method. You can specify additional orderings with ``addOrderBy``,
or you can pass an array of property names to ``orderBy``.

The ordering direction is specified as either ``ASC`` (ascending order, e.g. a-z, 0-9) or ``DESC``
(descending order, e.g. z-a, 9-0). The default is ``ASC``.

Add a single ordering:

.. code-block:: php

   <?php

   $qb->orderBy('username', 'ASC'); // username assending

Descending:

.. code-block:: php

   <?php

   $qb->orderBy('username', 'DESC'); // username descending

Add two orderings:

.. code-block:: php

   <?php

   $qb->orderBy('username');
   $qb->addOrderBy('name'); // username then name ascending (ORDER BY username, name ASC)

Add two orderings by passing an array to ``orderBy``:

.. code-block:: php

   <?php

   $qb->orderBy(array('username', 'name'), 'ASC'); // same as previous example

.. _qbref_expressionbuilder:

The Expression Builder
----------------------

The ``ExpressionBuilder`` is a class which allows you to programatically construct selection
criteria. It is created through the factory method ``expr()`` of the query builder. The return
value is accepted by :ref:`where <qbref_where>`.

.. _qbref_expr_andx:

andX (and eXpression)
~~~~~~~~~~~~~~~~~~~~~

Join two or more expressions with an *AND* constraint.

.. code-block:: php

    <?php

    $qb->expr()->andX(
        $qb->expr()->eq('tag', 'dogs'),
        $qb->expr()->eq('owner', 'daniel')
    );

.. _qbref_expr_orx:

orX (or eXpression)
~~~~~~~~~~~~~~~~~~~

Join two or more expressions with an *OR* constraint.

.. code-block:: php

    <?php

    $qb->expr()->andX(
        $qb->expr()->eq('tag', 'dogs'),
        $qb->expr()->eq('tag', 'cats')
    );

.. _qbref_expr_eq:

eq (equal)
~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be 
equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->eq('tag', 'dogs');

neq (not equal)
~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must **not** 
be equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->neq('tag', 'cats');

.. _qbref_expr_gt:

gt (greater than)
~~~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be greater 
than the given value.

.. code-block:: php

    <?php

    $qb->expr()->gt('number_of_logins', 50);

.. _qbref_expr_gte:

gte (greater than or equal)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be greater 
than or equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->gte('number_of_logins', 50);

.. _qbref_expr_lt:

lt (less than)
~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be less 
than the given value.

.. code-block:: php

    <?php

    $qb->expr()->lt('number_of_logins', 50);

.. _qbref_expr_lte:

lte (less than or equal)
~~~~~~~~~~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be less 
than or equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->lte('number_of_logins', 50);

.. _qbref_phpcrquerybuilder:

The PHPCR QueryBuilder
----------------------

The PHPCR QueryBuilder is a lower level and more verbose query builder available in the PHPCR Utils
package and is not part of the ODM package, as such we will not document it extensively here and it
is recommended that you use the ODM query builder. 

This query builder does not know about the ODM layer, which means that it produces PHPCR queries
and not ODM queries. To hydrate Documents from the results of a PHPCR query you need to use the
``getDocumentsByPhpcrQuery`` method of the document manager.

See the `PHPCR Documentation <http://phpcr.github.com/doc/html-all/index.html>`_ for more information.

Examples
~~~~~~~~

This query is equivalent to the JCR-SQL2 query ``SELECT * FROM nt:unstructured WHERE name NOT IS NULL``

.. code-block:: php

    <?php

    /** @var $qb QueryBuilder */
    $qb = $dm->getPhpcrQueryBuilder();
    $factory = $qb->getQOMFactory();
    $qb->from($factory->selector('nt:unstructured'))
        ->where($factory->propertyExistence('name'))
        ->execute();

    $result = $documentManager->getDocumentsByPhpcrQuery($qb->getQuery());
    foreach ($result as $document) {
        echo $document->getId();
    }

The maximum number of results (limit) can be set with the setMaxResults method.
Furthermore the position of the first result to be retrieved (offset) can be
set with setFirstResult

.. code-block:: php

    <?php

    /** @var $qb QueryBuilder */
    $factory = $qb->getQOMFactory();
    $qb->from($factory->selector('nt:unstructured'))
        ->where($factory->propertyExistence('name'))
        ->setFirstResult(5)
        ->setMaxResults(10)
        ->execute();

Getting all descendant nodes of /dms is as simple as adding a descendant node constraint:

.. code-block:: php

    <?php

    /** @var $qb QueryBuilder */
    $factory = $qb->getQOMFactory();
    $qb->from($factory->selector('nt:unstructured'))
        ->where($factory->descendantNode('/dms'))
        ->execute();

Note that if you just need the direct children of a document, you should use
the ``@Children`` annotation on the document.

If you want to know the SQL2 statement generated call getStatement() on the query object.

.. code-block:: php

    <?php
    //Prepare the query builder with the desired statement.
    //..
    echo $qb->getQuery()->getStatement();
