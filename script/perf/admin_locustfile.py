from locust import Locust, TaskSet, task, events
from utils import *

class AdminPage(BaseTaskSet):

    def on_start(self):
        self.admin_login()

    @task
    def schemes(self):
        self.get("/admin/schemes").expect(code=200, match_text="Add New Scheme")

    @task
    def clients(self):
        self.get("/admin/clients").expect(code=200, match_text="Add New Client")

    @task
    def participants(self):
        self.get("/admin/users").expect(code=200, match_text="Upload Participants")

    @task
    def categories(self):
        self.get("/admin/categories").expect(code=200, match_text="Add New Category")

    @task
    def orders(self):
        self.get("/admin/order_items").expect(code=200, match_text="Download Orders CSV")

    @task
    def suppliers(self):
        self.get("/admin/suppliers").expect(code=200, match_text="Add New Supplier")

class AdminCatalogPage(BaseTaskSet):
    def on_start(self):
        self.admin_login()

    @task
    def draft_items(self):
        self.get("/admin/draft_items").expect(code=200, match_text="Draft Items")

    @task
    def master_catalog(self):
        self.get("/admin/master_catalog").expect(code=200, match_text="Master Catalog")

    @task
    def client_catalog(self):
        self.get("/admin/client_catalog/1").expect(code=200, match_text="Emerson Catalog")

class AdminBehavior(TaskSet):
    tasks = {AdminCatalogPage:1, AdminPage:1}
    @task
    def index(self):
        pass

class AdminUser(Locust):
    task_set = AdminBehavior
    min_wait=2000
    max_wait=9000