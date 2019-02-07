# encoding: utf-8
# module Scripts.pyexpat
# from C:\Users\cit-labs\PycharmProjects\untitled\venv\Scripts\pyexpat.pyd
# by generator 1.146
""" Python wrapper for Expat parser. """

# imports
import pyexpat.errors as errors # <module 'pyexpat.errors'>
import pyexpat.model as model # <module 'pyexpat.model'>
from pyexpat import XMLParserType


# Variables with simple values

EXPAT_VERSION = 'expat_2.2.4'

native_encoding = 'UTF-8'

XML_PARAM_ENTITY_PARSING_ALWAYS = 2
XML_PARAM_ENTITY_PARSING_NEVER = 0

XML_PARAM_ENTITY_PARSING_UNLESS_STANDALONE = 1

# functions

def ErrorString(*args, **kwargs): # real signature unknown
    """ Returns string error for given number. """
    pass

def ParserCreate(*args, **kwargs): # real signature unknown
    """ Return a new XML parser object. """
    pass

# classes

class ExpatError(Exception):
    # no doc
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    __weakref__ = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """list of weak references to the object (if defined)"""



error = ExpatError


# variables with complex values

expat_CAPI = None # (!) real value is ''

features = [
    (
        'sizeof(XML_Char)',
        1,
    ),
    (
        'sizeof(XML_LChar)',
        1,
    ),
    (
        'XML_DTD',
        0,
    ),
    (
        'XML_CONTEXT_BYTES',
        1024,
    ),
    (
        'XML_NS',
        0,
    ),
]

version_info = (
    2,
    2,
    4,
)

__loader__ = None # (!) real value is ''

__spec__ = None # (!) real value is ''

