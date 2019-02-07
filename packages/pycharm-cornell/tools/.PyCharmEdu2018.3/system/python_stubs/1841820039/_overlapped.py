# encoding: utf-8
# module _overlapped
# from (pre-generated)
# by generator 1.146
# no doc
# no imports

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

# classes

class Overlapped(object):
    """ OVERLAPPED structure wrapper """
    def AcceptEx(self, listen_handle, accept_handle): # real signature unknown; restored from __doc__
        """
        AcceptEx(listen_handle, accept_handle) -> Overlapped[address_as_bytes]
        
        Start overlapped wait for client to connect
        """
        return Overlapped

    def cancel(self): # real signature unknown; restored from __doc__
        """
        cancel() -> None
        
        Cancel overlapped operation
        """
        pass

    def ConnectEx(self, client_handle, address_as_bytes): # real signature unknown; restored from __doc__
        """
        ConnectEx(client_handle, address_as_bytes) -> Overlapped[None]
        
        Start overlapped connect.  client_handle should be unbound.
        """
        return Overlapped

    def ConnectNamedPipe(self, handle): # real signature unknown; restored from __doc__
        """
        ConnectNamedPipe(handle) -> Overlapped[None]
        
        Start overlapped wait for a client to connect.
        """
        return Overlapped

    def DisconnectEx(self, handle, flags): # real signature unknown; restored from __doc__
        """
        DisconnectEx(handle, flags) -> Overlapped[None]
        
        Start overlapped connect.  client_handle should be unbound.
        """
        return Overlapped

    def getresult(self, wait=False): # real signature unknown; restored from __doc__
        """
        getresult(wait=False) -> result
        
        Retrieve result of operation.  If wait is true then it blocks
        until the operation is finished.  If wait is false and the
        operation is still pending then an error is raised.
        """
        pass

    def ReadFile(self, handle, size): # real signature unknown; restored from __doc__
        """
        ReadFile(handle, size) -> Overlapped[message]
        
        Start overlapped read
        """
        return Overlapped

    def WriteFile(self, handle, buf): # real signature unknown; restored from __doc__
        """
        WriteFile(handle, buf) -> Overlapped[bytes_transferred]
        
        Start overlapped write
        """
        return Overlapped

    def WSARecv(self, *args, **kwargs): # real signature unknown
        """
        RecvFile(handle, size, flags) -> Overlapped[message]
        
        Start overlapped receive
        """
        pass

    def WSASend(self, handle, buf, flags): # real signature unknown; restored from __doc__
        """
        WSASend(handle, buf, flags) -> Overlapped[bytes_transferred]
        
        Start overlapped send
        """
        return Overlapped

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    address = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """Address of overlapped structure"""

    error = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """Error from last operation"""

    event = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """Overlapped event handle"""

    pending = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """Whether the operation is pending"""



# variables with complex values

__loader__ = None # (!) real value is ''

__spec__ = None # (!) real value is ''

