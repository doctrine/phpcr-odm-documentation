Inheritance Mapping
===================

Document class inheritance
--------------------------

Mapped documents can basically extend each other. It is even possible
to overwrite the mapping of the base class, but you should be very careful
with that, as this can lead to semantically broken data structures.

Typically, the purpose of such inheritance is to model the is-a relationship in
your models and to reuse the mappings and functions of the base class.


.. note::

    Contrary to ORM, the PHPCR-ODM with its NoSQL nature can handle documents
    that extend each other just like any other document. This means both
    your super class and the extending classes can be concrete classes and
    be stored in the repository.

    There are also no restrictions on referencing between any of those classes.

    You can also query for them, but if you query for documents of a specific
    type, you will not find the super type documents.

To use this feature, just have your document classes extend each other. You should not
repeat mappings that exist in the super class, to inherit them automatically.

TODO: what are the mappedsuperclass annotations doing?