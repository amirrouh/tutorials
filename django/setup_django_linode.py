import os
sudoPassword = 'Artinebaba7355!'
command = 'sudo apt update'
p = os.system('echo %s|sudo -S %s' % (sudoPassword, command))