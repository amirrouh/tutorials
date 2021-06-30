import sys
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
ip = (s.getsockname()[0])
s.close()

username = sys.argv[0]
myproject = sys.argv[1]
myprojectdir = sys.argv[1]
myprojectenv = "venv"

file_path = "/home/{0}/{1}/{2}/settings.py".format(username, myprojectdir, myproject)

new_lines = []
with open(file_path, 'r') as f:
    lines = f.readlines()
    for line in lines:
        if "ALLOWED_HOSTS = []":
            new_lines.append("ALLOWED_HOSTS = [{0}.com, www.{0}.com, {1}]".format(myproject, ip))
        else:
            new_lines.append(line)


with open(file_path, 'w') as f:
    for line in lines:
        f.write(line)
