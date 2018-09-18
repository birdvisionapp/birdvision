# Follow installation instructions from locust.io
# Run using /usr/local/share/python/locust --host http://localhost:3000 -c 2 -r 2  --no-web in current directory
from locust import Locust, TaskSet, task, events
from utils import *

class SchemesPage(BaseTaskSet):

    def on_start(self):
        self.participant_login()

    @task(2)
    def schemes(self):
        self.get("/schemes").expect(code=200, match_text="Redemption Schemes")

    @task(2)
    def items(self):
        self.get("/schemes/perf-big-bang-dhamaka-0/catalogs").expect(code=200, match_text="Perf Big Bang Dhamaka 0")

    @task(2)
    def categories(self):
        self.get("/schemes/perf-big-bang-dhamaka-0/search?search%5Bkeyword%5D=Camerawalla").expect(code=200, match_text="No Search Results")

    @task(1)
    def search(self):
        self.get("/schemes/perf-big-bang-dhamaka-0/search?utf8=%E2%9C%93&search%5Bkeyword%5D=tie&commit=").expect(code=200, match_text="tie")

class RedemptionPage(BaseTaskSet):
    def on_start(self):
        self.participant_login()

    @task
    def redeem(self):
        self.add_to_cart()
        self.wait()
        self.enter_delivery_address()
        self.wait()
        self.create_order()

    def add_to_cart(self):
        self.get("/schemes/perf-big-bang-dhamaka-0/carts/add?id=black-tie").expect(code=200, match_text="Shopping Cart")

    def enter_delivery_address(self):
        self.get("/schemes/perf-big-bang-dhamaka-0/orders/new").expect(code=200, match_text="Please enter the Shipping Address")
        order_params = {
            "order[address_name]":"perf_addr_name",
            "order[address_body]":"perf_addr_body",
            "order[address_landmark]":"perf_landmark",
            "order[address_city]":"perf_addr_city",
            "order[address_state]":"perf_addr_state",
            "order[address_zip_code]":"123456",
            "order[address_phone]":"9876543210",
            "order[address_landline_phone]" : "perf_landline",
            "commit": "Confirm"
        }
        self.post("/schemes/perf-big-bang-dhamaka-0/orders/preview", order_params).expect(code=200, match_text="Please review your Order")

    def create_order(self):
        self.post("/schemes/perf-big-bang-dhamaka-0/orders").expect(code=200, match_text="Thank you for your order")


class ParticipantBehavior(TaskSet):
    tasks = {RedemptionPage:1, SchemesPage:1}
    @task
    def index(self):
        pass

class ParticipantUser(Locust):
    task_set = ParticipantBehavior
    min_wait=2000
    max_wait=9000