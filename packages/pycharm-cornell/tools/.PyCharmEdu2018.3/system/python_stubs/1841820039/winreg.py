# encoding: utf-8
# module winreg
# from (built-in)
# by generator 1.146
"""
This module provides access to the Windows registry API.

Functions:

CloseKey() - Closes a registry key.
ConnectRegistry() - Establishes a connection to a predefined registry handle
                    on another computer.
CreateKey() - Creates the specified key, or opens it if it already exists.
DeleteKey() - Deletes the specified key.
DeleteValue() - Removes a named value from the specified registry key.
EnumKey() - Enumerates subkeys of the specified open registry key.
EnumValue() - Enumerates values of the specified open registry key.
ExpandEnvironmentStrings() - Expand the env strings in a REG_EXPAND_SZ
                             string.
FlushKey() - Writes all the attributes of the specified key to the registry.
LoadKey() - Creates a subkey under HKEY_USER or HKEY_LOCAL_MACHINE and
            stores registration information from a specified file into that
            subkey.
OpenKey() - Opens the specified key.
OpenKeyEx() - Alias of OpenKey().
QueryValue() - Retrieves the value associated with the unnamed value for a
               specified key in the registry.
QueryValueEx() - Retrieves the type and data for a specified value name
                 associated with an open registry key.
QueryInfoKey() - Returns information about the specified key.
SaveKey() - Saves the specified key, and all its subkeys a file.
SetValue() - Associates a value with a specified key.
SetValueEx() - Stores data in the value field of an open registry key.

Special objects:

HKEYType -- type object for HKEY objects
error -- exception raised for Win32 errors

Integer constants:
Many constants are defined - see the documentation for each function
to see what constants are used, and where.
"""
# no imports

# Variables with simple values

HKEY_CLASSES_ROOT = 18446744071562067968

HKEY_CURRENT_CONFIG = 18446744071562067973
HKEY_CURRENT_USER = 18446744071562067969

HKEY_DYN_DATA = 18446744071562067974

HKEY_LOCAL_MACHINE = 18446744071562067970

HKEY_PERFORMANCE_DATA = 18446744071562067972

HKEY_USERS = 18446744071562067971

KEY_ALL_ACCESS = 983103

KEY_CREATE_LINK = 32

KEY_CREATE_SUB_KEY = 4

KEY_ENUMERATE_SUB_KEYS = 8

KEY_EXECUTE = 131097
KEY_NOTIFY = 16

KEY_QUERY_VALUE = 1

KEY_READ = 131097

KEY_SET_VALUE = 2

KEY_WOW64_32KEY = 512
KEY_WOW64_64KEY = 256

KEY_WRITE = 131078

REG_BINARY = 3

REG_CREATED_NEW_KEY = 1

REG_DWORD = 4

REG_DWORD_BIG_ENDIAN = 5

REG_DWORD_LITTLE_ENDIAN = 4

REG_EXPAND_SZ = 2

REG_FULL_RESOURCE_DESCRIPTOR = 9

REG_LEGAL_CHANGE_FILTER = 268435471

REG_LEGAL_OPTION = 31

REG_LINK = 6

REG_MULTI_SZ = 7

REG_NONE = 0

REG_NOTIFY_CHANGE_ATTRIBUTES = 2

REG_NOTIFY_CHANGE_LAST_SET = 4

REG_NOTIFY_CHANGE_NAME = 1
REG_NOTIFY_CHANGE_SECURITY = 8

REG_NO_LAZY_FLUSH = 4

REG_OPENED_EXISTING_KEY = 2

REG_OPTION_BACKUP_RESTORE = 4

REG_OPTION_CREATE_LINK = 2

REG_OPTION_NON_VOLATILE = 0

REG_OPTION_OPEN_LINK = 8

REG_OPTION_RESERVED = 0
REG_OPTION_VOLATILE = 1

REG_QWORD = 11

REG_QWORD_LITTLE_ENDIAN = 11

REG_REFRESH_HIVE = 2

REG_RESOURCE_LIST = 8

REG_RESOURCE_REQUIREMENTS_LIST = 10

REG_SZ = 1

REG_WHOLE_HIVE_VOLATILE = 1

