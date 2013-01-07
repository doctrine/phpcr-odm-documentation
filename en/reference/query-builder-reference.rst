Query Builder Reference
=======================

The ODM query builder allows you to pragmatically construct queries.

In a nutshell:

.. code-block:: php

   <?php
   
   $dm = // .. get the document manager
   $qb = $dm->createQueryBuilder();
   $qb->from('nt:unstructured');
   $qb->where($qb->expr()->eq('phpcr:class', 'DCMS\Bundle\BlogBundle\Document\Blog'));
   $blogs = $qb->execute();

Note on usage
~~~~~~~~~~~~~

Note that by convention the code examples use the variable ``$qb`` to represent
the ``QueryBuilder`` object.

Query Builder
-------------



.. _qbref_expressionbuilder:

Expression Builder
------------------

To specify expressions

.. _qbref_expr_andx:

andX
~~~~

Join two or more expressions with an **AND** constraint.

.. code-block:: php

    <?php

    $qb->expr()->andX(
        $qb->expr()->eq('tag', 'dogs')
        $qb->expr()->eq('owner', 'daniel')
    );

.. _qbref_expr_orx:

orX
~~~

Join two or more expressions with an **OR** constraint.

.. code-block:: php

    <?php

    $qb->expr()->andX(
        $qb->expr()->eq('tag', 'dogs')
        $qb->expr()->eq('tag', 'cats')
    );

.. _qbref_expr_eq:

eq (equal)
~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be 
equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->eq('tag', 'dogs')

neq (not equal)
~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must **not** 
be equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->neq('tag', 'cats')

.. _qbref_expr_gt:

gt (greater than)
~~~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be greater 
than the given value.

.. code-block:: php

    <?php

    $qb->expr()->gt('number_of_logins', 50)

.. _qbref_expr_gte:

gte (greater than or equal)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be greater 
than or equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->gte('number_of_logins', 50)

.. _qbref_expr_lt:

lt (less than)
~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be less 
than the given value.

.. code-block:: php

    <?php

    $qb->expr()->lt('number_of_logins', 50)

.. _qbref_expr_lte:

lte (less than or equal)
~~~~~~~~~~~~~~~~~~~~~~~~

Specify that the value of the given field name on candidate documents must be less 
than or equal to the given value.

.. code-block:: php

    <?php

    $qb->expr()->lte('number_of_logins', 50)
