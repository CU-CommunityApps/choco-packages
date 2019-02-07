# encoding: utf-8
# module errno
# from (built-in)
# by generator 1.146
"""
This module makes available standard errno system symbols.

The value of each symbol is the corresponding integer value,
e.g., on most systems, errno.ENOENT equals the integer 2.

The dictionary errno.errorcode maps numeric codes to symbol names,
e.g., errno.errorcode[2] could be the string 'ENOENT'.

Symbols that are not relevant to the underlying system are not defined.

To map error codes to error messages, use the function os.strerror(),
e.g. os.strerror(2) could return 'No such file or directory'.
"""
# no imports

# Variables with simple values

E2BIG = 7

EACCES = 13
EADDRINUSE = 10048
EADDRNOTAVAIL = 10049
EAFNOSUPPORT = 10047
EAGAIN = 11
EALREADY = 10037

EBADF = 9
EBADMSG = 104
EBUSY = 16

ECANCELED = 105
ECHILD = 10
ECONNABORTED = 10053
ECONNREFUSED = 10061
ECONNRESET = 10054

EDEADLK = 36
EDEADLOCK = 36
EDESTADDRREQ = 10039
EDOM = 33
EDQUOT = 10069

EEXIST = 17

EFAULT = 14
EFBIG = 27

EHOSTDOWN = 10064
EHOSTUNREACH = 10065

EIDRM = 111
EILSEQ = 42
EINPROGRESS = 10036
EINTR = 4
EINVAL = 22
EIO = 5
EISCONN = 10056
EISDIR = 21

ELOOP = 10062

EMFILE = 24
EMLINK = 31
EMSGSIZE = 10040

ENAMETOOLONG = 38
ENETDOWN = 10050
ENETRESET = 10052
ENETUNREACH = 10051
ENFILE = 23
ENOBUFS = 10055
ENODATA = 120
ENODEV = 19
ENOENT = 2
ENOEXEC = 8
ENOLCK = 39
ENOLINK = 121
ENOMEM = 12
ENOMSG = 122
ENOPROTOOPT = 10042
ENOSPC = 28
ENOSR = 124
ENOSTR = 125
ENOSYS = 40
ENOTCONN = 10057
ENOTDIR = 20
ENOTEMPTY = 41
ENOTRECOVERABLE = 127
ENOTSOCK = 10038
ENOTSUP = 129
ENOTTY = 25
ENXIO = 6

EOPNOTSUPP = 10045
EOVERFLOW = 132
EOWNERDEAD = 133

EPERM = 1
EPFNOSUPPORT = 10046
EPIPE = 32
EPROTO = 134
EPROTONOSUPPORT = 10043
EPROTOTYPE = 10041

ERANGE = 34
EREMOTE = 10071
EROFS = 30

ESHUTDOWN = 10058
ESOCKTNOSUPPORT = 10044
ESPIPE = 29
ESRCH = 3
ESTALE = 10070

ETIME = 137
ETIMEDOUT = 10060
ETOOMANYREFS = 10059
ETXTBSY = 139

EUSERS = 10068

EWOULDBLOCK = 10035

EXDEV = 18

WSABASEERR = 10000
WSAEACCES = 10013
WSAEADDRINUSE = 10048
WSAEADDRNOTAVAIL = 10049
WSAEAFNOSUPPORT = 10047
WSAEALREADY = 10037
WSAEBADF = 10009
WSAECONNABORTED = 10053
WSAECONNREFUSED = 10061
WSAECONNRESET = 10054
WSAEDESTADDRREQ = 10039
WSAEDISCON = 10101
WSAEDQUOT = 10069
WSAEFAULT = 10014
WSAEHOSTDOWN = 10064
WSAEHOSTUNREACH = 10065
WSAEINPROGRESS = 10036
WSAEINTR = 10004
WSAEINVAL = 10022
WSAEISCONN = 10056
WSAELOOP = 10062
WSAEMFILE = 10024
WSAEMSGSIZE = 10040
WSAENAMETOOLONG = 10063
WSAENETDOWN = 10050
WSAENETRESET = 10052
WSAENETUNREACH = 10051
WSAENOBUFS = 10055
WSAENOPROTOOPT = 10042
WSAENOTCONN = 10057
WSAENOTEMPTY = 10066
WSAENOTSOCK = 10038
WSAEOPNOTSUPP = 10045
WSAEPFNOSUPPORT = 10046
WSAEPROCLIM = 10067
WSAEPROTONOSUPPORT = 10043
WSAEPROTOTYPE = 10041
WSAEREMOTE = 10071
WSAESHUTDOWN = 10058
WSAESOCKTNOSUPPORT = 10044
WSAESTALE = 10070
WSAETIMEDOUT = 10060
WSAETOOMANYREFS = 10059
WSAEUSERS = 10068
WSAEWOULDBLOCK = 10035
WSANOTINITIALISED = 10093
WSASYSNOTREADY = 10091
WSAVERNOTSUPPORTED = 10092

