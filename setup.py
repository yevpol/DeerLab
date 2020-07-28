from setuptools import setup, find_packages
from setuptools.command.install import install
from setuptools.command.develop import develop
import platform
import subprocess

def install_dependencies():
   subprocess.run(['pip','install','memoization'])
   subprocess.run(['pip','install','matplotlib'])
   subprocess.run(['pip','install','pytest'])
   if platform.system() is 'Windows':  
      subprocess.run(['pip','install','pipwin'])
      subprocess.run(['pipwin','install','numpy'])
      subprocess.run(['pipwin','install','scipy'])
      subprocess.run(['pipwin','install','cvxopt'])

class install_routine(install):
   """Customized setuptools install command"""
   def run(self):
      install.run(self)
      install_dependencies()

class develop_routine(develop):
   """Customized setuptools install command"""
   def run(self):
      develop.run(self)
      install_dependencies()

setup(
   name='DeerLab',
   version=open('VERSION').read(),
   author='Luis Fabregas, Stefan Stoll and other contributors',
   package_dir={'deerlab': 'deerlab',
                'deerlab.utils': 'deerlab/utils'},
   packages=['deerlab','deerlab.utils'],
   url='https://jeschkelab.github.io/DeerLab/',
   license='LICENSE.txt',
   description='',
   long_description=open('README.md').read(),
   cmdclass={
      'install': install_routine,
      'develop': develop_routine},
)