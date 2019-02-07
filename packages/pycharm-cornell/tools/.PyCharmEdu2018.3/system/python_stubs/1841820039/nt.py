# encoding: utf-8
# module nt
# from (built-in)
# by generator 1.146
"""
This module provides access to operating system functionality that is
standardized by the C Standard and the POSIX standard (a thinly
disguised Unix interface).  Refer to the library manual and
corresponding Unix manual entries for more information on calls.
"""
# no imports

# Variables with simple values

F_OK = 0

O_APPEND = 8
O_BINARY = 32768
O_CREAT = 256
O_EXCL = 1024
O_NOINHERIT = 128
O_RANDOM = 16
O_RDONLY = 0
O_RDWR = 2
O_SEQUENTIAL = 32

O_SHORT_LIVED = 4096

O_TEMPORARY = 64
O_TEXT = 16384
O_TRUNC = 512
O_WRONLY = 1

P_DETACH = 4
P_NOWAIT = 1
P_NOWAITO = 3
P_OVERLAY = 2
P_WAIT = 0

R_OK = 4

TMP_MAX = 2147483647

W_OK = 2

X_OK = 1

# functions

def abort(*args, **kwargs): # real signature unknown
    """
    Abort the interpreter immediately.
    
    This function 'dumps core' or otherwise fails in the hardest way possible
    on the hosting operating system.  This function never returns.
    """
    pass

def access(*args, **kwargs): # real signature unknown
    """
    Use the real uid/gid to test for access to a path.
    
      path
        Path to be tested; can be string or bytes
      mode
        Operating-system mode bitfield.  Can be F_OK to test existence,
        or the inclusive-OR of R_OK, W_OK, and X_OK.
      dir_fd
        If not None, it should be a file descriptor open to a directory,
        and path should be relative; path will then be relative to that
        directory.
      effective_ids
        If True, access will use the effective uid/gid instead of
        the real uid/gid.
      follow_symlinks
        If False, and the last element of the path is a symbolic link,
        access will examine the symbolic link itself instead of the file
        the link points to.
    
    dir_fd, effective_ids, and follow_symlinks may not be implemented
      on your platform.  If they are unavailable, using them will raise a
      NotImplementedError.
    
    Note that most operations will use the effective uid/gid, therefore this
      routine can be used in a suid/sgid environment to test if the invoking user
      has the specified access to the path.
    """
    pass

def chdir(*args, **kwargs): # real signature unknown
    """
    Change the current working directory to the specified path.
    
    path may always be specified as a string.
    On some platforms, path may also be specified as an open file descriptor.
      If this functionality is unavailable, using it raises an exception.
    """
    pass

def chmod(*args, **kwargs): # real signature unknown
    """
    Change the access permissions of a file.
    
      path
        Path to be modified.  May always be specified as a str or bytes.
        On some platforms, path may also be specified as an open file descriptor.
        If this functionality is unavailable, using it raises an exception.
      mode
        Operating-system mode bitfield.
      dir_fd
        If not None, it should be a file descriptor open to a directory,
        and path should be relative; path will then be relative to that
        directory.
      follow_symlinks
        If False, and the last element of the path is a symbolic link,
        chmod will modify the symbolic link itself instead of the file
        the link points to.
    
    It is an error to use dir_fd or follow_symlinks when specifying path as
      an open file descriptor.
    dir_fd and follow_symlinks may not be implemented on your platform.
      If they are unavailable, using them will raise a NotImplementedError.
    """
    pass

def close(*args, **kwargs): # real signature unknown
    """ Close a file descriptor. """
    pass

def closerange(*args, **kwargs): # real signature unknown
    """ Closes all file descriptors in [fd_low, fd_high), ignoring errors. """
    pass

def cpu_count(*args, **kwargs): # real signature unknown
    """
    Return the number of CPUs in the system; return None if indeterminable.
    
    This number is not equivalent to the number of CPUs the current process can
    use.  The number of usable CPUs can be obtained with
    ``len(os.sched_getaffinity(0))``
    """
    pass

