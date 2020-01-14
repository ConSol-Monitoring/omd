import coshsh
from coshsh.application import Application
from coshsh.templaterule import TemplateRule
from coshsh.util import compare_attr

def __mi_ident__(params={}):
    if coshsh.util.compare_attr("type", params, "snmp_agent_for_unexpected_traps"):
        return SNMPAgentForUnexpectedTraps


class SNMPAgentForUnexpectedTraps(coshsh.application.Application):
    template_rules = [
        coshsh.templaterule.TemplateRule(needsattr=None, 
            template="app_snmp_agent_traps"),
    ]

