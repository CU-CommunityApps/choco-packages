# encoding: utf-8
# module msvcrt
# from C:\Users\cit-labs\PycharmProjects\untitled\venv\Scripts\_asyncio.pyd
# by generator 1.146
# no doc
# no imports

# Variables with simple values

CRT_ASSEMBLY_VERSION = '14.0.23918.0'

LK_LOCK = 1
LK_NBLCK = 2
LK_NBRLCK = 4
LK_RLCK = 3
LK_UNLCK = 0

SEM_FAILCRITICALERRORS = 1
SEM_NOALIGNMENTFAULTEXCEPT = 4
SEM_NOGPFAULTERRORBOX = 2
SEM_NOOPENFILEERRORBOX = 32768

# functions

def getch(*args, **kwargs): # real signature unknown
    """
    Read a keypress and return the resulting character as a byte string.
    
    Nothing is echoed to the console. This call will block if a keypress is
    not already available, but will not wait for Enter to be pressed. If the
    pressed key was a special function key, this will return '\000' or
    '\xe0'; the next call will return the keycode. The Control-C keypress
    cannot be read with this function.
    """
    pass

def getche(*args, **kwargs): # real signature unknown
    """ Similar to getch(), but the keypress will be echoed if possible. """
    pass

def getwch(*args, **kwargs): # real signature unknown
    """ Wide char variant of getch(), returning a Unicode value. """
    pass

def getwche(*args, **kwargs): # real signature unknown
    """ Wide char variant of getche(), returning a Unicode value. """
    pass

def get_osfhandle(*args, **kwargs): # real signature unknown
    """
    Return the file handle for the file descriptor fd.
    
    Raises IOError if fd is not recognized.
    """
    pass

def heapmin(*args, **kwargs): # real signature unknown
    """
    Minimize the malloc() heap.
    
    Force the malloc() heap to clean itself up and return unused blocks
    to the operating system. On failure, this raises OSError.
    """
    pass

def kbhit(*args, **kwargs): # real signature unknown
    """ Return true if a keypress is waiting to be read. """
    pass

def locking(*args, **kwargs): # real signature unknown
    """
    Lock part of a file based on file descriptor fd from the C runtime.
    
    Raises IOError on failure. The locked region of the file extends from
    the current file position for nbytes bytes, and may continue beyond
    the end of the file. mode must be one of the LK_* constants listed
    below. Multiple regions in a file may be locked at the same time, but
    may not overlap. Adjacent regions are not merged; they must be unlocked
    individually.
    """
    pass

def open_osfhandle(*args, **kwargs): # real signature unknown
    """
    Create a C runtime file descriptor from the file handle handle.
    
    The flags parameter should be a bitwise OR of os.O_APPEND, os.O_RDONLY,
    and os.O_TEXT. The returned file descriptor may be used as a parameter
    to os.fdopen() to create a file object.
    """
    pass

def putch(*args, **kwargs): # real signature unknown
    """ Print the byte string char to the console without buffering. """
    pass

def putwch(*args, **kwargs): # real signature unknown
    """ Wide char variant of putch(), accepting a Unicode value. """
    pass

def SetErrorMode(*args, **kwargs): # real signature unknown
    """ Wrapper around SetErrorMode. """
    pass

def setmode(*args, **kwargs): # real signature unknown
    """
    Set the line-end translation mode for the file descriptor fd.
    
    To set it to text mode, flags should be os.O_TEXT; for binary, it
    should be os.O_BINARY.
    
    Return value is the previous mode.
    """
    pass

def ungetch(*args, **kwargs): # real signature unknown
    """
    Opposite of getch.
    
    Cause the byte string char to be "pushed back" into the
    console buffer; it will be the next character read by
    getch() or getche().
    """
    pass

def ungetwch(*args, **kwargs): # real signature unknown
    """ Wide char variant of ungetch(), accepting a Unicode value. """
    pass

# classes

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