def device_encoding(*args, **kwargs): # real signature unknown
    """
    Return a string describing the encoding of a terminal's file descriptor.
    
    The file descriptor must be attached to a terminal.
    If the device is not a terminal, return None.
    """
    pass

def dup(*args, **kwargs): # real signature unknown
    """ Return a duplicate of a file descriptor. """
    pass

def dup2(*args, **kwargs): # real signature unknown
    """ Duplicate file descriptor. """
    pass

def execv(*args, **kwargs): # real signature unknown
    """
    Execute an executable path with arguments, replacing current process.
    
      path
        Path of executable file.
      argv
        Tuple or list of strings.
    """
    pass

def execve(*args, **kwargs): # real signature unknown
    """
    Execute an executable path with arguments, replacing current process.
    
      path
        Path of executable file.
      argv
        Tuple or list of strings.
      env
        Dictionary of strings mapping to strings.
    """
    pass

def fspath(*args, **kwargs): # real signature unknown
    """
    Return the file system path representation of the object.
    
    If the object is str or bytes, then allow it to pass through as-is. If the
    object defines __fspath__(), then return the result of that method. All other
    types raise a TypeError.
    """
    pass

def fstat(*args, **kwargs): # real signature unknown
    """
    Perform a stat system call on the given file descriptor.
    
    Like stat(), but for an open file descriptor.
    Equivalent to os.stat(fd).
    """
    pass

def fsync(*args, **kwargs): # real signature unknown
    """ Force write of fd to disk. """
    pass

def ftruncate(*args, **kwargs): # real signature unknown
    """ Truncate a file, specified by file descriptor, to a specific length. """
    pass

def getcwd(*args, **kwargs): # real signature unknown
    """ Return a unicode string representing the current working directory. """
    pass

def getcwdb(*args, **kwargs): # real signature unknown
    """ Return a bytes string representing the current working directory. """
    pass

def getlogin(*args, **kwargs): # real signature unknown
    """ Return the actual login name. """
    pass

def getpid(*args, **kwargs): # real signature unknown
    """ Return the current process id. """
    pass

def getppid(*args, **kwargs): # real signature unknown
    """
    Return the parent's process id.
    
    If the parent process has already exited, Windows machines will still
    return its id; others systems will return the id of the 'init' process (1).
    """
    pass

def get_handle_inheritable(*args, **kwargs): # real signature unknown
    """ Get the close-on-exe flag of the specified file descriptor. """
    pass

def get_inheritable(*args, **kwargs): # real signature unknown
    """ Get the close-on-exe flag of the specified file descriptor. """
    pass

def get_terminal_size(*args, **kwargs): # real signature unknown
    """
    Return the size of the terminal window as (columns, lines).
    
    The optional argument fd (default standard output) specifies
    which file descriptor should be queried.
    
    If the file descriptor is not connected to a terminal, an OSError
    is thrown.
    
    This function will only be defined if an implementation is
    available for this system.
    
    shutil.get_terminal_size is the high-level function which should 
    normally be used, os.get_terminal_size is the low-level implementation.
    """
    pass

def isatty(*args, **kwargs): # real signature unknown
    """
    Return True if the fd is connected to a terminal.
    
    Return True if the file descriptor is an open file descriptor
    connected to the slave end of a terminal.
    """
    pass

def kill(*args, **kwargs): # real signature unknown
    """ Kill a process with a signal. """
    pass

def link(*args, **kwargs): # real signature unknown
    """
    Create a hard link to a file.
    
    If either src_dir_fd or dst_dir_fd is not None, it should be a file
      descriptor open to a directory, and the respective path string (src or dst)
      should be relative; the path will then be relative to that directory.
    If follow_symlinks is False, and the last element of src is a symbolic
      link, link will create a link to the symbolic link itself instead of the
      file the link points to.
    src_dir_fd, dst_dir_fd, and follow_symlinks may not be implemented on your
      platform.  If they are unavailable, using them will raise a
      NotImplementedError.
    """
    pass

