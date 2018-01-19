import os
from setuptools import find_packages, setup

# allow setup.py to be run from any path
os.chdir(os.path.normpath(os.path.join(os.path.abspath(__file__), os.pardir)))

setup(
    name='aether.sync',
    version='0.0.0',
    description='A python module with Aether CoudhDB Sync functionality',
    url='https://github.com/eHealthAfrica/aether/',

    author='eHealth Africa',
    author_email='aether@ehealthafrica.org',

    license='Apache2 License',

    packages=find_packages(),
    python_requires='>=2.7, <4',
    install_requires=[
        'django>=2<2.1',
        'djangorestframework>=3.6<4',
    ],

    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Environment :: Web Environment',
        'Framework :: Django',
        'Framework :: Django :: 2.0',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: Software Development',
        'Topic :: Software Development :: Libraries',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
)