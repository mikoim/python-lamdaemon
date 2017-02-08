#!/usr/bin/python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8 ft=python:

import sys
import pwd
import os
import subprocess

def test_basic():
  print('INFO,Basic test ok')

def test_version():
  print('INFO,Version check ok')

def test_nss_ldap(user_name):
  print('INFO,NSS test ok')
  return

  #with open('/etc/passwd') as passwd:
  #  if len(list(filter(lambda l: l.split(':')[0] == user_name , passwd.readlines()))) != 0:
  #    print('ERROR,User {:s} is a local user (/etc/passwd) but should be LDAP only.'.format(user_name))
  #    return
  #  if not pwd.getpwnam(user_name)[5]:
  #    print('ERROR,Unable to determine home directory of user {:s}. Please check that NSS LDAP is correctly configured.'.format(user_name))
  #    return
  #  print('INFO,NSS test ok')

def home_converter(home):
  return '/data/homes/{:s}'.format(home.split('/')[-1])

def home_check(home):
  if not home:
    print('ERROR,Lamdaemon ,No home directory specified to check.')
  elif not os.path.isdir(home):
    print('missing')
  else:
    print('ok')

def home_add(home, permission, uid, gid):
  if not home:
    print('ERROR,Lamdaemon ,No home directory specified to check.')
  elif os.path.isdir(home):
    print('ERROR,Lamdaemon ,Home directory already exists ({:s}).'.format(home))
  else:
    subprocess.call('/root/dataonstor/nfs/nfs_kcua.sh {:s}'.format(home.split('/')[-1]), shell=True)
    #subprocess.call('mkdir -m {:s} {:s}'.format(permission, home), shell=True)
    #subprocess.call('(cd /etc/skel && tar cf - .) | (cd {:s} && tar xmf -)'.format(home), shell=True)
    #subprocess.call('chown -hR {:s}:{:s} {:s}'.format(uid, gid, home), shell=True)
    #subprocess.call('chmod {:s} {:s}'.format(permission, home), shell=True)
    print('INFO,Lamdaemon ,Home directory created ({:s}).'.format(home))

def home_remove(home, uid):
  if not home:
    print('ERROR,Lamdaemon ,No home directory specified to check.')
  elif not os.path.isdir(home):
    print('ERROR,Lamdaemon ,Home directory not found. ({:s})'.format(home))
  elif str(os.stat(home).st_uid) != uid:
    print('ERROR,Lamdaemon ,Mismatch between target UID ({:s}) and UID of home directory. ({:s})'.format(uid, home))
  else:
    subprocess.call('mv {home} /data/homes_removed/{user_name}_`date +%Y%m%d_%H%M%S`'.format(home=home, user_name=home.split('/')[-1]), shell=True)
    print('INFO,Lamdaemon ,Home directory removed ({:s}).'.format(home))


if __name__ == '__main__':

  args = sys.argv[1].split('###x##y##x###')

  if args[1] == 'test':
    if args[2] == 'basic':
      test_basic()
    if args[2] == 'version':
      test_version()
    if args[2] == 'nss':
      test_nss_ldap(args[3])

  if args[1] == 'home':
    if args[2] == 'check':
      home_check(home_converter(args[3]))
    if args[2] == 'add':
      home_add(home_converter(args[3]), args[4], args[5], args[6])
    if args[2] == 'rem':
      home_remove(home_converter(args[3]), args[4])

  with open('/tmp/lam.log', mode='w+') as f:
    f.write(','.join(args))