def listdir(*args, **kwargs): # real signature unknown
    """
    Return a list containing the names of the files in the directory.
    
    path can be specified as either str or bytes.  If path is bytes,
      the filenames returned will also be bytes; in all other circumstances
      the filenames returned will be str.
    If path is None, uses the path='.'.
    On some platforms, path may also be specified as an open file descriptor;\
      the file descriptor must refer to a directory.
      If this functionality is unavailable, using it raises NotImplementedError.
    
    The list is in arbitrary order.  It does not include the special
    entries '.' and '..' even if they are present in the directory.
    """
    pass

def lseek(*args, **kwargs): # real signature unknown
    """
    Set the position of a file descriptor.  Return the new position.
    
    Return the new cursor position in number of bytes
    relative to the beginning of the file.
    """
    pass

def lstat(*args, **kwargs): # real signature unknown
    """
    Perform a stat system call on the given path, without following symbolic links.
    
    Like stat(), but do not follow symbolic links.
    Equivalent to stat(path, follow_symlinks=False).
    """
    pass

def mkdir(*args, **kwargs): # real signature unknown
    """
    Create a directory.
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    
    The mode argument is ignored on Windows.
    """
    pass

def open(*args, **kwargs): # real signature unknown
    """
    Open a file for low level IO.  Returns a file descriptor (integer).
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    """
    pass

def pipe(*args, **kwargs): # real signature unknown
    """
    Create a pipe.
    
    Returns a tuple of two file descriptors:
      (read_fd, write_fd)
    """
    pass

def putenv(*args, **kwargs): # real signature unknown
    """ Change or add an environment variable. """
    pass

def read(*args, **kwargs): # real signature unknown
    """ Read from a file descriptor.  Returns a bytes object. """
    pass

def readlink(path, *args, **kwargs): # real signature unknown; NOTE: unreliably restored from __doc__ 
    """
    readlink(path, *, dir_fd=None) -> path
    
    Return a string representing the path to which the symbolic link points.
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    """
    pass

def remove(*args, **kwargs): # real signature unknown
    """
    Remove a file (same as unlink()).
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    """
    pass

def rename(*args, **kwargs): # real signature unknown
    """
    Rename a file or directory.
    
    If either src_dir_fd or dst_dir_fd is not None, it should be a file
      descriptor open to a directory, and the respective path string (src or dst)
      should be relative; the path will then be relative to that directory.
    src_dir_fd and dst_dir_fd, may not be implemented on your platform.
      If they are unavailable, using them will raise a NotImplementedError.
    """
    pass

def replace(*args, **kwargs): # real signature unknown
    """
    Rename a file or directory, overwriting the destination.
    
    If either src_dir_fd or dst_dir_fd is not None, it should be a file
      descriptor open to a directory, and the respective path string (src or dst)
      should be relative; the path will then be relative to that directory.
    src_dir_fd and dst_dir_fd, may not be implemented on your platform.
      If they are unavailable, using them will raise a NotImplementedError."
    """
    pass

def rmdir(*args, **kwargs): # real signature unknown
    """
    Remove a directory.
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    """
    pass

def scandir(path='.'): # real signature unknown; restored from __doc__
    """ scandir(path='.') -> iterator of DirEntry objects for given path """
    pass

def set_handle_inheritable(*args, **kwargs): # real signature unknown
    """ Set the inheritable flag of the specified handle. """
    pass

def set_inheritable(*args, **kwargs): # real signature unknown
    """ Set the inheritable flag of the specified file descriptor. """
    pass

def spawnv(*args, **kwargs): # real signature unknown
    """
    Execute the program specified by path in a new process.
    
      mode
        Mode of process creation.
      path
        Path of executable file.
      argv
        Tuple or list of strings.
    """
    pass

def spawnve(*args, **kwargs): # real signature unknown
    """
    Execute the program specified by path in a new process.
    
      mode
        Mode of process creation.
      path
        Path of executable file.
      argv
        Tuple or list of strings.
      env
        Dictionary of strings mapping to strings.
    """
    pass

