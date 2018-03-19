yum -y install openldap compat-openldap openldap-clients openldap-servers openldap-servers-sql openldap-devel
slappasswd
{SSHA}+T6Sz1nsaTGdSuyZFWLBFY2MeYLnWTaS
vim db.ldif
ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif
vim monitor.ldif
ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif
openssl req -new -x509 -nodes -out /etc/openldap/certs/sbor2.pem -keyout /etc/openldap/certs/sbor2.pem -days 365
openssl req -new -x509 -nodes -out /etc/openldap/certs/sbor2cert.pem -keyout /etc/openldap/certs/sbor2key.pem -days 365
chown -R ldap:ldap /etc/openldap/certs/*.pem
vim /opt/ldap/certs.ldif
ldapmodify -Y EXTERNAL  -H ldapi:/// -f /opt/ldap/certs.ldif
slaptest -u
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
vim /opt/ldap/base.ldif
ldapadd -x -W -D cn=ldapadm,dc=sbor2,dc=local -f /opt/ldap/base.ldif
