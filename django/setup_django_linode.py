import os
from . import local_settings

sudoPassword = local_settings.SUDO_PASSWORD

def run(command):
    os.system('echo %s|sudo -S %s' % (sudoPassword, command))