# functions

def CloseKey(*args, **kwargs): # real signature unknown
    """
    Closes a previously opened registry key.
    
      hkey
        A previously opened key.
    
    Note that if the key is not closed using this method, it will be
    closed when the hkey object is destroyed by Python.
    """
    pass

def ConnectRegistry(*args, **kwargs): # real signature unknown
    """
    Establishes a connection to the registry on another computer.
    
      computer_name
        The name of the remote computer, of the form r"\\computername".  If
        None, the local computer is used.
      key
        The predefined key to connect to.
    
    The return value is the handle of the opened key.
    If the function fails, an OSError exception is raised.
    """
    pass

def CreateKey(*args, **kwargs): # real signature unknown
    """
    Creates or opens the specified key.
    
      key
        An already open key, or one of the predefined HKEY_* constants.
      sub_key
        The name of the key this method opens or creates.
    
    If key is one of the predefined keys, sub_key may be None. In that case,
    the handle returned is the same key handle passed in to the function.
    
    If the key already exists, this function opens the existing key.
    
    The return value is the handle of the opened key.
    If the function fails, an OSError exception is raised.
    """
    pass

def CreateKeyEx(*args, **kwargs): # real signature unknown
    """
    Creates or opens the specified key.
    
      key
        An already open key, or one of the predefined HKEY_* constants.
      sub_key
        The name of the key this method opens or creates.
      reserved
        A reserved integer, and must be zero.  Default is zero.
      access
        An integer that specifies an access mask that describes the
        desired security access for the key. Default is KEY_WRITE.
    
    If key is one of the predefined keys, sub_key may be None. In that case,
    the handle returned is the same key handle passed in to the function.
    
    If the key already exists, this function opens the existing key
    
    The return value is the handle of the opened key.
    If the function fails, an OSError exception is raised.
    """
    pass

def DeleteKey(*args, **kwargs): # real signature unknown
    """
    Deletes the specified key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that must be the name of a subkey of the key identified by
        the key parameter. This value must not be None, and the key may not
        have subkeys.
    
    This method can not delete keys with subkeys.
    
    If the function succeeds, the entire key, including all of its values,
    is removed.  If the function fails, an OSError exception is raised.
    """
    pass

def DeleteKeyEx(*args, **kwargs): # real signature unknown
    """
    Deletes the specified key (64-bit OS only).
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that must be the name of a subkey of the key identified by
        the key parameter. This value must not be None, and the key may not
        have subkeys.
      access
        An integer that specifies an access mask that describes the
        desired security access for the key. Default is KEY_WOW64_64KEY.
      reserved
        A reserved integer, and must be zero.  Default is zero.
    
    This method can not delete keys with subkeys.
    
    If the function succeeds, the entire key, including all of its values,
    is removed.  If the function fails, an OSError exception is raised.
    On unsupported Windows versions, NotImplementedError is raised.
    """
    pass

def DeleteValue(*args, **kwargs): # real signature unknown
    """
    Removes a named value from a registry key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      value
        A string that identifies the value to remove.
    """
    pass

def DisableReflectionKey(*args, **kwargs): # real signature unknown
    """
    Disables registry reflection for 32bit processes running on a 64bit OS.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
    
    Will generally raise NotImplemented if executed on a 32bit OS.
    
    If the key is not on the reflection list, the function succeeds but has
    no effect.  Disabling reflection for a key does not affect reflection
    of any subkeys.
    """
    pass

def EnableReflectionKey(*args, **kwargs): # real signature unknown
    """
    Restores registry reflection for the specified disabled key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
    
    Will generally raise NotImplemented if executed on a 32bit OS.
    Restoring reflection for a key does not affect reflection of any
    subkeys.
    """
    pass

def EnumKey(*args, **kwargs): # real signature unknown
    """
    Enumerates subkeys of an open registry key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      index
        An integer that identifies the index of the key to retrieve.
    
    The function retrieves the name of one subkey each time it is called.
    It is typically called repeatedly until an OSError exception is
    raised, indicating no more values are available.
    """
    pass

