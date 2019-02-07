# encoding: utf-8
# module _json
# from (built-in)
# by generator 1.146
""" json speedups """
# no imports

# functions

def encode_basestring(string): # real signature unknown; restored from __doc__
    """
    encode_basestring(string) -> string
    
    Return a JSON representation of a Python string
    """
    return ""

def encode_basestring_ascii(string): # real signature unknown; restored from __doc__
    """
    encode_basestring_ascii(string) -> string
    
    Return an ASCII-only JSON representation of a Python string
    """
    return ""

def scanstring(string, end, strict=True): # real signature unknown; restored from __doc__
    """
    scanstring(string, end, strict=True) -> (string, end)
    
    Scan the string s for a JSON string. End is the index of the
    character in s after the quote that started the JSON string.
    Unescapes all valid JSON string escape sequences and raises ValueError
    on attempt to decode an invalid string. If strict is False then literal
    control characters are allowed in the string.
    
    Returns a tuple of the decoded string and the index of the character in s
    after the end quote.
    """
    pass

# classes

class make_encoder(object):
    """ _iterencode(obj, _current_indent_level) -> iterable """
    def __call__(self, *args, **kwargs): # real signature unknown
        """ Call self as a function. """
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    default = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """default"""

    encoder = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """encoder"""

    indent = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """indent"""

    item_separator = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """item_separator"""

    key_separator = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """key_separator"""

    markers = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """markers"""

    skipkeys = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """skipkeys"""

    sort_keys = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """sort_keys"""



class make_scanner(object):
    """ JSON scanner object """
    def __call__(self, *args, **kwargs): # real signature unknown
        """ Call self as a function. """
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    object_hook = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """object_hook"""

    object_pairs_hook = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    parse_constant = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """parse_constant"""

    parse_float = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """parse_float"""

    parse_int = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """parse_int"""

    strict = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """strict"""



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

