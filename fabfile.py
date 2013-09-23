"""
Fabfile for dpetzel.info project
"""

from fabric.api import local

def build():
    """
    Build the HTML contents
    """
    local("tinker --build")

def publish():
    """
    Publish the site
    """
    local("git checkout source")
    build()
    local("ghp-import -n -p -b master blog/html")
    