The QueryBuilder
================

The ``QueryBuilder`` provides an API that is designed for
programmatically constructing a query in several steps.

It provides a set of classes and methods that is able to
programmatically build queries, and also provides a fluent API.

The QueryBuilder of PHPCR-ODM is provided by the phpcr-utils library.
See `PHPCR-utils > Namespaces > PHPCR\Util\QOM\QueryBuilder <http://phpcr.github.com/doc/html-all/index.html>`_
for a full documentation on the QueryBuilder methods.

The actual tests and such are done by the PHPCR Query Object Model factory,
defined by ``PHPCR\Query\QOM\QueryObjectModelFactoryInterface``


Constructing a new QueryBuilder object
--------------------------------------

The same way you build a normal Query, you build a ``QueryBuilder``
object, with a factory method on the DocumentManager:

.. code-block:: php

    <?php
    /** @var $dm DocumentManager */

    $qb = $dm->createQueryBuilder();

Once you have created an instance of QueryBuilder, it provides you
with the methods to build a query.


Working with QueryBuilder
-------------------------

This query is equivalent to the JCR-SQL2 query ``SELECT * FROM nt:unstructured WHERE name NOT IS NULL``

.. code-block:: php

    <?php

    /** @var $qb QueryBuilder */
    $factory = $qb->getQOMFactory();
    $qb->from($factory->selector('nt:unstructured'))
        ->where($factory->propertyExistence('name'))
        ->execute();

    $result = $documentManager->getDocumentsByQuery($qb->getQuery());
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