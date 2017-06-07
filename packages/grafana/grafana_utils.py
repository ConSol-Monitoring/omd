import urllib2
import json
import os
import time


settings = {}
with open(os.path.join(os.environ['OMD_ROOT'], 'etc', 'omd', 'site.conf')) as siteconf:
    for setting in [s for s in siteconf if '=' in s]:
        key, val = map(lambda x: x.strip().strip("'"), setting.split('='))
        settings[key] = val
    settings['CONFIG_GRAFANA_API_URL'] = 'http://127.0.0.1:%s/api' % (settings['CONFIG_GRAFANA_TCP_PORT'],)

class Grafana(object):
    content_header = {
        'Content-type':'application/json;charset=UTF-8',
        'X-WEBAUTH-USER': 'omdadmin'
    }
    omd_settings = settings
    api_url = omd_settings['CONFIG_GRAFANA_API_URL']
    tcp_port = omd_settings['CONFIG_GRAFANA_TCP_PORT']

    def __init__(self):
        try:
            self.datasources = [Datasource(ds) for ds in Grafana.get('/datasources')]
        except Exception:
            self.datasources = []
        try:
            self.dashboards = [Dashboard(ds) for ds in Grafana.get('/search')]
        except Exception:
            self.dashboards = []
        
    @staticmethod
    def ping(sec=5):
        for i in range(sec):
            if Grafana.answers():
                return True
            time.sleep(1)
        return False

    @staticmethod
    def answers():
        request = urllib2.Request(url=Grafana.api_url+'/datasources', headers=Grafana.content_header)
        try:
            datasources = json.loads(urllib2.urlopen(request).read())
            return True if isinstance(datasources, list) else False
        except Exception:
            return False

    def get_datasource(self, name):
        try:
            return [ds for ds in self.datasources if ds.name == name][0]
        except Exception:
            return None

    def create_datasource(self, **kwargs):
        try:
            ds = Datasource(kwargs)
            result = self.post('/datasources', ds.to_json())
            ds.id = result['id']
            return ds if result['message'] == 'Datasource added' else None
        except Exception:
            return None

    def get_dashboard(self, title):
        try:
            return [db for db in self.dashboards if db.title == title][0]
        except Exception:
            return None

    def import_dashboard(self, **kwargs):
        try:
            db = Dashboard(kwargs)
            result = self.post('/dashboards/import', db.to_json())
            db.description = result['description']
            db.title = result['title']
            db.installed = result['installed']
            return db if result['installed'] == True else None
        except Exception, e:
            return None

    @staticmethod
    def get(url):
        #handler=urllib2.HTTPHandler(debuglevel=1)
        #opener = urllib2.build_opener(handler)
        #urllib2.install_opener(opener)
        request = urllib2.Request(url=Grafana.api_url+url, headers=Grafana.content_header)
        try:
            return json.loads(urllib2.urlopen(request).read())
        except Exception:
            return None

    @staticmethod
    def post(url, data):
        request = urllib2.Request(url=Grafana.api_url+url, headers=Grafana.content_header, data=data)
        try:
            return json.loads(urllib2.urlopen(request).read())
        except Exception, e:
            return None

    @staticmethod
    def put(url, data):
        request = urllib2.Request(url=Grafana.api_url+url, headers=Grafana.content_header, data=data)
        request.get_method = lambda: 'PUT'
        try:
            return json.loads(urllib2.urlopen(request).read())
        except Exception:
            return None


class GrafanaComponent(object):

    def __init__(self, *args, **kwargs):
        for dictionary in args:
            for key in dictionary:
                setattr(self, key, dictionary[key])
        for key in kwargs:
            setattr(self, key, kwargs[key])

    def to_json(self):
        return(json.dumps(self.__dict__))


class Datasource(GrafanaComponent):

    def update(self, **kwargs):
        for key in kwargs:
            setattr(self, key, kwargs[key])
        result = Grafana.put('/datasources/'+str(self.id), self.to_json())
        try:
            return True if result['message'] == 'Datasource updated' else False
        except Exception:
            return False

class Dashboard(GrafanaComponent):
    pass