def startfile(filepath, operation=None): # real signature unknown; restored from __doc__
    """
    startfile(filepath [, operation])
    
    Start a file with its associated application.
    
    When "operation" is not specified or "open", this acts like
    double-clicking the file in Explorer, or giving the file name as an
    argument to the DOS "start" command: the file is opened with whatever
    application (if any) its extension is associated.
    When another "operation" is given, it specifies what should be done with
    the file.  A typical operation is "print".
    
    startfile returns as soon as the associated application is launched.
    There is no option to wait for the application to close, and no way
    to retrieve the application's exit status.
    
    The filepath is relative to the current directory.  If you want to use
    an absolute path, make sure the first character is not a slash ("/");
    the underlying Win32 ShellExecute function doesn't work if it is.
    """
    pass

def stat(*args, **kwargs): # real signature unknown
    """
    Perform a stat system call on the given path.
    
      path
        Path to be examined; can be string, bytes, path-like object or
        open-file-descriptor int.
      dir_fd
        If not None, it should be a file descriptor open to a directory,
        and path should be a relative string; path will then be relative to
        that directory.
      follow_symlinks
        If False, and the last element of the path is a symbolic link,
        stat will examine the symbolic link itself instead of the file
        the link points to.
    
    dir_fd and follow_symlinks may not be implemented
      on your platform.  If they are unavailable, using them will raise a
      NotImplementedError.
    
    It's an error to use dir_fd or follow_symlinks when specifying path as
      an open file descriptor.
    """
    pass

def stat_float_times(newval=None): # real signature unknown; restored from __doc__
    """
    stat_float_times([newval]) -> oldval
    
    Determine whether os.[lf]stat represents time stamps as float objects.
    
    If value is True, future calls to stat() return floats; if it is False,
    future calls return ints.
    If value is omitted, return the current setting.
    """
    pass

def strerror(*args, **kwargs): # real signature unknown
    """ Translate an error code to a message string. """
    pass

def symlink(*args, **kwargs): # real signature unknown
    """
    Create a symbolic link pointing to src named dst.
    
    target_is_directory is required on Windows if the target is to be
      interpreted as a directory.  (On Windows, symlink requires
      Windows 6.0 or greater, and raises a NotImplementedError otherwise.)
      target_is_directory is ignored on non-Windows platforms.
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    """
    pass

def system(*args, **kwargs): # real signature unknown
    """ Execute the command in a subshell. """
    pass

def times(*args, **kwargs): # real signature unknown
    """
    Return a collection containing process timing information.
    
    The object returned behaves like a named tuple with these fields:
      (utime, stime, cutime, cstime, elapsed_time)
    All fields are floating point numbers.
    """
    pass

def truncate(*args, **kwargs): # real signature unknown
    """
    Truncate a file, specified by path, to a specific length.
    
    On some platforms, path may also be specified as an open file descriptor.
      If this functionality is unavailable, using it raises an exception.
    """
    pass

def umask(*args, **kwargs): # real signature unknown
    """ Set the current numeric umask and return the previous umask. """
    pass

def unlink(*args, **kwargs): # real signature unknown
    """
    Remove a file (same as remove()).
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    dir_fd may not be implemented on your platform.
      If it is unavailable, using it will raise a NotImplementedError.
    """
    pass

def urandom(*args, **kwargs): # real signature unknown
    """ Return a bytes object containing random bytes suitable for cryptographic use. """
    pass

def utime(*args, **kwargs): # real signature unknown
    """
    Set the access and modified time of path.
    
    path may always be specified as a string.
    On some platforms, path may also be specified as an open file descriptor.
      If this functionality is unavailable, using it raises an exception.
    
    If times is not None, it must be a tuple (atime, mtime);
        atime and mtime should be expressed as float seconds since the epoch.
    If ns is specified, it must be a tuple (atime_ns, mtime_ns);
        atime_ns and mtime_ns should be expressed as integer nanoseconds
        since the epoch.
    If times is None and ns is unspecified, utime uses the current time.
    Specifying tuples for both times and ns is an error.
    
    If dir_fd is not None, it should be a file descriptor open to a directory,
      and path should be relative; path will then be relative to that directory.
    If follow_symlinks is False, and the last element of the path is a symbolic
      link, utime will modify the symbolic link itself instead of the file the
      link points to.
    It is an error to use dir_fd or follow_symlinks when specifying path
      as an open file descriptor.
    dir_fd and follow_symlinks may not be available on your platform.
      If they are unavailable, using them will raise a NotImplementedError.
    """
    pass

