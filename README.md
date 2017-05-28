# Linotp - Docker
## With S3 integration for secret sharing

### About
This is my attempt of merging LinOTP with Kubernetes, I needed LinOTP for a large distributed network under Kubernetes with confidential secret sharing.

### To-Do

 - [ ] Share secrets with other method than S3 buckets.
 - [ ] Give more configuration parameters through environment variables.

### Download docker image

[Dockerhub](https://hub.docker.com/r/videlanicolas/linotp/)

```shell
docker pull videlanicolas/linotp
```

### Upload encKey and certificate in PKCS12 format

```shell
shasum encKey > encKey.sha1
mv encKey encKey.bak
openssl aes-256-cbc -a -salt -in encKey.bak -out encKey
openssl pkcs12 -export -out linotp_certificate.p12 -inkey privateKey.key -in certificate.crt
```

Upload <b>encKey</b>, <b>encKey.sha1</b> and <b>linotp_certificate.p12</b> to your S3 bucket. Take note of the passwords you've used so that you can share them with your Docker container through environment variables.

#### If you don't use S3 bucket for secret sharing then the container will use random encKey and certificate files.

### Environment variables
#### Required

 * LINOTP_TO_MAIL: Who should LinOTP send mails in case of errors.
 * LINOTP_FROM_MAIL: From which address should LinOTP send.
 * SMTP_SERVER: SMTP server's hostname or IP address.
 * LINOTP_USER: LinOTP token database user.
 * LINOTP_PASSWORD: LinOTP token database password.
 * LINOTP_HOSTNAME: LinOTP token database's hostname/IP.
 * LINOTP_DB: LinOTP token database's name.
 * RADIUS_SECRET: Freeradius secret.
 * RADIUS_REALM: Freeradius Realm.
 * RADIUS_SSL_CHECK: Should Freeradius check the LinOTP SSL certificate? Better not... (True/False).

#### Optional

 * LINOTP_AUDIT_DB: Database name for the Audit database, default: LINOTP_DB.
 * LINOTP_AUDIT_USER: User for the Audit database, default: LINOTP_USER.
 * LINOTP_AUDIT_PASSWORD: Password for the Audit username, default: LINOTP_PASSWORD.
 * LINOTP_AUDIT_HOSTNAME: Hostname/IP for the Audit database, default: LINOTP_HOSTNAME.
 * LINTOP_DEFAULTSYNCWINDOW: How many blank presses LinOTP will calculated further from its last known counter, default: 1000.
 * LINOTP_DEFAULTOTPLEN:  Length of the OTP value, default: 6.
 * LINOTP_DEFAULTCOUNTWINDOW: How many additional OTP values LinOTP will compute to verify the OTP value entered by the user. Default: 50.
 * LINOTP_DEFAULTMAXFAILCOUNT: Max fail counter, default: 15.
 * LINOTP_FAILCOUNTINCONFALSEPIN: Should LinOTP increase on wrong pin? You should, so don't change this. Default: True.
 * LINOTP_PREPENDPIN: If set to true (checked) the user needs to put the OTP PIN in front of the OTP value. Default: True.
 * LINOTP_DEFAULTRESETFAILCOUNT: Should fail count reset when the user makes a successful login? Default: True.
 * LINOTP_SPLITATSIGN: Should LinOTP split Realm and Username? Default: True.
 * AWS_BUCKET: AWS bucket name. Default: Use the automatic generated encKey and certificate.
 * AWS_SECRET_KEY: AWS secret key. Default: Use the automatic generated encKey and certificate.
 * AWS_ACCESS_KEY: AWS access key. Default: Use the automatic generated encKey and certificate.
 * ENCKEY_PASSWORD: Password for the encrypted encKey file. Default: None.
 * PKCS12_PASSWORD: Password for the PKCS12 encrypted certificate. Default: None.

### Run
An example run:
```shell
docker run -d -p 443:443 -p 1812:1812/udp \
-e LINOTP_TO_MAIL=to_mail@mail.com \
-e LINOTP_FROM_MAIL=from_mail@mail.com \
-e SMTP_SERVER=smtp.server.com \
-e LINOTP_USER=db_linotp \
-e LINOTP_PASSWORD=password \
-e LINOTP_HOSTNAME=database.server.com \
-e LINOTP_DB=linotp \
-e LINOTP_AUDIT_DB=audit \
-e AWS_ACCESS_KEY=12341234 \
-e AWS_SECRET_KEY=secret \
-e AWS_BUCKET=my_bucket \
-e ENCKEY_PASSWORD=encpassword \
-e PKCS12_PASSWORD=pkcs12password \
-e RADIUS_SSL_CHECK=False \
-e RADIUS_SECRET=secret \
-e RADIUS_REALM=realm \
videlanicolas/linotp
```
