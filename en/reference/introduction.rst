Getting Started
===============

.. note::

    **Difference from the ORM**

    Doctrine ORM knows several models of developing. If you know the ORM, please note that
    with PHPCR-ODM you can only develop "Code First". We do not (yet) have any generator to
    build model classes from a content repository.

    As PHPCR allows NoSQL like data storage, we speak of Documents rather than Entities
    to stress the fact that there need not be a rigid database model.

Doctrine PHPCR-ODM is an object-document mapper (ODM) for PHP 5.3.0+ that provides
transparent persistence for PHP objects. It uses the Data Mapper pattern at
the heart of this project, aiming for a complete separation of the domain/business
logic from the persistence in a content repository. The benefit of Doctrine for
the programmer is the ability to focus solely on the object-oriented business logic
and worry about persistence only as a secondary task. This doesn't mean persistence
is not important to Doctrine, however it is our belief that there are considerable benefits for
object-oriented programming if persistence and documents are kept perfectly
separated.

Starting with the object-oriented model is called the *Code First* approach to
Doctrine.


What are Documents?
-------------------

Documents are lightweight PHP Objects that don't need to extend any
abstract base class or interface. An entity class must not be final
or contain final methods. Additionally it must not implement
**clone** nor **wakeup** or :doc:`do so safely <../cookbook/implementing-wakeup-or-clone>`.

See the :doc:`architecture chapter <../reference/architecture>` for a full list of the restrictions
that your entities need to comply with.

A document contains persistable properties. A persistable property
is an instance variable of the document that is saved into and retrieved from the content repository
by Doctrine's data mapping capabilities.

An Example Model: Document Management
-------------------------------------

* Documents have a title and a content
* Documents are arranged in a tree
* Documents can reference other documents

We do not build a web interface but simple run scripts on the command line to keep this example simple.

.. note::
    This is a simplistic document manage to illustrate the PHPCR-ODM features. If you want to build a
    custom Web Content Management System, we recommend looking into the `Symfony CMF <http://cmf.symfony.com>`_
    which is a content management framework built on top of Doctrine PHPCR-ODM and Symfony2.


Setup Project
-------------

Create a file composer.json in your project directory.

::

    {
        "minimum-stability": "dev",
        "require": {
            "doctrine/phpcr-odm": "1.0.*",
            "jackalope/jackalope-doctrine-dbal": "1.0.*"
        }
        "autoload": {
          "psr-0": { "Demo\\": "src/" }
        }
    }

Then run the following commands on your command line

.. code-block:: bash

    $ curl -s http://getcomposer.org/installer | php --
    $ php composer.phar install

This will download the dependencies into the vendor/ folder and generate vendor/autoload.php

Now we bootstrap Doctrine PHPCR-ODM. Create a file called ``bootstrap.php``
in the project root directory::

    <?php
    // bootstrap.php

    $vendorDir = __DIR__.'/vendor';

    $file = $vendorDir.'/autoload.php';
    if (file_exists($file)) {
        $autoload = require_once $file;
    } else {
        throw new RuntimeException('Install dependencies to run test suite.');
    }

    use Doctrine\Common\Annotations\AnnotationRegistry;

    AnnotationRegistry::registerLoader(function($class) use ($autoload) {
        $autoload->loadClass($class);
        return class_exists($class, false);
    });
    AnnotationRegistry::registerFile(__DIR__.'/vendor/doctrine/phpcr-odm/lib/Doctrine/ODM/PHPCR/Mapping/Annotations/DoctrineAnnotations.php');

    $params = array(
        'driver'    => 'pdo_mysql',
        'host'      => 'localhost',
        'user'      => 'root',
        'password'  => '',
        'dbname'    => 'phpcr_odm_tutorial',
    );

    $workspace = 'default';
    $user = 'admin';
    $pass = 'admin';

    /* --- transport implementation specific code begin --- */
    $dbConn = \Doctrine\DBAL\DriverManager::getConnection($params);
    $parameters = array('jackalope.doctrine_dbal_connection' => $dbConn);
    $repository = \Jackalope\RepositoryFactoryDoctrineDBAL::getRepository($parameters);
    $credentials = new \PHPCR\SimpleCredentials(null, null);
    /* --- transport implementation specific code  ends --- */

    $session = $repository->login($credentials, $workspace);

    /* prepare the doctrine configuration */
    $config = new \Doctrine\ODM\PHPCR\Configuration();

    $documentManager = \Doctrine\ODM\PHPCR\DocumentManager::create($session, $config);

    return $autoload;


Building the model
------------------

