#! /bin/bash
echo "Configuring linotp.ini ..."
#Comment
sed -i "/^port = /s/^#*/#/" /etc/linotp2/linotp.ini
sed -i "/^host = /s/^#*/#/" /etc/linotp2/linotp.ini
sed -i "/^use = egg:Paste#http/s/^#*/#/" /etc/linotp2/linotp.ini
#Uncomment
sed -i "/^#email_to = /s/^#*//" /etc/linotp2/linotp.ini
sed -i "/^#linotpAudit.type = /s/^#*//" /etc/linotp2/linotp.ini
sed -i "/^#linotpAudit.sql.url = /s/^#*//" /etc/linotp2/linotp.ini
#Change value
sed -i "/^email_to = /s/=.*/= $LINOTP_TO_MAIL/" /etc/linotp2/linotp.ini
sed -i "/^smtp_server = /s/=.*/= $SMTP_SERVER/" /etc/linotp2/linotp.ini
sed -i "/^error_email_from = /s/=.*/= $LINOTP_FROM_MAIL/" /etc/linotp2/linotp.ini
if ! env | grep -q "^LINOTP_AUDIT_DB="
	then
		LINOTP_AUDIT_DB=LINOTP_DB
fi
if env | grep -q "^LINOTP_AUDIT_USER=" && env | grep -q "^LINOTP_AUDIT_PASSWORD=" && env | grep -q "^LINOTP_AUDIT_HOSTNAME="
	then 
		sed -i "/^linotpAudit.sql.url = /s/=.*/= mysql:\/\/$LINOTP_AUDIT_USER:$LINOTP_AUDIT_PASSWORD@$LINOTP_AUDIT_HOSTNAME\/$LINOTP_AUDIT_DB/" /etc/linotp2/linotp.ini
	else
		sed -i "/^linotpAudit.sql.url = /s/=.*/= mysql:\/\/$LINOTP_USER:$LINOTP_PASSWORD@$LINOTP_HOSTNAME\/$LINOTP_AUDIT_DB/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINTOP_DEFAULTSYNCWINDOW=
	then
		sed -i "/^linotp.DefaultSyncWindow = /s/=.*/= $LINTOP_DEFAULTSYNCWINDOW/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_DEFAULTOTPLEN=
	then
		sed -i "/^linotp.DefaultOtpLen = /s/=.*/= $LINOTP_DEFAULTOTPLEN/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_DEFAULTCOUNTWINDOW=
	then
		sed -i "/^linotp.DefaultCountWindow = /s/=.*/= $LINOTP_DEFAULTCOUNTWINDOW/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_DEFAULTMAXFAILCOUNT=
	then
		sed -i "/^linotp.DefaultMaxFailCount = /s/=.*/= $LINOTP_MAXFAILCOUNT/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_FAILCOUNTINCONFALSEPIN=
	then
		sed -i "/^linotp.FailCounterIncOnFalsePin = /s/=.*/= $LINOTP_FAILCOUNTINCONFALSEPIN/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_PREPENDPIN=
	then
		sed -i "/^linotp.PrependPin = /s/=.*/= $LINOTP_PREPENDPIN/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_DEFAULTRESETFAILCOUNT=
	then
		sed -i "/^linotp.DefaultResetFailCount = /s/=.*/= $LINOTP_DEFAULTRESETFAILCOUNT/" /etc/linotp2/linotp.ini
fi
if env | grep -q ^LINOTP_SPLITATSIGN=
	then
		sed -i "/^linotp.splitAtSign = /s/=.*/= $LINOTP_SPLITATSIGN/" /etc/linotp2/linotp.ini
fi
sed -i "/^sqlalchemy.url = /s/=.*/= mysql:\/\/$LINOTP_USER:$LINOTP_PASSWORD@$LINOTP_HOSTNAME\/$LINOTP_DB/" /etc/linotp2/linotp.ini

if env | grep -q ^AWS_BUCKET= && env | grep -q ^AWS_SECRET_KEY= && env | grep -q ^AWS_ACCESS_KEY=; then
	echo "Retrieving encKey file ..."
	if env | grep -q ^AWS_PATH=; then
		s3download $AWS_BUCKET $AWS_PATH/encKey $AWS_ACCESS_KEY $AWS_SECRET_KEY /etc/linotp2/encKey.enc
		s3download $AWS_BUCKET $AWS_PATH/encKey.sha1 $AWS_ACCESS_KEY $AWS_SECRET_KEY /etc/linotp2/encKey.sha1
	else
		s3download $AWS_BUCKET encKey $AWS_ACCESS_KEY $AWS_SECRET_KEY /etc/linotp2/encKey.enc
		s3download $AWS_BUCKET encKey.sha1 $AWS_ACCESS_KEY $AWS_SECRET_KEY /etc/linotp2/encKey.sha1
	fi
	if env | grep -q ^ENCKEY_PASSWORD=
		then
			echo "Decrypting encKey file ..."
			openssl aes-256-cbc -d -a -in /etc/linotp2/encKey.enc -out /etc/linotp2/encKey -k $ENCKEY_PASSWORD
			if ! (cd /etc/linotp2 && shasum -c encKey.sha1)
				then
					echo "Wrong decryption key or encKey is corrupt." > /dev/stderr
					exit 1
				else
					echo "Successfully decrypted encription key."
			fi
		else
			echo "Using random encription key."
	fi
	if env | grep -q ^PKCS12_PASSWORD=; then
		echo "Retrieving linotp_certificate.p12 file ..."
		if env | grep -q ^AWS_PATH=; then
			s3download $AWS_BUCKET $AWS_PATH/linotp_certificate.p12 $AWS_ACCESS_KEY $AWS_SECRET_KEY /etc/linotp2/linotp_certificate.p12
		else
			s3download $AWS_BUCKET linotp_certificate.p12 $AWS_ACCESS_KEY $AWS_SECRET_KEY /etc/linotp2/linotp_certificate.p12
		fi
		openssl pkcs12 -in /etc/linotp2/linotp_certificate.p12 -nocerts -out /etc/linotp2/private.pem -password file:<( echo -n "$PKCS12_PASSWORD" ) -passout file:<( echo -n "12344321")
		openssl rsa -in /etc/linotp2/private.pem -out /etc/linotp2/private.pem -passin file:<( echo -n "12344321")
		openssl rsa -pubout -in /etc/linotp2/private.pem -out /etc/linotp2/public.pem
		rm -f /etc/linotp2/linotp_certificate.p12
	else
		echo "Using default RSA certificate."
	fi
fi
echo "Configuring apache file linotp.conf ..."
apacheconfig
cat /etc/apache2/sites-enabled/linotp2.conf
echo "Configuring freeradius ..."
sed -i 's/^\(.*secret  =\).*/\1 '$RADIUS_SECRET'/' /etc/freeradius/clients.conf
sed -i 's/^\(.*REALM=\).*/\1'$RADIUS_REALM'/' /etc/linotp2/rlm_perl.ini
sed -i 's/^\(.*SSL_CHECK=\).*/\1'$RADIUS_SSL_CHECK'/' /etc/linotp2/rlm_perl.ini

#sed -i "/^secret  =/s/=.*/= $RADIUS_SECRET/" /etc/freeradius/clients.conf
#sed -i "/^REALM=/s/=.*/= $RADIUS_REALM/" /etc/linotp2/rlm_perl.ini
#sed -i "/^SSL_CHECK=/s/=.*/= $RADIUS_SSL_CHECK/" /etc/linotp2/rlm_perl.ini
#Start apache2 (wtf...)
service apache2 start
#Start freeradius
freeradius -X
