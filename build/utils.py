import os
import zipfile


def set_modtime(filePath):
    ts = 1514764800  # 01/01/2018 12am UTC
    os.utime(filePath, (ts, ts))


def zip_directory(srcDir, dstPath):
    # modtimes AND order in which files are added to the archive will affect
    # resulting archive hash. os.walk (os.listdir) returns in an arbitrary order
    # so we sort the lists before iterating.
    zipf = zipfile.ZipFile(dstPath, 'w', zipfile.ZIP_DEFLATED)
    for root, dirs, files in os.walk(srcDir):
        dirs.sort()
        files.sort()
        set_modtime(root)
        for dir in dirs:
            set_modtime(os.path.join(root, dir))
        for file in files:
            set_modtime(os.path.join(root, file))
            relPath = os.path.relpath(os.path.join(root, file), srcDir)
            zipf.write(os.path.join(root, file), relPath)
    zipf.close()