def waitpid(*args, **kwargs): # real signature unknown
    """
    Wait for completion of a given process.
    
    Returns a tuple of information regarding the process:
        (pid, status << 8)
    
    The options argument is ignored on Windows.
    """
    pass

def write(*args, **kwargs): # real signature unknown
    """ Write a bytes object to a file descriptor. """
    pass

def _exit(*args, **kwargs): # real signature unknown
    """ Exit to the system with specified status, without normal exit processing. """
    pass

def _getdiskusage(*args, **kwargs): # real signature unknown
    """ Return disk usage statistics about the given path as a (total, free) tuple. """
    pass

def _getfinalpathname(*args, **kwargs): # real signature unknown
    """ A helper function for samepath on windows. """
    pass

def _getfullpathname(*args, **kwargs): # real signature unknown
    pass

def _getvolumepathname(*args, **kwargs): # real signature unknown
    """ A helper function for ismount on Win32. """
    pass

def _isdir(*args, **kwargs): # real signature unknown
    """ Return true if the pathname refers to an existing directory. """
    pass

# classes

class DirEntry(object):
    # no doc
    def inode(self, *args, **kwargs): # real signature unknown
        """ return inode of the entry; cached per entry """
        pass

    def is_dir(self, *args, **kwargs): # real signature unknown
        """ return True if the entry is a directory; cached per entry """
        pass

    def is_file(self, *args, **kwargs): # real signature unknown
        """ return True if the entry is a file; cached per entry """
        pass

    def is_symlink(self, *args, **kwargs): # real signature unknown
        """ return True if the entry is a symbolic link; cached per entry """
        pass

    def stat(self, *args, **kwargs): # real signature unknown
        """ return stat_result object for the entry; cached per entry """
        pass

    def __fspath__(self, *args, **kwargs): # real signature unknown
        """ returns the path for the entry """
        pass

    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    def __repr__(self, *args, **kwargs): # real signature unknown
        """ Return repr(self). """
        pass

    name = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """the entry's base filename, relative to scandir() "path" argument"""

    path = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """the entry's full path name; equivalent to os.path.join(scandir_path, entry.name)"""



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



class statvfs_result(tuple):
    """
    statvfs_result: Result from statvfs or fstatvfs.
    
    This object may be accessed either as a tuple of
      (bsize, frsize, blocks, bfree, bavail, files, ffree, favail, flag, namemax),
    or via the attributes f_bsize, f_frsize, f_blocks, f_bfree, and so on.
    
    See os.statvfs for more information.
    """
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    def __reduce__(self, *args, **kwargs): # real signature unknown
        pass

    def __repr__(self, *args, **kwargs): # real signature unknown
        """ Return repr(self). """
        pass

    f_bavail = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_bfree = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_blocks = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_bsize = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_favail = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_ffree = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_files = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_flag = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_frsize = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default

    f_namemax = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default


    n_fields = 10
    n_sequence_fields = 10
    n_unnamed_fields = 0


class stat_result(tuple):
    """
    stat_result: Result from stat, fstat, or lstat.
    
    This object may be accessed either as a tuple of
      (mode, ino, dev, nlink, uid, gid, size, atime, mtime, ctime)
    or via the attributes st_mode, st_ino, st_dev, st_nlink, st_uid, and so on.
    
    Posix/windows: If your platform supports st_blksize, st_blocks, st_rdev,
    or st_flags, they are available as attributes only.
    
    See os.stat for more information.
    """
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    def __reduce__(self, *args, **kwargs): # real signature unknown
        pass

    def __repr__(self, *args, **kwargs): # real signature unknown
        """ Return repr(self). """
        pass

    st_atime = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """time of last access"""

    st_atime_ns = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """time of last access in nanoseconds"""

    st_ctime = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """time of last change"""

    st_ctime_ns = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """time of last change in nanoseconds"""

    st_dev = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """device"""

    st_file_attributes = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """Windows file attribute bits"""

    st_gid = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """group ID of owner"""

    st_ino = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """inode"""

    st_mode = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """protection bits"""

    st_mtime = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """time of last modification"""

    st_mtime_ns = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """time of last modification in nanoseconds"""

    st_nlink = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """number of hard links"""

    st_size = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """total size, in bytes"""

    st_uid = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """user ID of owner"""


    n_fields = 17
    n_sequence_fields = 10
    n_unnamed_fields = 3


