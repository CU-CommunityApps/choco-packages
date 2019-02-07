# encoding: utf-8
# module Scripts._lzma
# from C:\Users\cit-labs\PycharmProjects\untitled\venv\Scripts\_lzma.pyd
# by generator 1.146
# no doc

# imports
from _lzma import LZMACompressor, LZMADecompressor, LZMAError


# Variables with simple values

CHECK_CRC32 = 1
CHECK_CRC64 = 4

CHECK_ID_MAX = 15

CHECK_NONE = 0
CHECK_SHA256 = 10
CHECK_UNKNOWN = 16

FILTER_ARM = 7
FILTER_ARMTHUMB = 8
FILTER_DELTA = 3
FILTER_IA64 = 6
FILTER_LZMA1 = 4611686018427387905
FILTER_LZMA2 = 33
FILTER_POWERPC = 5
FILTER_SPARC = 9
FILTER_X86 = 4

FORMAT_ALONE = 2
FORMAT_AUTO = 0
FORMAT_RAW = 3
FORMAT_XZ = 1

MF_BT2 = 18
MF_BT3 = 19
MF_BT4 = 20
MF_HC3 = 3
MF_HC4 = 4

MODE_FAST = 1
MODE_NORMAL = 2

PRESET_DEFAULT = 6
PRESET_EXTREME = 2147483648

# functions

def is_check_supported(*args, **kwargs): # real signature unknown
    """
    Test whether the given integrity check is supported.
    
    Always returns True for CHECK_NONE and CHECK_CRC32.
    """
    pass

def _decode_filter_properties(*args, **kwargs): # real signature unknown
    """
    Return a bytes object encoding the options (properties) of the filter specified by *filter* (a dict).
    
    The result does not include the filter ID itself, only the options.
    """
    pass

def _encode_filter_properties(*args, **kwargs): # real signature unknown
    """
    Return a bytes object encoding the options (properties) of the filter specified by *filter* (a dict).
    
    The result does not include the filter ID itself, only the options.
    """
    pass

# no classes
# variables with complex values

__loader__ = None # (!) real value is ''

__spec__ = None # (!) real value is ''

