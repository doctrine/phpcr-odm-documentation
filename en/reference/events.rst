Events
======

Doctrine PHPCR-ODM features a lightweight event system that is part of the
Common package.

For a general introduction, see the corresponding chapter in the `Doctrine ORM documentation <http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html>`_


Lifecycle Events
----------------

The DocumentManager and PHPCR-ODM UnitOfWork trigger a bunch of events during
the life-time of their registered documents.


- preRemove - occurs before a document is removed from the repository
- postRemove - occurs after the document has been successfully removed from the repository
- prePersist - occurs before a new document is created in the repository
- postPersist - occurs after a document has been created in repository. generated fields will be available in this state.
- preUpdate - occurs before an existing document is updated in the repository, during the flush operation
- postUpdate - occurs after an existing document has successfully been updated in the repository
- postLoad - occurs after the document has been loaded from the repository
- postFlush - occurs at the end of a flush operation. This event is not a lifecycle callback.
- onClear - occurs when the DocumentManager#clear() operation is invoked, after all references to documents
  have been removed from the unit of work.
- loadClassMetadata - occurs after mapping metadata for a class has been loaded from a mapping source
  (annotations/xml/yaml).
- preFlush - occurs at the very beginning of a flush operation. This event is not a lifecycle callback.
- onFlush - occurs after the change-sets of all managed documents have been computed. This event is not a lifecycle
  callback.
- preMove - occurs before a document is moved to the target path
- postMove - occurs after a document has been moved to the target path

.. note::

    If you use PHPCR-ODM inside Symfony2, you can use the tag
    doctrine_phpcr.event_listener to register a service as event listener.
    See the `Documentation of DoctrinePHPCRBundle <http://github.com/doctrine/DoctrinePHPCRBundle>`_
    for more information.


.. warning::

    Note that the postLoad event occurs for a document
    before any associations have been initialized. Therefore it is not
    safe to access associations in a postLoad callback or event
    handler.


You can access the Event constants from the ``Event`` class in the
PHPCR-ODM package.

.. code-block:: php

    <?php
    use Doctrine\ODM\PHPCR\Event;
    echo Event::preUpdate;

These can be hooked into by two different types of event
listeners:


-  Lifecycle Callbacks are methods on the document classes that are
   called when the event is triggered. They receive absolutely no
   arguments and are specifically designed to allow changes inside the
   document classes state.
-  Lifecycle Event Listeners are classes with specific callback
   methods that receives some kind of ``EventArgs`` instance which
   give access to the entity, EntityManager or other relevant data.

.. _events_lifecyclecallbacks:

Lifecycle Callbacks
-------------------

A lifecycle event is a regular event with the additional feature of
providing a mechanism to register direct callbacks inside the
corresponding document classes that are executed when the lifecycle
event occurs.

.. configuration-block::

    .. code-block:: php

        <?php
        /** @PrePersist */
        public function doStuffOnPrePersist()
        {
            $this->createdAt = date('Y-m-d H:m:s');
        }
        /** @PrePersist */
        public function doOtherStuffOnPrePersist()
        {
            $this->value = 'changed from prePersist callback!';
        }
        /** @PostPersist */
        public function doStuffOnPostPersist()
        {
            $this->value = 'changed from postPersist callback!';
        }
        /** @PostLoad */
        public function doStuffOnPostLoad()
        {
            $this->value = 'changed from postLoad callback!';
        }
        /** @PreUpdate */
        public function doStuffOnPreUpdate()
        {
            $this->value = 'changed from preUpdate callback!';
        }

    .. code-block:: yaml

        MyPersistentClass:
          lifecycleCallbacks:
            prePersist: [ doStuffOnPrePersist, doOtherStuffOnPrePersistToo ]
            postPersist: [ doStuffOnPostPersist ]

    .. code-block:: xml

        <?xml version="1.0" encoding="UTF-8"?>

        <doctrine-mapping>
            <document name="MyPersistentClass">
                <lifecycle-callbacks>
                    <lifecycle-callback type="prePersist" method="doStuffOnPrePersist"/>
                    <lifecycle-callback type="postPersist" method="doStuffOnPostPersist"/>
                </lifecycle-callbacks>
            </document>
        </doctrine-mapping>

The methods mapped to the callbacks in xml or yml need to be public methods of your document.

The ``key`` of the lifecycleCallbacks is the name of the method and
the value is the event type. The allowed event types are the ones
listed in the previous Lifecycle Events section.


.. note::

    Contrary to the ORM, PHPCR-ODM does **not** use the @HasLifecycleCallbacks marker.


Listening to Lifecycle Events
-----------------------------

This works exactly the same as with the `ORM events <http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/reference/events.html>`_.

Move events
-----------

When I move a document, the document is not be modified, except the ID.
The preFlush and onFlush events may modify the document before moving the document.

When $dm->flush is calling after $dm->move(), the order of events is:

1. preFlush
2. onFlush
3. preMove
4. postMove
5. postFlush