class terminal_size(tuple):
    """ A tuple of (columns, lines) for holding terminal window size """
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    def __reduce__(self, *args, **kwargs): # real signature unknown
        pass

    def __repr__(self, *args, **kwargs): # real signature unknown
        """ Return repr(self). """
        pass

    columns = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """width of the terminal window in characters"""

    lines = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """height of the terminal window in characters"""


    n_fields = 2
    n_sequence_fields = 2
    n_unnamed_fields = 0


class times_result(tuple):
    """
    times_result: Result from os.times().
    
    This object may be accessed either as a tuple of
      (user, system, children_user, children_system, elapsed),
    or via the attributes user, system, children_user, children_system,
    and elapsed.
    
    See os.times for more information.
    """
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    def __reduce__(self, *args, **kwargs): # real signature unknown
        pass

    def __repr__(self, *args, **kwargs): # real signature unknown
        """ Return repr(self). """
        pass

    children_system = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """system time of children"""

    children_user = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """user time of children"""

    elapsed = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """elapsed time since an arbitrary point in the past"""

    system = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """system time"""

    user = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """user time"""


    n_fields = 5
    n_sequence_fields = 5
    n_unnamed_fields = 0


class uname_result(tuple):
    """
    uname_result: Result from os.uname().
    
    This object may be accessed either as a tuple of
      (sysname, nodename, release, version, machine),
    or via the attributes sysname, nodename, release, version, and machine.
    
    See os.uname for more information.
    """
    def __init__(self, *args, **kwargs): # real signature unknown
        pass

    @staticmethod # known case of __new__
    def __new__(*args, **kwargs): # real signature unknown
        """ Create and return a new object.  See help(type) for accurate signature. """
        pass

    def __reduce__(self, *args, **kwargs): # real signature unknown
        pass

    def __repr__(self, *args, **kwargs): # real signature unknown
        """ Return repr(self). """
        pass

    machine = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """hardware identifier"""

    nodename = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """name of machine on network (implementation-defined)"""

    release = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """operating system release"""

    sysname = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """operating system name"""

    version = property(lambda self: object(), lambda self, v: None, lambda self: None)  # default
    """operating system version"""


    n_fields = 5
    n_sequence_fields = 5
    n_unnamed_fields = 0


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

