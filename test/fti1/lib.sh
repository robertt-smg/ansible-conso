
#!/bin/bash
function init() {
echo "verifying installed dnf packages..."

packages=("rsync")

for package in "${packages[@]}"; do
    echo "verifying installed dnf package $package..."
    if ! dnf list installed $package &> /dev/null; then
        echo "Info: $package is not installed. Installing $package now ..."
        if ! dnf install -y $package; then
            echo "Error: Failed to install $package."
            exit 1
        fi
    fi
done
# Define the SSH config block as a variable
read -r -d '' SSH_BLOCK <<'EOF'
Host *
	SendEnv TERM
	ForwardAgent yes
    IdentitiesOnly yes
	IdentityFile ~/.ssh/id_smg_github

Host ssh-fti-jmp #Menu
	User ssh
	CheckHostIP no
	StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
	HostName 192.168.178.170
	IdentityFile ~/.ssh/id_smg_github

Host aqdb1.prd.muc01.fti.int #Menu
	User root
    ProxyCommand ssh -q -W %h:%p ssh-fti-jmp
	CheckHostIP no
	StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
	HostName aqdb1.prd.muc01.fti.int

    IdentityFile ~/.ssh/id_gitlab

Host fti1.app1.vm #Menu
	User ansible
	port 22
	CheckHostIP no
	StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
	
	#LocalForward  192.168.178.170:2480 127.0.0.8:2480
	#LocalForward  192.168.178.170:2443 127.0.0.8:2443
	#LocalForward  192.168.178.170:443 127.0.0.8:443
	
	HostName 192.168.121.242
	
    IdentityFile ~/.ssh/id_gitlab    
EOF

# Check if the Host entry exists in ~/.ssh/config
if ! grep -q 'Host aqdb1.prd.muc01.fti.int' ~/.ssh/config 2>/dev/null; then
    echo "Adding aqdb1.prd.muc01.fti.int SSH config to ~/.ssh/config"
    printf "\n%s\n" "$SSH_BLOCK" >> ~/.ssh/config
else
    echo "SSH config for DB_aqdb1.prd.muc01.fti.int already present in ~/.ssh/config"
fi

if [ ! -f ~/.ssh/id_gitlab ]; then
    ID_GITLAB_PUB="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3DFzVzFO1H+NkOUMVURZT+8NKE3VRMGre26yKmoVS+/zfrVd9CAQATRDSYCdyFvVOfEE0kQpZHL60NWIOi8BFyHx9c+YJQTjfEzcB6cNnnXEl10GZHv19TbAFxv/qXmxPCoqszI6RA1GnWpvv0Ez13zAdnX3X1/9upBpYdgvqVGSdeR94MtGezJO7vLBahgDL9pK9pkrzPR5G6ZTYi9c7pFforefw3sjYQ1+IJddLQ9B5YuFiIQJS11HauR/M1VzAECFjlHvjZJjUnNKLE6sypRlznyO7zBkeYKPhnK3yOw+ZKYs3Tf+0ODOXPQUgGk0WQ0cTjWsxSbnW0+4RqKc7"
    read -r -d '' ID_GITLAB <<'EOF'
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,5CF1CB8447B62BED

VVz7PlMbr4WnQz/BCCzRjNaXNDxgBPmmiFhlVH9GKBb49lbYyEF8BBIbsUw31cdU
3+HOCsdcEeLVGRvXr4xZCprvs78WeBmxFooUo6yVT+aXNHtADCVEF6Tgnx7FuMOp
xl+WfHU+P4aoOftz8lPIxs5MKCEx/jc40CdeqyYrvGL5aqi8yzoCunoNAx5u0J1u
nZNmNwtKatec6uESLXGd4iCfkcWKnNYjZNDfHzLNIFNPJynGnhvFQcUf6keJv4/4
NYIVBV2lQGW7rAxNbe3FOYf5pJHED8tCW/A0mlKw0CQgSjLm99v9wQd/DKtKMRXN
uLdy0izTMdB5wlLpT3AOvRt1DpMHnjQU6rVNv0BQr2JB6rkNv4nI62y4/KdyLDIA
9KVNnYePtuXA5hI8cCWcqpThMPx9v2eLL6yWdO/tMiUB2Q34nfXeXAgCfmOutYJq
OlQMOTy35nUXwswlBFe5XbAEbbxPBOCxhDqYWKX8RjdZhRpPiRVr15UHMY5/48Xf
Gp840XunrHVAt+nBANZSlTgeUxPRcLgNFAwk+6Nxt2tpdRDUTSHBy5UOGcg0iAHk
7+PmgYDSRoZ+5ILFXctaLR8DCpPWmGjqtu40IkNixa2OiuSb/KFI6596E9lzoXED
5XhLQtuqNKCwgpnQSynN3/hDNtP9rYBL0F7AVkDVi1mgBZiU+bkOwBGplqOxT2bJ
8/cbCOZSbO1unDNVBhB24pyIFT6pe04nVBCoXX2WJT/1V+4CwOkSPwqiq++Q0T7R
ABc+1/2qX7ZEUiRdnSYcHwhQFKZr0yn2nKpnwbcTCHO35cPhBTVHdW8hsrz+UfRe
0w3X1IH/DSy6BwGXXpLgnw3a1wExQGJEL9W/zH4C0bys+qQFKrBn7srM/Ov3d8y4
7Ul/YK2Ay0C+zqOHUxr4kqPe/BiLXpMRY1f5KPxPl5BEviCHd6UmzfMRAwORsL/z
tvCPMgxeSfvxntioludo7+y3agOubeN9nrYLxQdBNrw2UcrYI0a9xYQ/pW7YBk9r
tUYS5y17ZWoGLmk8wwwrEgurOxcZdo9D3lNldX/zI63MDu87joHt2ll5+7JnBMl6
xCKCd57PhryUTs7VVa+XepgEGqRJUB0QuS3G728sdSkD9VwA5GWeTb9/v4LKlryL
IckEcsjs0v9ThcztWJYdGm9I4Wate2N/iA5Y9e/ELFmhCPg9XBNTSjzILT9M3QTE
LCyubNnAXB1WnqoO7FjJkORNGT/bJHR/2cpWtm1RXAYELdlcLnUiwZsI2iyMezjI
bcPOBHlG68UNXfAcgqtFGAimZeTDQhjDnsJFimufTUWEj7hTfZcG3S7VBDceSgdu
BqZNg+dxyvyUPUhFIP8OfWYRV3+RKgrSKfKMvPx6fRN5twwHegFgAdHt8jzqE0Bk
sYz2v6P24gXIfBN7Sd8u+xCwVCWTu1Hr26PEgEeUTpgYTMt8aGym/0S4abgIKWly
BxiYkqXWGp0qC3jRIlS7vEHSGtjByCMKJXhI5PjIjG/Zp3VcAKg+Eboro6+0BvIR
HKMSDaB5k0W0UKnyBlw/fh+uVV32pY8fU+4jvz0wG31vWKSBE7Vxrg==
-----END RSA PRIVATE KEY-----
EOF
    echo "Creating ~/.ssh/id_gitlab"
    printf "\n%s\n" "$ID_GITLAB" >> ~/.ssh/id_gitlab
    printf "\n%s\n" "$ID_GITLAB_PUB" >> ~/.ssh/id_gitlab.pub

fi

if [ ! -f ~/.ssh/id_smg_github ]; then
    ID_SMG_GITHUB_PUB="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEm0iUEqGejQUYcaV8L5XfzjCRaL/FBkE9eC0/0IQFAzb1T2YXcOMI7Bqw2KMHzkXHTcVatDlTXT+Y2teRxuQtPHsl5E2Cxp25bWLxKkn13lZ2CYaBtzswpQz3VXt2b8d1YtbfmSq3tjyQ86OpuSKAsWtCgEAuJchH/2e6gqPHNoo5O7LPDJGxHu2Cu4krzRZB+pn3ZPJnMkpSfxtF0oCSiEEp1jKWo/uZUaWzwnLNLpnI0em4s9I4RfMBNBOk8nFtQaGRcZs4HnQLizBToxJ3rZzC/qQddD9m5gZII6wN6iWVowZS3szqELRk8r5vXC1r/4qttkCeCSw7xp1AA+Ij"
    read -r -d '' ID_SMG_GITHUB <<'EOF'
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,D2D13B94A41E6867

ysIKIaA7poBqamoys6af9SLTaKZYNdyPRaBKXlir1XSrZR1lXap20BpIltSGVj/e
GhFO2/74520+oX7Qcb0vktjj/9Bzc8gPX+KK8th8soRVKnaukO2jzHNeJEGm65tY
sH81XC9l8iUxiXDQkTHZThERRJIhE0XtLOk3O4hURw+KaVvhhh35ZlOc3cTq83lD
tqhlNy1KrqOqmHB145nglOsBg0YhrJ/M6NQifqxIlYaQBk4Jr8CQGjq4pY9hwxHh
AwxJNIamcyE76nGdkbHtYQ1aOliNa28NZV/hbkexamFXMcvGowu3yhGzJL+V9ATJ
hRIfnnxJ/ZwJy51GWqDu6AZnBRF0EQCjDelYUYSRvzOsfefsSznnnTsSJhVaPUWK
DoVgLjJO4FGvPWMk1KvTBhlfqFNLlG/MQM7IrQWidLghkBOTHvtw1EMDJjwz29tS
BTcn6qM1U3yAB/GHsuxu3TLk5DEJnxLSUI152AowiZoQAhucRZ8y5WZYCapf8FDE
Zli1ZyrJSBW2h9y3L6P+8YYLcLrEBVvZQH0rM4AOR4EaI8eb8nZJ6xd9I/Inc7du
IC/UCKC6NG8MCkJKxEjRrAWp+aGkFZfwt5OMbO8WpqSY4p6+xM68DZD7TWXGQdT5
1oV1vCjxRLx/Mnw0U9MQCG1ijyVVYZLmbLNj3OA604QwTS0V+dzCc8B8Nt4x0Z6y
e9OH3wZ1NpB9uAdfB7jZZ2r/g2DDgsk33I44VjtI14/Adz3gICXcqIJ1W8YvMrgF
90QKvoNnXGtZpU4A7hJHXtN8bCHB7AqpnTJg8btEEtgG40vI6RAjCk+n1+AcWCPK
6FaTv7liZKJaqqeVh6TgJv0DGyvWNLuR8TseIec4Xc8QFfUdX1ulYvZu057k+SDn
Mbkoi0sYPYCgzOpeG5buBDc80iTr0d9z+0l8Gh8007Sx7N7mz2uf3dvi+m9A7L4e
40oIKfenKhFoLIjAg6Qf/hyFbLhwhKLJtdHqtmtH4vBpnhFUN2w1pNtVwHra7rqF
YcjvIO+Kdta9fi7U4RHy2NOBCHE0MEf6d9tkmop655QxWs+DxOYnbKhhmetEB+YZ
ZZ20YtgbG1v8co6TO0P6f1rWGIgVu6uz6uSJeZFecBfaWfpYww5CtywyEGAyVDjz
9hIENrnsMzhfKWFJMyFPOGTObXekdvdTLmwlJdsy+00kmwGz3NbkOkDHwLN8HyDh
O1VRFYllENRA+8Z5kDTiljM8+bgHMmpnyPNI+hVPlkzwCy4UXq2QZ+KQvEmplwHq
iCNTZAniplPRVQ6kA0Pqwf/E40EFe8lE/j6WjFtZuf0w3kM5DmZeYfod+TXnJBiv
Cx5NW6DnTxKRsE2l83Jbr3nUTkR8SO36bemPJ/3RGoIH7Q9qNIogcVIH8aJwwHfL
jdSKwUBpavxipUL9owaalKIwS1VdMGlndCPdBETnkJzt4O4pK2LBvOASlIeEaIjM
lX2qqHl/zd5WyLeQUkaO0FvxFw3Cu0zuid8ay5tMTMgnvIAM3DISrfVKCpYh5ODf
LkRgyjC5BFjicCs6PmO9xFHgHmY4XnUP5DT6XQQnpPUd1luIgRcaWg==
-----END RSA PRIVATE KEY-----
EOF
    echo "Creating ~/.ssh/id_smg_github"
    printf "\n%s\n" "$ID_SMG_GITHUB" >> ~/.ssh/id_smg_github
    printf "\n%s\n" "$ID_SMG_GITHUB_PUB" >> ~/.ssh/id_smg_github.pub
fi
chmod 0600 ~/.ssh/id_*
}