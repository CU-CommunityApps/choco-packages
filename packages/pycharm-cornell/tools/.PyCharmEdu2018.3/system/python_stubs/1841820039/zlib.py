# encoding: utf-8
# module zlib
# from (built-in)
# by generator 1.146
"""
The functions in this module allow compression and decompression using the
zlib library, which is based on GNU zip.

adler32(string[, start]) -- Compute an Adler-32 checksum.
compress(data[, level]) -- Compress data, with compression level 0-9 or -1.
compressobj([level[, ...]]) -- Return a compressor object.
crc32(string[, start]) -- Compute a CRC-32 checksum.
decompress(string,[wbits],[bufsize]) -- Decompresses a compressed string.
decompressobj([wbits[, zdict]]]) -- Return a decompressor object.

'wbits' is window buffer size and container format.
Compressor objects support compress() and flush() methods; decompressor
objects support decompress() and flush().
"""
# no imports

# Variables with simple values

DEFLATED = 8

DEF_BUF_SIZE = 16384

DEF_MEM_LEVEL = 8

MAX_WBITS = 15

ZLIB_RUNTIME_VERSION = '1.2.11'

ZLIB_VERSION = '1.2.11'

Z_BEST_COMPRESSION = 9
Z_BEST_SPEED = 1

Z_BLOCK = 5

Z_DEFAULT_COMPRESSION = -1
Z_DEFAULT_STRATEGY = 0

Z_FILTERED = 1
Z_FINISH = 4
Z_FIXED = 4

Z_FULL_FLUSH = 3

Z_HUFFMAN_ONLY = 2

Z_NO_COMPRESSION = 0
Z_NO_FLUSH = 0

Z_PARTIAL_FLUSH = 1

Z_RLE = 3

Z_SYNC_FLUSH = 2

Z_TREES = 6

__version__ = '1.0'

# functions

def adler32(*args, **kwargs): # real signature unknown
    """
    Compute an Adler-32 checksum of data.
    
      value
        Starting value of the checksum.
    
    The returned checksum is an integer.
    """
    pass

def compress(*args, **kwargs): # real signature unknown
    """
    Returns a bytes object containing compressed data.
    
      data
        Binary data to be compressed.
      level
        Compression level, in 0-9 or -1.
    """
    pass

def compressobj(*args, **kwargs): # real signature unknown
    """
    Return a compressor object.
    
      level
        The compression level (an integer in the range 0-9 or -1; default is
        currently equivalent to 6).  Higher compression levels are slower,
        but produce smaller results.
      method
        The compression algorithm.  If given, this must be DEFLATED.
      wbits
        +9 to +15: The base-two logarithm of the window size.  Include a zlib
            container.
        -9 to -15: Generate a raw stream.
        +25 to +31: Include a gzip container.
      memLevel
        Controls the amount of memory used for internal compression state.
        Valid values range from 1 to 9.  Higher values result in higher memory
        usage, faster compression, and smaller output.
      strategy
        Used to tune the compression algorithm.  Possible values are
        Z_DEFAULT_STRATEGY, Z_FILTERED, and Z_HUFFMAN_ONLY.
      zdict
        The predefined compression dictionary - a sequence of bytes
        containing subsequences that are likely to occur in the input data.
    """
    pass

def crc32(*args, **kwargs): # real signature unknown
    """
    Compute a CRC-32 checksum of data.
    
      value
        Starting value of the checksum.
    
    The returned checksum is an integer.
    """
    pass

def decompress(*args, **kwargs): # real signature unknown
    """
    Returns a bytes object containing the uncompressed data.
    
      data
        Compressed data.
      wbits
        The window buffer size and container format.
      bufsize
        The initial output buffer size.
    """
    pass

def decompressobj(*args, **kwargs): # real signature unknown
    """
    Return a decompressor object.
    
      wbits
        The window buffer size and container format.
      zdict
        The predefined compression dictionary.  This must be the same
        dictionary as used by the compressor that produced the input data.
    """
    pass

# classes

class error(Exception):
    # no doc
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    __weakref__ = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """list of weak references to the object (if defined)"""



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

