# encoding: utf-8
# module audioop
# from (built-in)
# by generator 1.146
# no doc
# no imports

# functions

def add(*args, **kwargs): # real signature unknown
    """ Return a fragment which is the addition of the two samples passed as parameters. """
    pass

def adpcm2lin(*args, **kwargs): # real signature unknown
    """ Decode an Intel/DVI ADPCM coded fragment to a linear fragment. """
    pass

def alaw2lin(*args, **kwargs): # real signature unknown
    """ Convert sound fragments in a-LAW encoding to linearly encoded sound fragments. """
    pass

def avg(*args, **kwargs): # real signature unknown
    """ Return the average over all samples in the fragment. """
    pass

def avgpp(*args, **kwargs): # real signature unknown
    """ Return the average peak-peak value over all samples in the fragment. """
    pass

def bias(*args, **kwargs): # real signature unknown
    """ Return a fragment that is the original fragment with a bias added to each sample. """
    pass

def byteswap(*args, **kwargs): # real signature unknown
    """ Convert big-endian samples to little-endian and vice versa. """
    pass

def cross(*args, **kwargs): # real signature unknown
    """ Return the number of zero crossings in the fragment passed as an argument. """
    pass

def findfactor(*args, **kwargs): # real signature unknown
    """ Return a factor F such that rms(add(fragment, mul(reference, -F))) is minimal. """
    pass

def findfit(*args, **kwargs): # real signature unknown
    """ Try to match reference as well as possible to a portion of fragment. """
    pass

def findmax(*args, **kwargs): # real signature unknown
    """ Search fragment for a slice of specified number of samples with maximum energy. """
    pass

def getsample(*args, **kwargs): # real signature unknown
    """ Return the value of sample index from the fragment. """
    pass

def lin2adpcm(*args, **kwargs): # real signature unknown
    """ Convert samples to 4 bit Intel/DVI ADPCM encoding. """
    pass

def lin2alaw(*args, **kwargs): # real signature unknown
    """ Convert samples in the audio fragment to a-LAW encoding. """
    pass

def lin2lin(*args, **kwargs): # real signature unknown
    """ Convert samples between 1-, 2-, 3- and 4-byte formats. """
    pass

def lin2ulaw(*args, **kwargs): # real signature unknown
    """ Convert samples in the audio fragment to u-LAW encoding. """
    pass

def max(*args, **kwargs): # real signature unknown
    """ Return the maximum of the absolute value of all samples in a fragment. """
    pass

def maxpp(*args, **kwargs): # real signature unknown
    """ Return the maximum peak-peak value in the sound fragment. """
    pass

def minmax(*args, **kwargs): # real signature unknown
    """ Return the minimum and maximum values of all samples in the sound fragment. """
    pass

def mul(*args, **kwargs): # real signature unknown
    """ Return a fragment that has all samples in the original fragment multiplied by the floating-point value factor. """
    pass

def ratecv(*args, **kwargs): # real signature unknown
    """ Convert the frame rate of the input fragment. """
    pass

def reverse(*args, **kwargs): # real signature unknown
    """ Reverse the samples in a fragment and returns the modified fragment. """
    pass

def rms(*args, **kwargs): # real signature unknown
    """ Return the root-mean-square of the fragment, i.e. sqrt(sum(S_i^2)/n). """
    pass

def tomono(*args, **kwargs): # real signature unknown
    """ Convert a stereo fragment to a mono fragment. """
    pass

def tostereo(*args, **kwargs): # real signature unknown
    """ Generate a stereo fragment from a mono fragment. """
    pass

def ulaw2lin(*args, **kwargs): # real signature unknown
    """ Convert sound fragments in u-LAW encoding to linearly encoded sound fragments. """
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

