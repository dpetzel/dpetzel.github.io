"""
Fabfile for dpetzel.info project
"""

from fabric.api import local
from fabric.utils import error
import os

def build():
    """
    Build the HTML contents
    """
    local("tinker --build")
    # I've noticed sometimes when I make a mistake an index.html is not
    # created. Catch that
    index = './blog/html/index.html'
    if not os.path.isfile(index):
        msg = "{0} failed to render".format(index)
        error(msg)


def publish():
    """
    Publish the site
    """
    local("git checkout source")
    build()
    local("ghp-import -n -p -b master blog/html")
    
def push():
    """
    Push source up to github
    """
    local("git push origin source")
    