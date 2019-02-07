# encoding: utf-8
# module parser
# from (built-in)
# by generator 1.146
""" This is an interface to Python's internal parser. """
# no imports

# Variables with simple values

__copyright__ = 'Copyright 1995-1996 by Virginia Polytechnic Institute & State\nUniversity, Blacksburg, Virginia, USA, and Fred L. Drake, Jr., Reston,\nVirginia, USA.  Portions copyright 1991-1995 by Stichting Mathematisch\nCentrum, Amsterdam, The Netherlands.'

__version__ = '0.5'

# functions

def compilest(*args, **kwargs): # real signature unknown
    """ Compiles an ST object into a code object. """
    pass

def expr(*args, **kwargs): # real signature unknown
    """ Creates an ST object from an expression. """
    pass

def isexpr(*args, **kwargs): # real signature unknown
    """ Determines if an ST object was created from an expression. """
    pass

def issuite(*args, **kwargs): # real signature unknown
    """ Determines if an ST object was created from a suite. """
    pass

def sequence2st(*args, **kwargs): # real signature unknown
    """ Creates an ST object from a tree representation. """
    pass

def st2list(*args, **kwargs): # real signature unknown
    """ Creates a list-tree representation of an ST. """
    pass

def st2tuple(*args, **kwargs): # real signature unknown
    """ Creates a tuple-tree representation of an ST. """
    pass

def suite(*args, **kwargs): # real signature unknown
    """ Creates an ST object from a suite. """
    pass

def tuple2st(*args, **kwargs): # real signature unknown
    """ Creates an ST object from a tree representation. """
    pass

def _pickler(*args, **kwargs): # real signature unknown
    """ Returns the pickle magic to allow ST objects to be pickled. """
    pass

# classes

class ParserError(Exception):
    # no doc
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    __weakref__ = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """list of weak references to the object (if defined)"""



class STType(object):
    """ Intermediate representation of a Python parse tree. """
    def compile(self, *args, **kwargs): # real signature unknown
        """ Compile this ST object into a code object. """
        pass

    def isexpr(self, *args, **kwargs): # real signature unknown
        """ Determines if this ST object was created from an expression. """
        pass

    def issuite(self, *args, **kwargs): # real signature unknown
        """ Determines if this ST object was created from a suite. """
        pass

    def tolist(self, *args, **kwargs): # real signature unknown
        """ Creates a list-tree representation of this ST. """
        pass

    def totuple(self, *args, **kwargs): # real signature unknown
        """ Creates a tuple-tree representation of this ST. """
        pass

    def __eq__(self, *args, **kwargs): # real signature unknown
        """ Return self==value. """
        pass

    def __ge__(self, *args, **kwargs): # real signature unknown
        """ Return self>=value. """
        pass

    def __gt__(self, *args, **kwargs): # real signature unknown
        """ Return self>value. """
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    def __le__(self, *args, **kwargs): # real signature unknown
        """ Return self<=value. """
        pass

    def __lt__(self, *args, **kwargs): # real signature unknown
        """ Return self<value. """
        pass

    def __ne__(self, *args, **kwargs): # real signature unknown
        """ Return self!=value. """
        pass

    def __sizeof__(self, *args, **kwargs): # real signature unknown
        """ Returns size in memory, in bytes. """
        pass

    __hash__ = None


class __loader__(object):
    """
    Meta path import for built-in modules.
    
        All methods are either class or static methods to avoid the need to
        instantiate the class.
    """
    @classmethod
    def create_module(cls, *args, **kwargs): # real signature unknown
        """ Create a built-in module """
        pass

    @classmethod
    def exec_module(cls, *args, **kwargs): # real signature unknown
        """ Exec a built-in module """
        pass

    @classmethod
    def find_module(cls, *args, **kwargs): # real signature unknown
        """
        Find the built-in module.
        
                If 'path' is ever specified then the search is considered a failure.
        
                This method is deprecated.  Use find_spec() instead.
        """
        pass

    @classmethod
    def find_spec(cls, *args, **kwargs): # real signature unknown
        pass

    @classmethod
    def get_code(cls, *args, **kwargs): # real signature unknown
        """ Return None as built-in modules do not have code objects. """
        pass

    @classmethod
    def get_source(cls, *args, **kwargs): # real signature unknown
        """ Return None as built-in modules do not have source code. """
        pass

    @classmethod
    def is_package(cls, *args, **kwargs): # real signature unknown
        """ Return False as built-in modules are never packages. """
        pass

    @classmethod
    def load_module(cls, *args, **kwargs): # real signature unknown
        """
        Load the specified module into sys.modules and return it.
        
            This method is deprecated.  Use loader.exec_module instead.
        """
        pass

    def module_repr(module): # reliably restored by inspect
        """
        Return repr for the module.
        
                The method is deprecated.  The import machinery does the job itself.
        """
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    __weakref__ = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """list of weak references to the object (if defined)"""


    __dict__ = None # (!) real value is ''


# variables with complex values

__spec__ = None # (!) real value is ''

