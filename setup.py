#!/usr/bin/env python

from distutils.core import setup, Extension

setup(name="cdjango",
    version="0.0",
    description="C template library loosely inspired by Django's",
    author="Joshua Yanovski",
    author_email="pythonesque@gmail.com",
    url="https://www.github.com/pythonesque/cdjango",
    packages=[],
    ext_modules=[Extension(
        "cdjango",
        ["cdjango.c"],
        include_dirs=["."],
        define_macros=[
            ("POSIX_C_SOURCE", "200809L"),
            ("POSIX_SOURCE", "1"),
        ],
        library_dirs=["."],
        libraries=["template"],
    )],
    data_files=[(".", ["libtemplate.a"])],
)
