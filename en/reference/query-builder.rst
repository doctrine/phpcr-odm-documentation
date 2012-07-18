The QueryBuilder
================

A ``QueryBuilder`` provides an API that is designed for
programmatically constructing a query in several steps.

It provides a set of classes and methods that is able to
programmatically build queries, and also provides a fluent API.

The QueryBuilder of PHPCR-ODM is provided by the phpcr-utils library.
See TODO for a full documentation on the QueryBuilder methods.

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
    $qb->select($factory->selector('nt:unstructured'))
        ->where($factory->propertyExistance('name'))
        ->setFirstResult(10)
        ->setMaxResults(10)
        ->execute();
    $result = $documentManager->getDocumentsByQuery($qb->getQuery());
    foreach ($result as $document) {
        echo $document->getId();
    }

