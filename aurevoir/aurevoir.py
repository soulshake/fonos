from flask import Flask, render_template
from logging import getLogger, basicConfig, DEBUG, INFO, WARNING
import os
from threading import Lock
from zeroconf import ServiceInfo, Zeroconf, ServiceBrowser

class RootListener(object):
    def remove_service(self, z, service_type, service_name):
        log.info("We're told that the last {} stopped announcing.".format(service_name))
    def add_service(self, z, service_type, service_name):
        log.info("Discovered new service type {}".format(service_name))
        if service_name in browsers:
            log.info("Nothing to do, we already had a listener for {}".format(service_name))
            return
        browsers[service_name] = ServiceBrowser(z, service_name, ServiceListener())

class ServiceListener(object):
    def remove_service(self, z, service_type, service_name):
        log.info("Removed {}".format(service_name))
        del self.root_listener.services[service_name]
    def add_service(self, z, service_type, service_name):
        lock.acquire()
        log.info("Discovered {}".format(service_name))
        info = z.get_service_info(service_type, service_name)
        if len(info.address) == 4:
            info.ipv4 = '.'.join(str(ord(b)) for b in info.address)
            log.debug("Expanded {!r} to {}".format(info.address, info.ipv4))
        else:
            log.warning("Address {!r} length != 4; setting IPV4 field to empty string!".format(info.address))
            info.ipv4 = ''
        services[service_name] = info
        log.debug("We now have {} services".format(len(services)))
        lock.release()

log = getLogger(__name__)
basicConfig(level = DEBUG if os.environ.get("FLASK_DEBUG") else INFO)

zeroconf = Zeroconf()
root_listener = RootListener()
services = {}
browsers = {}
lock = Lock()
root_browser = ServiceBrowser(zeroconf, "_services._dns-sd._udp.local.", root_listener)

app = Flask(__name__)

@app.route('/')
def index():
    return render_template("services.html", services=services)