Models are plain PHP classes. Note that you have several ways to define the mapping.
For easy readability, we use the annotation mapping in this tutorial::

    <?php
    // src/Demo/Document.php
    namespace Demo;

    use Doctrine\ODM\PHPCR\Mapping\Annotations as PHPCRODM;

    /**
     * @PHPCRODM\Document
     */
    class MyDocument
    {
        /**
         * @PHPCRODM\Id
         */
        private $id;
        /**
         * @PHPCRODM\ParentDocument
         */
        private $parent;
        /**
         * @PHPCRODM\Nodename
         */
        private $name;
        /**
         * @PHPCRODM\Children
         */
        private $children;
        /**
         * @PHPCRODM\String
         */
        private $title;

        /**
         * @PHPCRODM\String
         */
        private $content;

        public function getId()
        {
            return $this->id;
        }
        public function getChildren()
        {
            return $this->children;
        }
        public function setParent($parent)
        {
            $this->parent = $parent;
        }
        public function setName($name)
        {
            $this->name = $name;
        }

        public function setTitle($title)
        {
            $this->title = $title;
        }
        public function getTitle()
        {
            return $this->title;
        }
        public function setContent($content)
        {
            $this->content = $content;
        }
        public function getContent()
        {
            return $this->content;
        }
    }

If you are familiar with Doctrine ORM, this code should look pretty familiar to you. The
only important difference are the hierarchy related annotations ParentDocument, Name and Children.
In PHPCR, data is stored in trees. Every document has a parent and its own name. The id is
built from this structure, resulting in path strings. The recommended way to generate the
id is by assigning a name and a parent to the document. See the section on identifier
strategies in the reference chapter :doc:`Objects and Fields <basic-mapping>`
for other possibilities.

.. note::
    PHPCR-ODM provides default classes for the standard PHPCR node types ``nt:file``,
    ``nt:folder`` and ``nt:resource``, as well as a GenericDocument for when a PHPCR node
    can not be mapped to a specific document. See the classes in lib/Doctrine/ODM/PHPCR/Document/


Initialize the repository
-------------------------

With jackalope-doctrine-dbal, you need to run the command to init the database. TODO: explain how to setup (see phpcr-odm)
with any repo, you need to run register-system-nodetypes

Storing documents
-----------------

We write a simple PHP script to generate our data. Note that in real world, you should
look into the doctrine fixtures (TODO: reference) when generating content in scripts::

    <?php
    // src/generate.php
    require_once '../bootstrap.php';

    // get the root node to add our data to it
    $rootDocument = $documentManager->find(null, '/');

    // create a new document
    $doc = new \Demo\Document();
    $doc->setParent($rootDocument);
    $doc->setName('doc');
    $doc->setTitle('My first document');
    $doc->setContent('The document content');

    // create a second document
    $childDocument = new \Demo\Document();
    $childDocument->setParent($doc);
    $childDocument->setName('child');
    $childDocument->setTitle('My child document');
    $childDocument->setContent('The child document content');


    // make the documents known to the document manager
    $documentManager->persist($doc);
    $documentManager->persist($childDocument);

    // store all changes, insertions, etc. with the storage backend
    $documentManager->flush();


Reading documents
-----------------

This script will simply echo the data to the console::

    <?php
    // src/read.php
    require_once '../bootstrap.php';

    $doc = $documentManager->find(null, "/doc");
    echo 'Found '.$doc->getId() ."\n";
    echo 'Title: '.$doc->getTitle()."\n";
    echo 'Content: '.$doc->getContent()."\n";
    foreach($doc->getChildren() as $child) {
        if ($child instanceof \Demo\Document) {
            echo 'Has child '.$child->getId() . "\n";
        } else {
            echo 'Unexpected child '.get_class($child)."\n";
        }
    }

Children need not be of the same document class as their parents. Be careful when reading
children to be sure they are of the expected class.

Even if children are not mapped, you can use the document manager to get all
flushed children of a document::

    <?php

    $children = $documentManager->getChildren($parent);

.. note:: *Difference from ORM*
    While with the ORM, the natural thing to get data is to query, with
    PHPCR-ODM the natural way is to use the hierarchy, that is parent-child
    relations.

    If you need to query, see :ref:`Querying in the Working with Objects section <workingobjects-query>`.


Tree traversal
--------------

TODO: explain @Children and @Parent and $documentManager->getChildren.

Add references
--------------

TODO: explain @ReferenceOne and @ReferenceMany and @Referrers
and $documentManager->getReferrers


Removing documents
------------------

To delete a document, call the ``remove`` method on the ``DocumentManager``::

    <?php
    // src/manipulate.php
    require_once '../bootstrap.php';

    // remove a document
    $doc = $documentManager->find(null, '/doc');
    $documentManager->remove($doc);

    // persist all operations
    $documentManager->flush();


Other helpful methods on the DocumentManager
----------------------------------------------

You can move a document to a different path with the ``move`` method.
Alternatively, you can assign a different Parent and/or Nodename to move
by assignment. The latter is for example handy with Symfony2 forms::

    <?php
    // src/manipulate.php
    require_once '../bootstrap.php';

    // we move a node
    $child = $documentManager->find(null, '/doc/child');
    $documentManager->move($child, '/newpath');

    // persist all operations
    $documentManager->flush();


Conclusion
----------

This tutorial is over here, I hope you had fun.

Additional details on all the topics discussed here can be found in
the respective manual chapters.