# no functions
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

errorcode = {
    1: 'EPERM',
    2: 'ENOENT',
    3: 'ESRCH',
    4: 'EINTR',
    5: 'EIO',
    6: 'ENXIO',
    7: 'E2BIG',
    8: 'ENOEXEC',
    9: 'EBADF',
    10: 'ECHILD',
    11: 'EAGAIN',
    12: 'ENOMEM',
    13: 'EACCES',
    14: 'EFAULT',
    16: 'EBUSY',
    17: 'EEXIST',
    18: 'EXDEV',
    19: 'ENODEV',
    20: 'ENOTDIR',
    21: 'EISDIR',
    22: 'EINVAL',
    23: 'ENFILE',
    24: 'EMFILE',
    25: 'ENOTTY',
    27: 'EFBIG',
    28: 'ENOSPC',
    29: 'ESPIPE',
    30: 'EROFS',
    31: 'EMLINK',
    32: 'EPIPE',
    33: 'EDOM',
    34: 'ERANGE',
    36: 'EDEADLOCK',
    38: 'ENAMETOOLONG',
    39: 'ENOLCK',
    40: 'ENOSYS',
    41: 'ENOTEMPTY',
    42: 'EILSEQ',
    104: 'EBADMSG',
    105: 'ECANCELED',
    111: 'EIDRM',
    120: 'ENODATA',
    121: 'ENOLINK',
    122: 'ENOMSG',
    124: 'ENOSR',
    125: 'ENOSTR',
    127: 'ENOTRECOVERABLE',
    129: 'ENOTSUP',
    132: 'EOVERFLOW',
    133: 'EOWNERDEAD',
    134: 'EPROTO',
    137: 'ETIME',
    139: 'ETXTBSY',
    10000: 'WSABASEERR',
    10004: 'WSAEINTR',
    10009: 'WSAEBADF',
    10013: 'WSAEACCES',
    10014: 'WSAEFAULT',
    10022: 'WSAEINVAL',
    10024: 'WSAEMFILE',
    10035: 'WSAEWOULDBLOCK',
    10036: 'WSAEINPROGRESS',
    10037: 'WSAEALREADY',
    10038: 'WSAENOTSOCK',
    10039: 'WSAEDESTADDRREQ',
    10040: 'WSAEMSGSIZE',
    10041: 'WSAEPROTOTYPE',
    10042: 'WSAENOPROTOOPT',
    10043: 'WSAEPROTONOSUPPORT',
    10044: 'WSAESOCKTNOSUPPORT',
    10045: 'WSAEOPNOTSUPP',
    10046: 'WSAEPFNOSUPPORT',
    10047: 'WSAEAFNOSUPPORT',
    10048: 'WSAEADDRINUSE',
    10049: 'WSAEADDRNOTAVAIL',
    10050: 'WSAENETDOWN',
    10051: 'WSAENETUNREACH',
    10052: 'WSAENETRESET',
    10053: 'WSAECONNABORTED',
    10054: 'WSAECONNRESET',
    10055: 'WSAENOBUFS',
    10056: 'WSAEISCONN',
    10057: 'WSAENOTCONN',
    10058: 'WSAESHUTDOWN',
    10059: 'WSAETOOMANYREFS',
    10060: 'WSAETIMEDOUT',
    10061: 'WSAECONNREFUSED',
    10062: 'WSAELOOP',
    10063: 'WSAENAMETOOLONG',
    10064: 'WSAEHOSTDOWN',
    10065: 'WSAEHOSTUNREACH',
    10066: 'WSAENOTEMPTY',
    10067: 'WSAEPROCLIM',
    10068: 'WSAEUSERS',
    10069: 'WSAEDQUOT',
    10070: 'WSAESTALE',
    10071: 'WSAEREMOTE',
    10091: 'WSASYSNOTREADY',
    10092: 'WSAVERNOTSUPPORTED',
    10093: 'WSANOTINITIALISED',
    10101: 'WSAEDISCON',
}

__spec__ = None # (!) real value is ''

