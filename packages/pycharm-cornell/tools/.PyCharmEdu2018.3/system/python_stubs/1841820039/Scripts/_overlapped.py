# encoding: utf-8
# module Scripts._overlapped
# from C:\Users\cit-labs\PycharmProjects\untitled\venv\Scripts\_overlapped.pyd
# by generator 1.146
# no doc

# imports
from _overlapped import Overlapped


# Variables with simple values

ERROR_IO_PENDING = 997

ERROR_NETNAME_DELETED = 64

ERROR_PIPE_BUSY = 231

ERROR_SEM_TIMEOUT = 121

INFINITE = 4294967295

INVALID_HANDLE_VALUE = 18446744073709551615

NULL = 0

SO_UPDATE_ACCEPT_CONTEXT = 28683

SO_UPDATE_CONNECT_CONTEXT = 28688

TF_REUSE_SOCKET = 2

# functions

def BindLocal(handle, family): # real signature unknown; restored from __doc__
    """
    BindLocal(handle, family) -> None
    
    Bind a socket handle to an arbitrary local port.
    family should AF_INET or AF_INET6.
    """
    pass

def ConnectPipe(addr): # real signature unknown; restored from __doc__
    """
    ConnectPipe(addr) -> pipe_handle
    
    Connect to the pipe for asynchronous I/O (overlapped).
    """
    pass

def CreateEvent(EventAttributes, ManualReset, InitialState, Name): # real signature unknown; restored from __doc__
    """
    CreateEvent(EventAttributes, ManualReset, InitialState, Name) -> Handle
    
    Create an event.  EventAttributes must be None.
    """
    pass

def CreateIoCompletionPort(handle, port, key, concurrency): # real signature unknown; restored from __doc__
    """
    CreateIoCompletionPort(handle, port, key, concurrency) -> port
    
    Create a completion port or register a handle with a port.
    """
    pass

def FormatMessage(error_code): # real signature unknown; restored from __doc__
    """
    FormatMessage(error_code) -> error_message
    
    Return error message for an error code.
    """
    pass

def GetQueuedCompletionStatus(port, msecs): # real signature unknown; restored from __doc__
    """
    GetQueuedCompletionStatus(port, msecs) -> (err, bytes, key, address)
    
    Get a message from completion port.  Wait for up to msecs milliseconds.
    """
    pass

def PostQueuedCompletionStatus(port, bytes, key, address): # real signature unknown; restored from __doc__
    """
    PostQueuedCompletionStatus(port, bytes, key, address) -> None
    
    Post a message to completion port.
    """
    pass

def RegisterWaitWithQueue(Object, CompletionPort, Overlapped, Timeout): # real signature unknown; restored from __doc__
    """
    RegisterWaitWithQueue(Object, CompletionPort, Overlapped, Timeout)
        -> WaitHandle
    
    Register wait for Object; when complete CompletionPort is notified.
    """
    pass

def ResetEvent(Handle): # real signature unknown; restored from __doc__
    """
    ResetEvent(Handle) -> None
    
    Reset event.
    """
    pass

def SetEvent(Handle): # real signature unknown; restored from __doc__
    """
    SetEvent(Handle) -> None
    
    Set event.
    """
    pass

def UnregisterWait(WaitHandle): # real signature unknown; restored from __doc__
    """
    UnregisterWait(WaitHandle) -> None
    
    Unregister wait handle.
    """
    pass

def UnregisterWaitEx(WaitHandle, Event): # real signature unknown; restored from __doc__
    """
    UnregisterWaitEx(WaitHandle, Event) -> None
    
    Unregister wait handle.
    """
    pass

# no classes
# variables with complex values

__loader__ = None # (!) real value is ''

__spec__ = None # (!) real value is ''

