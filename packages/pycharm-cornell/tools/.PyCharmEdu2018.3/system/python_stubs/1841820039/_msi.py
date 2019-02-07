# encoding: utf-8
# module _msi
# from (pre-generated)
# by generator 1.146
""" Documentation """
# no imports

# Variables with simple values

MSICOLINFO_NAMES = 0
MSICOLINFO_TYPES = 1

MSIDBOPEN_CREATE = 3
MSIDBOPEN_CREATEDIRECT = 4
MSIDBOPEN_DIRECT = 2
MSIDBOPEN_PATCHFILE = 32
MSIDBOPEN_READONLY = 0
MSIDBOPEN_TRANSACT = 1

MSIMODIFY_ASSIGN = 3
MSIMODIFY_DELETE = 6
MSIMODIFY_INSERT = 1

MSIMODIFY_INSERT_TEMPORARY = 7

MSIMODIFY_MERGE = 5
MSIMODIFY_REFRESH = 0
MSIMODIFY_REPLACE = 4
MSIMODIFY_SEEK = -1
MSIMODIFY_UPDATE = 2
MSIMODIFY_VALIDATE = 8

MSIMODIFY_VALIDATE_DELETE = 11
MSIMODIFY_VALIDATE_FIELD = 10
MSIMODIFY_VALIDATE_NEW = 9

PID_APPNAME = 18
PID_AUTHOR = 4
PID_CHARCOUNT = 16
PID_CODEPAGE = 1
PID_COMMENTS = 6

PID_CREATE_DTM = 12

PID_KEYWORDS = 5
PID_LASTAUTHOR = 8
PID_LASTPRINTED = 11

PID_LASTSAVE_DTM = 13

PID_PAGECOUNT = 14
PID_REVNUMBER = 9
PID_SECURITY = 19
PID_SUBJECT = 3
PID_TEMPLATE = 7
PID_TITLE = 2
PID_WORDCOUNT = 15

# functions

def CreateRecord(*args, **kwargs): # real signature unknown
    """
    OpenDatabase(name, flags) -> dbobj
    Wraps MsiCreateRecord
    """
    pass

def FCICreate(*args, **kwargs): # real signature unknown
    """ fcicreate(cabname,files) -> None """
    pass

def OpenDatabase(name, flags): # real signature unknown; restored from __doc__
    """
    OpenDatabase(name, flags) -> dbobj
    Wraps MsiOpenDatabase
    """
    pass

def UuidCreate(): # real signature unknown; restored from __doc__
    """ UuidCreate() -> string """
    return ""

# classes

class MSIError(Exception):
    # no doc
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    __weakref__ = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """list of weak references to the object (if defined)"""



# variables with complex values

__loader__ = None # (!) real value is ''

__spec__ = None # (!) real value is ''