def EnumValue(*args, **kwargs): # real signature unknown
    """
    Enumerates values of an open registry key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      index
        An integer that identifies the index of the value to retrieve.
    
    The function retrieves the name of one subkey each time it is called.
    It is typically called repeatedly, until an OSError exception
    is raised, indicating no more values.
    
    The result is a tuple of 3 items:
      value_name
        A string that identifies the value.
      value_data
        An object that holds the value data, and whose type depends
        on the underlying registry type.
      data_type
        An integer that identifies the type of the value data.
    """
    pass

def ExpandEnvironmentStrings(*args, **kwargs): # real signature unknown
    """ Expand environment vars. """
    pass

def FlushKey(): # real signature unknown; restored from __doc__
    """
    Writes all the attributes of a key to the registry.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
    
    It is not necessary to call FlushKey to change a key.  Registry changes
    are flushed to disk by the registry using its lazy flusher.  Registry
    changes are also flushed to disk at system shutdown.  Unlike
    CloseKey(), the FlushKey() method returns only when all the data has
    been written to the registry.
    
    An application should only call FlushKey() if it requires absolute
    certainty that registry changes are on disk.  If you don't know whether
    a FlushKey() call is required, it probably isn't.
    """
    pass

def LoadKey(): # real signature unknown; restored from __doc__
    """
    Insert data into the registry from a file.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that identifies the sub-key to load.
      file_name
        The name of the file to load registry data from.  This file must
        have been created with the SaveKey() function.  Under the file
        allocation table (FAT) file system, the filename may not have an
        extension.
    
    Creates a subkey under the specified key and stores registration
    information from a specified file into that subkey.
    
    A call to LoadKey() fails if the calling process does not have the
    SE_RESTORE_PRIVILEGE privilege.
    
    If key is a handle returned by ConnectRegistry(), then the path
    specified in fileName is relative to the remote computer.
    
    The MSDN docs imply key must be in the HKEY_USER or HKEY_LOCAL_MACHINE
    tree.
    """
    pass

def OpenKey(*args, **kwargs): # real signature unknown
    """
    Opens the specified key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that identifies the sub_key to open.
      reserved
        A reserved integer that must be zero.  Default is zero.
      access
        An integer that specifies an access mask that describes the desired
        security access for the key.  Default is KEY_READ.
    
    The result is a new handle to the specified key.
    If the function fails, an OSError exception is raised.
    """
    pass

def OpenKeyEx(*args, **kwargs): # real signature unknown
    """
    Opens the specified key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that identifies the sub_key to open.
      reserved
        A reserved integer that must be zero.  Default is zero.
      access
        An integer that specifies an access mask that describes the desired
        security access for the key.  Default is KEY_READ.
    
    The result is a new handle to the specified key.
    If the function fails, an OSError exception is raised.
    """
    pass

def QueryInfoKey(*args, **kwargs): # real signature unknown
    """
    Returns information about a key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
    
    The result is a tuple of 3 items:
    An integer that identifies the number of sub keys this key has.
    An integer that identifies the number of values this key has.
    An integer that identifies when the key was last modified (if available)
    as 100's of nanoseconds since Jan 1, 1600.
    """
    pass

def QueryReflectionKey(*args, **kwargs): # real signature unknown
    """
    Returns the reflection state for the specified key as a bool.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
    
    Will generally raise NotImplemented if executed on a 32bit OS.
    """
    pass

def QueryValue(*args, **kwargs): # real signature unknown
    """
    Retrieves the unnamed value for a key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that holds the name of the subkey with which the value
        is associated.  If this parameter is None or empty, the function
        retrieves the value set by the SetValue() method for the key
        identified by key.
    
    Values in the registry have name, type, and data components. This method
    retrieves the data for a key's first value that has a NULL name.
    But since the underlying API call doesn't return the type, you'll
    probably be happier using QueryValueEx; this function is just here for
    completeness.
    """
    pass

def QueryValueEx(*args, **kwargs): # real signature unknown
    """
    Retrieves the type and value of a specified sub-key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      name
        A string indicating the value to query.
    
    Behaves mostly like QueryValue(), but also returns the type of the
    specified value name associated with the given open registry key.
    
    The return value is a tuple of the value and the type_id.
    """
    pass

