#!/usr/bin/env python3
#
# Listen for SMTP messages and forward to matrix
# /usr/local/sbin/smtp-to-matrix.py


# Imports
import asyncio
from aiosmtpd.controller import Controller
import email
import logging
import logging.handlers
import mailparser
from matrix_client.client import MatrixClient, MatrixHttpApi
from re import sub
import sys
import yaml

import atexit

@atexit.register
def goodbye():
    print('Exiting smtp to matrix daemon')
    client.logout()



# Define logger
logging.basicConfig(level=logging.WARN)
log = logging.getLogger('smtp-to-matrix.py')
handler = logging.handlers.SysLogHandler(address = '/dev/log')
log.addHandler(handler)
def log_debug(debug_message):
    if debug == True:
        print(debug_message)
def log_error(error_message):
    print(error_message)
    sys.exit(1)



# Load variables from config file
try:
    config = yaml.safe_load(open('/etc/smtp-to-matrix/config.yml', 'r'))
except FileNotFoundError:
    log_error("File not found: /etc/smtp-to-matrix/config.yml")

# Defining global config variables
debug = None
debug = config['debug']
user = None
user = config['user']
password = None
password = config['password']
server = None
server = config['server']
room_id = None
room_id = config['room_id']
if all(item is None for item in [debug, user, password, server, room_id]):
    log_error("configuration file variables incorrect, check /etc/smtp-to-matrix/config.yml")



# Login to matrix
client = MatrixClient(server) #, encryption=True)
try:
    token = client.login_with_password(user, password)
except Exception as e:
    log_error("Matrix login error: " + str(e))
try:
    room = client.join_room(room_id)
except Exception as e:
    log_error("Matrix join room error: " + str(e))



# Load hostname into variable
with open("/etc/hostname") as f:
   hostname = f.read().upper()




# Handle SMTP connections send matrix message
class CustomHandler:
    async def handle_DATA(self, server, session, envelope):
        peer = session.peer

        # email lib variant
        data = envelope.content.decode('utf-8')
        message = email.message_from_string(data)

        #mail_from = sub(r"[^a-zA-Z0-9\@\-\. ]", "", str(message.get('from')).upper())
        #subject = str(message.get('subject')).upper()

        # Manage multiplart messages
        maintype = message.get_content_maintype()
        if maintype == 'multipart':
            for part in message.walk():
                if part.get_content_type() == "text/plain":
                    # to control automatic email-style MIME decoding (e.g., Base64, uuencode, quoted-printable)
                    body = part.get_payload(decode=True)
                    body = body.decode()

        elif maintype == 'text':
            body = message.get_payload()

        # mail-parser variant
        message = mailparser.parse_from_bytes(envelope.content)
        mail_from = sub(r"[^a-zA-Z0-9\@\-\. ]", "", str((message.from_))).upper()
        subject = message.subject.upper()
        date = str(message.date)
        #body = message.body

        # Debug components
        log_debug("maintype: " + maintype)
        log_debug("from:     " + str(mail_from))
        log_debug("subject:  " + str(subject))
        log_debug("date:     " + str(date))
        log_debug("body:     " + str(body))

        # Build matrix message
        matrix_message = "HOST:       " + hostname + "\nFROM:      " + mail_from + "\nSUBJECT: " + subject + "\nDATE:        " + date + "\n\n" + body
        log_debug("\n\n==== MESSAGE FOR MATRIX ====\n" + str(matrix_message))

        # Send message via matrix
        if debug == False:
            room.send_text(matrix_message)
        return '250 OK'



# Daemonize smtpd
async def amain(loop):
    handler = CustomHandler()
    controller = Controller(handler, hostname='127.0.0.1', port=12325)
    controller.start()

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.create_task(amain(loop=loop))
    try:
        loop.run_forever()
    except:
        # KeyboardInterrupt
        pass
