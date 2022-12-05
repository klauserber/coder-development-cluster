import os

class FilterModule(object):
    """
    Filter to check if a file resource exists.
    """
    def path_exits(self, path):
        return os.path.exists(path)

    def filters(self):
        return {
            "path_exists": self.path_exits
        }