def SaveKey(*args, **kwargs): # real signature unknown
    """
    Saves the specified key, and all its subkeys to the specified file.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      file_name
        The name of the file to save registry data to.  This file cannot
        already exist. If this filename includes an extension, it cannot be
        used on file allocation table (FAT) file systems by the LoadKey(),
        ReplaceKey() or RestoreKey() methods.
    
    If key represents a key on a remote computer, the path described by
    file_name is relative to the remote computer.
    
    The caller of this method must possess the SeBackupPrivilege
    security privilege.  This function passes NULL for security_attributes
    to the API.
    """
    pass

def SetValue(*args, **kwargs): # real signature unknown
    """
    Associates a value with a specified key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      sub_key
        A string that names the subkey with which the value is associated.
      type
        An integer that specifies the type of the data.  Currently this must
        be REG_SZ, meaning only strings are supported.
      value
        A string that specifies the new value.
    
    If the key specified by the sub_key parameter does not exist, the
    SetValue function creates it.
    
    Value lengths are limited by available memory. Long values (more than
    2048 bytes) should be stored as files with the filenames stored in
    the configuration registry to help the registry perform efficiently.
    
    The key identified by the key parameter must have been opened with
    KEY_SET_VALUE access.
    """
    pass

def SetValueEx(*args, **kwargs): # real signature unknown
    """
    Stores data in the value field of an open registry key.
    
      key
        An already open key, or any one of the predefined HKEY_* constants.
      value_name
        A string containing the name of the value to set, or None.
      reserved
        Can be anything - zero is always passed to the API.
      type
        An integer that specifies the type of the data, one of:
        REG_BINARY -- Binary data in any form.
        REG_DWORD -- A 32-bit number.
        REG_DWORD_LITTLE_ENDIAN -- A 32-bit number in little-endian format. Equivalent to REG_DWORD
        REG_DWORD_BIG_ENDIAN -- A 32-bit number in big-endian format.
        REG_EXPAND_SZ -- A null-terminated string that contains unexpanded
                         references to environment variables (for example,
                         %PATH%).
        REG_LINK -- A Unicode symbolic link.
        REG_MULTI_SZ -- A sequence of null-terminated strings, terminated
                        by two null characters.  Note that Python handles
                        this termination automatically.
        REG_NONE -- No defined value type.
        REG_QWORD -- A 64-bit number.
        REG_QWORD_LITTLE_ENDIAN -- A 64-bit number in little-endian format. Equivalent to REG_QWORD.
        REG_RESOURCE_LIST -- A device-driver resource list.
        REG_SZ -- A null-terminated string.
      value
        A string that specifies the new value.
    
    This method can also set additional value and type information for the
    specified key.  The key identified by the key parameter must have been
    opened with KEY_SET_VALUE access.
    
    To open the key, use the CreateKeyEx() or OpenKeyEx() methods.
    
    Value lengths are limited by available memory. Long values (more than
    2048 bytes) should be stored as files with the filenames stored in
    the configuration registry to help the registry perform efficiently.
    """
    pass

# classes

class error(Exception):
    """ Base class for I/O related errors. """
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    def __reduce__(self, *args, **kwargs): # real signature unknown
        pass

    def __str__(self, *args, **kwargs): # real signature unknown
        """ Return str(self). """
        pass

    characters_written = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    errno = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """POSIX exception code"""

    filename = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """exception filename"""

    filename2 = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """second exception filename"""

    strerror = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """exception strerror"""

    winerror = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """Win32 exception code"""



