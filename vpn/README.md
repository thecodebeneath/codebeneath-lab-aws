# AWS Certificate Manager

Create a custom CA
```
export VPN_DOMAIN="vpn.codebeneath.org"
export VPN_CLIENT_DOMAIN="client.codebeneath.org"

cd ~/dev
git clone https://github.com/OpenVPN/easy-rsa.git

cd easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full "$VPN_DOMAIN" nopass
./easyrsa build-client-full "$VPN_CLIENT_DOMAIN" nopass

cp pki/ca.crt ~/dev/codebeneath-lab-aws/vpn/pki/
cp pki/issued/"$VPN_DOMAIN".crt ~/dev/codebeneath-lab-aws/vpn/pki/
cp pki/private/"$VPN_DOMAIN".key ~/dev/codebeneath-lab-aws/vpn/pki/
cp pki/issued/"$VPN_CLIENT_DOMAIN".crt ~/dev/codebeneath-lab-aws/vpn/pki/
cp pki/private/"$VPN_CLIENT_DOMAIN".key ~/dev/codebeneath-lab-aws/vpn/pki/
```

Import the two certs to AWS Certificate Manager for VPN usage
```
cd ~/dev/codebeneath-lab-aws/vpn/pki/

aws acm import-certificate --certificate fileb://"$VPN_DOMAIN".crt --private-key fileb://"$VPN_DOMAIN".key --certificate-chain fileb://ca.crt
aws acm import-certificate --certificate fileb://"$VPN_CLIENT_DOMAIN".crt --private-key fileb://"$VPN_CLIENT_DOMAIN".key --certificate-chain fileb://ca.crt
```

# OpenVPN Client

Download the OpenVPN config file `downloaded-client-config.ovpn`. Edit and add:

Edit
```
Modify DNS name by adding a random prefix: qwerty.cvpn-endpoint-0102bc4c2eEXAMPLE.prod.clientvpn.us-east-2.amazonaws.com
```

Add
```
<cert>
Contents of client certificate (.crt) file
</cert>
<key>
Contents of private key (.key) file
</key>
```

Import the edited config file into OpenVPN. Connect to VPN endpoint profile.