environ = {
    'ALLUSERSPROFILE': 'C:\\ProgramData',
    'APPDATA': 'C:\\Users\\builduser\\AppData\\Roaming',
    'BUILD_NUMBER': '159',
    'BUILD_VCS_NUMBER_ijplatform_GitHostingIdeaCidr': '5c888bb03e3db7b29d08822689559bfd213eb16f',
    'BUILD_VCS_NUMBER_ijplatform_GitHostingIdeaCommunity': '19f53d619cbcdb31b98118abdbe2c3800592e0d6',
    'BUILD_VCS_NUMBER_ijplatform_GitHostingIdeaCommunityAndroid': '6fe40b4078f5d74e510936bfb16aff60a1a28193',
    'BUILD_VCS_NUMBER_ijplatform_GitHostingIdeaCommunityAndroidTools': 'e841aa025aa62a4250040ca2a538daabbff54cf5',
    'BUILD_VCS_NUMBER_ijplatform_GitHostingIdeaContrib': '2937e776a64c71f60cff984f683dc26efb13a7a0',
    'BUILD_VCS_NUMBER_ijplatform_GitHostingIdeaUltimate': 'a8f86c549dcf753d0f86d6409815b936e3e36c43',
    'COMPUTERNAME': 'WIN-UCLSU57F2BI',
    'ChocolateyInstall': 'C:\\ProgramData\\chocolatey',
    'ComSpec': 'C:\\Windows\\system32\\cmd.exe',
    'CommonProgramFiles': 'C:\\Program Files\\Common Files',
    'CommonProgramFiles(x86)': 'C:\\Program Files (x86)\\Common Files',
    'CommonProgramW6432': 'C:\\Program Files\\Common Files',
    'DOCKER_HOST': 'tcp://127.0.0.1:2375',
    'DOTNET_CLI_TELEMETRY_OPTOUT': 'true',
    'DOTNET_SKIP_FIRST_TIME_EXPERIENCE': 'true',
    'FSHARPINSTALLDIR': 'C:\\Program Files (x86)\\Microsoft SDKs\\F#\\4.1\\Framework\\v4.0\\',
    'IDEA_HOME': 'C:\\BuildAgent\\work\\db4ab5c5d1163f8d',
    'JAVA_HOME': 'C:\\tools\\jdk8.171-i586',
    'JDK_14': 'C:\\tools\\jdk1.4.2.19-i586',
    'JDK_15': 'C:\\tools\\jdk5.0.22-i586',
    'JDK_16': 'C:\\tools\\jdk6.45-i586',
    'JDK_16_x64': 'C:\\tools\\jdk6.45-x64',
    'JDK_17': 'C:\\tools\\jdk7.79-i586',
    'JDK_17_x64': 'C:\\tools\\jdk7.79-x64',
    'JDK_18': 'C:\\tools\\jdk8.171-i586',
    'JDK_18_x64': 'C:\\tools\\jdk8.171-x64',
    'JDK_19': 'C:\\tools\\jdk9.0.4-x64',
    'JDK_19_x64': 'C:\\tools\\jdk9.0.4-x64',
    'JDK_9': 'C:\\tools\\jdk9.0.4-x64',
    'JDK_9_x64': 'C:\\tools\\jdk9.0.4-x64',
    'JDK_HOME': 'C:\\tools\\jdk9.0.4-x64',
    'JRE_HOME': 'C:\\tools\\jdk9.0.4-x64',
    'LOCALAPPDATA': 'C:\\Users\\builduser\\AppData\\Local',
    'M2_HOME': 'C:\\BuildAgent/plugins/maven-2.0.8',
    'NO_FS_ROOTS_ACCESS_CHECK': '1',
    'NUGET_XMLDOC_MODE': 'skip',
    'NUMBER_OF_PROCESSORS': '2',
    'OS': 'Windows_NT',
    'PATHEXT': '.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.RB;.RBW',
    'PROCESSOR_ARCHITECTURE': 'AMD64',
    'PROCESSOR_IDENTIFIER': 'Intel64 Family 6 Model 79 Stepping 1, GenuineIntel',
    'PROCESSOR_LEVEL': '6',
    'PROCESSOR_REVISION': '4f01',
    'PSModulePath': '%ProgramFiles%\\WindowsPowerShell\\Modules;C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules',
    'PUBLIC': 'C:\\Users\\Public',
    'PYCHARM_PYTHONS': 'C:\\BuildAgent\\system\\.persistent_cache/pycharm/pythons4skeletons',
    'PYCHARM_PYTHON_VIRTUAL_ENVS': 'C:\\BuildAgent\\system\\.persistent_cache/pycharm/envs',
    'PYCHARM_ZIP_REPOSITORY': 'http://repo.labs.intellij.net/pycharm/python-archives-windows/',
    'PYTHONDONTWRITEBYTECODE': '1',
    'Path': 'C:\\Tools\\ruby25\\bin;C:\\Tools\\ruby24\\bin;C:\\Windows\\system32;C:\\Windows;C:\\Windows\\System32\\Wbem;C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\;C:\\Program Files\\Git\\cmd;C:\\tools\\Subversion\\bin;C:\\tools\\jdk8.171-i586\\bin;C:\\Program Files\\TortoiseHg\\;C:\\Program Files\\Microsoft SQL Server\\110\\Tools\\Binn\\;C:\\Program Files (x86)\\Microsoft SDKs\\TypeScript\\1.0\\;C:\\Program Files\\dotnet\\;C:\\Program Files\\Microsoft SQL Server\\130\\Tools\\Binn\\;C:\\Program Files\\nodejs\\;C:\\Users\\Administrator\\AppData\\Local\\Microsoft\\WindowsApps;C:\\Users\\Administrator\\AppData\\Roaming\\npm;C:\\Program Files\\docker;C:\\ProgramData\\chocolatey\\bin;C:\\Tools\\DevKit2\\bin;C:\\Tools\\DevKit2\\mingw\\bin;C:\\Tools\\ruby25\\bin;;C:\\tools\\sysinternals;C:\\Users\\builduser\\AppData\\Local\\Microsoft\\WindowsApps',
    'ProgramData': 'C:\\ProgramData',
    'ProgramFiles': 'C:\\Program Files',
    'ProgramFiles(x86)': 'C:\\Program Files (x86)',
    'ProgramW6432': 'C:\\Program Files',
    'SystemDrive': 'C:',
    'SystemRoot': 'C:\\Windows',
    'TEAMCITY_BUILDCONF_NAME': 'Skeletons (Windows)',
    'TEAMCITY_BUILD_PROPERTIES_FILE': 'C:\\BuildAgent\\temp\\buildTmp\\teamcity.build9219727127992950522.properties',
    'TEAMCITY_CAPTURE_ENV': '"C:\\tools\\jdk8.171-i586\\jre\\bin\\java.exe" -jar "C:\\BuildAgent\\plugins\\environment-fetcher\\bin\\env-fetcher.jar"',
    'TEAMCITY_GIT_PATH': 'C:\\BuildAgent\\plugins\\GitBinaries\\Win\\bin\\git.exe',
    'TEAMCITY_P4_PATH': 'C:\\BuildAgent\\plugins\\perforceDistributor\\p4files\\p4.exe',
    'TEAMCITY_PROCESS_FLOW_ID': '13142189302804902',
    'TEAMCITY_PROCESS_PARENT_FLOW_ID': '',
    'TEAMCITY_PROJECT_NAME': 'Utils',
    'TEAMCITY_VERSION': '2018.2 EAP3 (build 60707)',
    'TEMP': 'C:\\BuildAgent\\temp\\buildTmp',
    'TMP': 'C:\\BuildAgent\\temp\\buildTmp',
    'TMPDIR': 'C:\\BuildAgent\\temp\\buildTmp',
    'USERDOMAIN': 'WIN-UCLSU57F2BI',
    'USERNAME': 'builduser',
    'USERPROFILE': 'C:\\Users\\builduser',
    'VS100COMNTOOLS': 'C:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\Common7\\Tools\\',
    'VS110COMNTOOLS': 'C:\\Program Files (x86)\\Microsoft Visual Studio 11.0\\Common7\\Tools\\',
    'VS120COMNTOOLS': 'C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\Common7\\Tools\\',
    'VS140COMNTOOLS': 'C:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\Common7\\Tools\\',
    'WRAPPER_ARCH': 'x86',
    'WRAPPER_BITS': '32',
    'WRAPPER_FILE_SEPARATOR': '\\',
    'WRAPPER_OS': 'windows',
    'WRAPPER_PATH_SEPARATOR': ';',
    '_CFLAGS': '-I$(brew --prefix openssl)/include',
    '_CPPFLAGS': '-I$(brew --prefix zlib)/include',
    '_LDFLAGS': '-L$(brew --prefix openssl)/lib -L$(brew --prefix zlib)/lib',
    '_PYCHARM_DJANGO_DEFAULT_TIMEOUT': '20',
    'chocolatey_bin_root': 'C:\\Tools',
    'pycharm.env': 'true',
    'windir': 'C:\\Windows',
}

_have_functions = [
    'HAVE_FTRUNCATE',
    'MS_WINDOWS',
]

__spec__ = None # (!) real value is ''

