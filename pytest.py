import django.template
import django.template.loaders
import django.template.loaders.filesystem
import django.template.loader
import django.conf
import itertools
import cProfile
import cdjango
# http://stackoverflow.com/questions/4675728/redirect-stdout-to-a-file-in-python
from os import close, dup, O_WRONLY

ALLOWED_INCLUDE_ROOTS = (".")

django.conf.settings.configure()

cProfile.run("""
import os
for i in itertools.repeat(0,1000):
    data = open('rest.template', "r").read()
    old = dup(1)
    close(1)
    os.open("/dev/null", O_WRONLY)
    print(django.template.Template(data).render(django.template.Context()))
    close(1)
    dup(old)
    close(old)""")
cProfile.run("""
import os
for i in itertools.repeat(0,1000):
    old = dup(1)
    close(1)
    os.open("/dev/null", O_WRONLY)
    cdjango.compile_template('test.template')
    close(1)
    dup(old)
    close(old)""")