class HKEYType(object):
    """
    PyHKEY Object - A Python object, representing a win32 registry key.
    
    This object wraps a Windows HKEY object, automatically closing it when
    the object is destroyed.  To guarantee cleanup, you can call either
    the Close() method on the PyHKEY, or the CloseKey() method.
    
    All functions which accept a handle object also accept an integer - 
    however, use of the handle object is encouraged.
    
    Functions:
    Close() - Closes the underlying handle.
    Detach() - Returns the integer Win32 handle, detaching it from the object
    
    Properties:
    handle - The integer Win32 handle.
    
    Operations:
    __bool__ - Handles with an open object return true, otherwise false.
    __int__ - Converting a handle to an integer returns the Win32 handle.
    rich comparison - Handle objects are compared using the handle value.
    """
    def Close(self, *args, **kwargs): # real signature unknown
        """
        Closes the underlying Windows handle.
        
        If the handle is already closed, no error is raised.
        """
        pass

    def Detach(self, *args, **kwargs): # real signature unknown
        """
        Detaches the Windows handle from the handle object.
        
        The result is the value of the handle before it is detached.  If the
        handle is already detached, this will return zero.
        
        After calling this function, the handle is effectively invalidated,
        but the handle is not closed.  You would call this function when you
        need the underlying win32 handle to exist beyond the lifetime of the
        handle object.
        """
        pass

    def __abs__(self, *args, **kwargs): # real signature unknown
        """ abs(self) """
        pass

    def __add__(self, *args, **kwargs): # real signature unknown
        """ Return self+value. """
        pass

    def __and__(self, *args, **kwargs): # real signature unknown
        """ Return self&value. """
        pass

    def __bool__(self, *args, **kwargs): # real signature unknown
        """ self != 0 """
        pass

    def __divmod__(self, *args, **kwargs): # real signature unknown
        """ Return divmod(self, value). """
        pass

    def __enter__(self, *args, **kwargs): # real signature unknown
        pass

    def __exit__(self, *args, **kwargs): # real signature unknown
        pass

    def __float__(self, *args, **kwargs): # real signature unknown
        """ float(self) """
        pass

    def __hash__(self, *args, **kwargs): # real signature unknown
        """ Return hash(self). """
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    def __int__(self, *args, **kwargs): # real signature unknown
        """ int(self) """
        pass

    def __invert__(self, *args, **kwargs): # real signature unknown
        """ ~self """
        pass

    def __lshift__(self, *args, **kwargs): # real signature unknown
        """ Return self<<value. """
        pass

    def __mod__(self, *args, **kwargs): # real signature unknown
        """ Return self%value. """
        pass

    def __mul__(self, *args, **kwargs): # real signature unknown
        """ Return self*value. """
        pass

    def __neg__(self, *args, **kwargs): # real signature unknown
        """ -self """
        pass

    def __or__(self, *args, **kwargs): # real signature unknown
        """ Return self|value. """
        pass

    def __pos__(self, *args, **kwargs): # real signature unknown
        """ +self """
        pass

    def __pow__(self, *args, **kwargs): # real signature unknown
        """ Return pow(self, value, mod). """
        pass

    def __radd__(self, *args, **kwargs): # real signature unknown
        """ Return value+self. """
        pass

    def __rand__(self, *args, **kwargs): # real signature unknown
        """ Return value&self. """
        pass

    def __rdivmod__(self, *args, **kwargs): # real signature unknown
        """ Return divmod(value, self). """
        pass

    def __rlshift__(self, *args, **kwargs): # real signature unknown
        """ Return value<<self. """
        pass

    def __rmod__(self, *args, **kwargs): # real signature unknown
        """ Return value%self. """
        pass

    def __rmul__(self, *args, **kwargs): # real signature unknown
        """ Return value*self. """
        pass

    def __ror__(self, *args, **kwargs): # real signature unknown
        """ Return value|self. """
        pass

    def __rpow__(self, *args, **kwargs): # real signature unknown
        """ Return pow(value, self, mod). """
        pass

    def __rrshift__(self, *args, **kwargs): # real signature unknown
        """ Return value>>self. """
        pass

    def __rshift__(self, *args, **kwargs): # real signature unknown
        """ Return self>>value. """
        pass

    def __rsub__(self, *args, **kwargs): # real signature unknown
        """ Return value-self. """
        pass

    def __rxor__(self, *args, **kwargs): # real signature unknown
        """ Return value^self. """
        pass

    def __str__(self, *args, **kwargs): # real signature unknown
        """ Return str(self). """
        pass

    def __sub__(self, *args, **kwargs): # real signature unknown
        """ Return self-value. """
        pass

    def __xor__(self, *args, **kwargs): # real signature unknown
        """ Return self^value. """
        pass

    handle = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default



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

