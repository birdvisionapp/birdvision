from locust import Locust, TaskSet, task, events
import re
import inspect
from itertools import count
import logging

logger = logging.getLogger('perf')
logger.setLevel(logging.ERROR)

def success_handler(method, path, response_time, response):
    logger.debug("Successfully fetched: %s" % (path))

events.request_success += success_handler
# -----------------------------------------------------------------------------

class ExpectResponse:
    def __init__(self, taskset, username, response):
        self.username = username
        self.response = response
        self.taskset = taskset

    def expect(self, url=None, code=None, match_text=None):
        if self.response is None:
            return
        if url is not None and self.response.url!= url:
            self.report_error("%s : Response url %s did not match %s" % (self.username, self.response.url, url))
            return
        if code is not None and self.response.status_code != code:
            self.report_error("%s : Response code %s did not match expected %s" % (self.username, self.response.status_code, code))
            return
        if match_text is not None and not re.search(match_text, self.response.text):
            logger.error("%s : %s" % (self.username, repr(self.response.text)))
            self.report_error("Response text did not match %s" % (match_text))
            return
        self.response.success()

    def report_error(self, msg):
        self.response.failure("%s : %s" % (msg, str(inspect.stack()[1])))
        self.taskset.interrupt()

class BaseTaskSet(TaskSet):
    _ids = count(1)

    def participant_login(self):
        self.username = "pc1.perf_%s" % self._ids.next()
        self.get("/")
        self.wait()
        self.post("/users/sign_in", {"user[username]": self.username, "user[password]":"password"}, interrupt=False).expect(code=200, match_text="Redemption Schemes")

    def admin_login(self):
        self.get("/admin").expect(code=200, match_text="Login to Admin")
        self.wait()
        self.post("/admin_users/sign_in", {"admin_user[username]":"admin", "admin_user[password]":"password"}).expect(code=200, match_text="Upload Participants")

    def on_stop(self):
        self.interrupt()

    def get(self, url):
        self.log_debug("Get for %s" % url)
        response = self.client.get(url, catch_response=True)
        self.retain_csrf_token(response)
        return ExpectResponse(self, self.username, response)

    def retain_csrf_token(self, response, interrupt=True):
        matched = re.search("<meta content=\"(.*)\" name=\"csrf-token\" />", response.text)
        if matched==None:
            self.csrf_token = None
            self.log_error(response.status_code)
            self.log_error(response.headers)
            self.log_error(response.url)
            self.log_error(response.text)
            self.log_error(response.error)
            if interrupt is True:
                response.failure(response.error)
                self.interrupt()
        else:
            self.csrf_token = matched.group(1)

    def post(self, url, params={}, interrupt=True):
        self.log_debug("Post for %s" % url)
        params["authenticity_token"] = self.csrf_token
        self.log_debug(params)
        response = self.client.post(url, params, catch_response=True)
        self.log_debug("Post response %s" % response.url)
        self.retain_csrf_token(response, interrupt)
        return ExpectResponse(self, self.username, response)

    def log_error(self, msg):
        logger.error("Failed for %s : %s" % (self.username, msg))

    def log_debug(self, msg):
        logger.debug("%s : %s" % (self.username, msg))
