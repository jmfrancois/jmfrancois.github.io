---
title: ReferenceEngine and poor Archetypes
categories: ["en"]
tags: ["plone"]
date: 2008-03-07
---

Today, got a bug on custom content type. “I can’t copy your content type, all the references are lost”

Well, i assume i don’t know how copy / paste works in plone. I first reproduce the bug without a pb:

Create two documents : a and b. set related document from b to a. means b has related document a. the field relatesTo is a ReferenceField.
Make a copy of b, said c.
Oh !!! c has no related document.
The bug is reproduce: ReferenceField doesn t support copy . Now i know that, i m starting to read all i found about References in Archetypes, and find this in Referenceable.py:

```python
####
## In the case of:
## - a copy:
##   * we want to lose refs on the new object
##   * we want to keep refs on the orig object
## - a cut/paste
##   * we want to keep refs
## - a delete:
##   * to lose refs
####
```

So this is not a bug but a feature ? Don’t be disapointed, Plone is build to be customized. CopySupport comes from zope, ok interesting code out there. I m finally try to MonkeyPath the methode manage_afterAdd and succedd in keep the reference:

```python
## OFS Hooks
def manage_afterAdd(self, item, container):
    """
    Get a UID
    (Called when the object is created or moved.)
    """
    print "Referenceable manage after add"
    isCopy = getattr(item, '_v_is_cp', None)
    if isCopy:
        setattr(self, config.UUID_ATTR, None)
        self._delReferenceAnnotations()
```

Every things ok ? Well no, in fact, i m trying to validate by retry the scenario above. c document has the related document to a. good, but i next delete c and that action delete the b relation with a (b doesn t have relation with a anymore). And Archetypes team writes ## * we want to lose refs on the new object ??? You call this a feature, i call that an error of referenceengine design !

Thank you Archeytpes !

If anyone know how to fix this i m ready to listen :)