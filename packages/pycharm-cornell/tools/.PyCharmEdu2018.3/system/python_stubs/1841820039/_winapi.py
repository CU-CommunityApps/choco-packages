# encoding: utf-8
# module _winapi
# from C:\Users\cit-labs\PycharmProjects\untitled\venv\Scripts\_asyncio.pyd
# by generator 1.146
# no doc
# no imports

# Variables with simple values

CREATE_NEW_CONSOLE = 16

CREATE_NEW_PROCESS_GROUP = 512

DUPLICATE_CLOSE_SOURCE = 1

DUPLICATE_SAME_ACCESS = 2

ERROR_ALREADY_EXISTS = 183

ERROR_BROKEN_PIPE = 109

ERROR_IO_PENDING = 997

ERROR_MORE_DATA = 234

ERROR_NETNAME_DELETED = 64

ERROR_NO_DATA = 232

ERROR_NO_SYSTEM_RESOURCES = 1450

ERROR_OPERATION_ABORTED = 995

ERROR_PIPE_BUSY = 231
ERROR_PIPE_CONNECTED = 535

ERROR_SEM_TIMEOUT = 121

FILE_FLAG_FIRST_PIPE_INSTANCE = 524288

FILE_FLAG_OVERLAPPED = 1073741824

FILE_GENERIC_READ = 1179785
FILE_GENERIC_WRITE = 1179926

GENERIC_READ = 2147483648
GENERIC_WRITE = 1073741824

INFINITE = 4294967295

NMPWAIT_WAIT_FOREVER = 4294967295

NULL = 0

OPEN_EXISTING = 3

PIPE_ACCESS_DUPLEX = 3
PIPE_ACCESS_INBOUND = 1

PIPE_READMODE_MESSAGE = 2

PIPE_TYPE_MESSAGE = 4

PIPE_UNLIMITED_INSTANCES = 255

PIPE_WAIT = 0

PROCESS_ALL_ACCESS = 2097151

PROCESS_DUP_HANDLE = 64

STARTF_USESHOWWINDOW = 1
STARTF_USESTDHANDLES = 256

STD_ERROR_HANDLE = 4294967284

STD_INPUT_HANDLE = 4294967286

STD_OUTPUT_HANDLE = 4294967285

STILL_ACTIVE = 259

SW_HIDE = 0

WAIT_ABANDONED_0 = 128

WAIT_OBJECT_0 = 0

WAIT_TIMEOUT = 258

# functions

def CloseHandle(*args, **kwargs): # real signature unknown
    """ Close handle. """
    pass

def ConnectNamedPipe(*args, **kwargs): # real signature unknown
    pass

def CreateFile(*args, **kwargs): # real signature unknown
    pass

def CreateJunction(*args, **kwargs): # real signature unknown
    pass

def CreateNamedPipe(*args, **kwargs): # real signature unknown
    pass

def CreatePipe(*args, **kwargs): # real signature unknown
    """
    Create an anonymous pipe.
    
      pipe_attrs
        Ignored internally, can be None.
    
    Returns a 2-tuple of handles, to the read and write ends of the pipe.
    """
    pass

def CreateProcess(*args, **kwargs): # real signature unknown
    """
    Create a new process and its primary thread.
    
      proc_attrs
        Ignored internally, can be None.
      thread_attrs
        Ignored internally, can be None.
    
    The return value is a tuple of the process handle, thread handle,
    process ID, and thread ID.
    """
    pass

def DuplicateHandle(*args, **kwargs): # real signature unknown
    """
    Return a duplicate handle object.
    
    The duplicate handle refers to the same object as the original
    handle. Therefore, any changes to the object are reflected
    through both handles.
    """
    pass

def ExitProcess(*args, **kwargs): # real signature unknown
    pass

def GetCurrentProcess(*args, **kwargs): # real signature unknown
    """ Return a handle object for the current process. """
    pass

def GetExitCodeProcess(*args, **kwargs): # real signature unknown
    """ Return the termination status of the specified process. """
    pass

def GetLastError(*args, **kwargs): # real signature unknown
    pass

def GetModuleFileName(*args, **kwargs): # real signature unknown
    """
    Return the fully-qualified path for the file that contains module.
    
    The module must have been loaded by the current process.
    
    The module parameter should be a handle to the loaded module
    whose path is being requested. If this parameter is 0,
    GetModuleFileName retrieves the path of the executable file
    of the current process.
    """
    pass

def GetStdHandle(*args, **kwargs): # real signature unknown
    """
    Return a handle to the specified standard device.
    
      std_handle
        One of STD_INPUT_HANDLE, STD_OUTPUT_HANDLE, or STD_ERROR_HANDLE.
    
    The integer associated with the handle object is returned.
    """
    pass

def GetVersion(*args, **kwargs): # real signature unknown
    """ Return the version number of the current operating system. """
    pass

def OpenProcess(*args, **kwargs): # real signature unknown
    pass

def PeekNamedPipe(*args, **kwargs): # real signature unknown
    pass

def ReadFile(*args, **kwargs): # real signature unknown
    pass

def SetNamedPipeHandleState(*args, **kwargs): # real signature unknown
    pass

def TerminateProcess(*args, **kwargs): # real signature unknown
    """ Terminate the specified process and all of its threads. """
    pass

def WaitForMultipleObjects(*args, **kwargs): # real signature unknown
    pass

def WaitForSingleObject(*args, **kwargs): # real signature unknown
    """
    Wait for a single object.
    
    Wait until the specified object is in the signaled state or
    the time-out interval elapses. The timeout value is specified
    in milliseconds.
    """
    pass

def WaitNamedPipe(*args, **kwargs): # real signature unknown
    pass

def WriteFile(*args, **kwargs): # real signature unknown
    pass

# classes

class Overlapped(object):
    """ OVERLAPPED structure wrapper """
    def cancel(self, *args, **kwargs): # real signature unknown
        pass

    def getbuffer(self, *args, **kwargs): # real signature unknown
        pass

    def GetOverlappedResult(self, *args, **kwargs): # real signature unknown
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    event = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """overlapped event handle"""



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

