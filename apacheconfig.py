#! /usr/bin/python
import os,sys

def work(config):
	manage_dict = {	'AuthLDAPBindDN' : os.environ['APACHE_LDAP_DN'] if 'APACHE_LDAP_DN' in os.environ else None,
					'AuthLDAPBindPassword' : os.environ['APACHE_LDAP_PASSWORD'] if 'APACHE_LDAP_PASSWORD' in os.environ else None,
					'AuthLDAPURL' : os.environ['APACHE_LDAP_URL'] if 'APACHE_LDAP_URL' in os.environ else None,
					'AuthType' : os.environ['APACHE_AUTH_TYPE'] if 'APACHE_AUTH_TYPE' in os.environ else None,
					'AuthName' : os.environ['APACHE_AUTH_NAME'] if 'APACHE_AUTH_NAME' in os.environ else 'LinOTP2 admin area'}
	if 'APACHE_LDAP_DN' in os.environ:
		manage_dict['AuthBasicProvider'] = 'ldap'
		manage_dict['AuthUserFile'] = '/dev/null'
		manage_dict['require'] = 'user ' + os.environ['APACHE_REQUIRE_USER']
	else:
		manage_dict['AuthBasicProvider'] = 'Digest'
		manage_dict['AuthUserFile'] = os.environ['APACHE_USER_FILE'] if 'APACHE_USER_FILE' in os.environ else '/etc/linotp2/admins'
	manage = ''
	for key,value in manage_dict.iteritems():
		if value:
			manage += str(key) + ' ' + str(value) + '\n'
	return config.format(manage)

if __name__ == "__main__":
	print "Reading apache configuration ..."
	with open('/etc/apache2/sites-available/linotp2') as f:
		new_config = work(f.read())
	print "Writing apache configuration ..."
	with open('/etc/apache2/sites-available/linotp2','w') as f:
		f.write(new_config)