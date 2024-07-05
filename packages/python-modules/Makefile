include ../../Makefile.omd

NAME       = python-modules
SHELL      = /bin/bash
FREETDS    = $(shell readlink -m ../freetds/tmpinstall$(OMD_ROOT))
HAS_CYTHON = $(shell python3 has_cython.py)
PYTHON_V   = $(shell python3 --version 2>&1 | cut -d' ' -f2)

DEPENDS  = freetds

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python
BUILDDEST=$(shell pwd)/dest
WHEELSDIR=$(shell pwd)/wheels

PIP=python3 -m pip

# install toolchain required to build wheels
BASE =
BASE += setuptools-59.6.0.tar.gz
BASE += wheel-0.37.1.tar.gz
BASE += pip-21.3.1.tar.gz

MODULES =
MODULES += semantic_version-2.10.0.tar.gz            # setuptools-rust-1.5.2
MODULES += tomli-1.2.3.tar.gz                        # setuptools_scm-7.0.5 (last version that works with python 3.6)
MODULES += flit_core-3.5.1.tar.gz                    #  typing_extensions-4.4.0
MODULES += typing_extensions-3.10.0.2.tar.gz         # setuptools-rust-1.5.2 (last version that works with python 3.6)
MODULES += packaging-21.3.tar.gz                     # setuptools_scm-7.0.5 (last version that works with python 3.6)
MODULES += pyparsing-3.0.8.tar.gz                    # setuptools_scm-7.0.5 (last version that works with python 3.6)
MODULES += setuptools_scm-6.4.2.tar.gz               # pymssql-2.2.7(<7.0,>=5.0)
MODULES += setuptools-rust-1.1.2.tar.gz              # paramiko-2.12.0 deps (last version that works with python 3.6)
MODULES += setuptools-git-1.2.tar.gz                 # pymssql-2.2.7
MODULES += Cython-0.29.32.tar.gz                     # pymssql-2.2.7
MODULES += ply-3.11.tar.gz                           # jsonpath-ng-1.5.3, pysmi-0.3.4, pywbem-1.5.0
MODULES += charset-normalizer-2.1.1.tar.gz           #  requests-2.28.1
MODULES += idna-3.4.tar.gz                           #  requests-2.28.1
MODULES += urllib3-1.26.13.tar.gz                    #  requests-2.28.1(<1.27,>=1.21.1)
MODULES += certifi-2022.12.7.tar.gz                  #  requests-2.28.1
MODULES += chardet-3.0.4.tar.gz                      #  requests-2.28.1
MODULES += requests-2.27.1.tar.gz                    # pywbem-1.5.0

# Coshsh
MODULES += MarkupSafe-2.0.1.tar.gz                   # Jinja2-3.1.2
MODULES += Jinja2-3.0.3.tar.gz

# Coshsh - datasources
MODULES += mysqlclient-2.1.1.tar.gz
MODULES += pymssql-2.2.7.tar.gz
MODULES += mysql_connector_python-8.3.0-py2.py3-none-any.whl
MODULES += lml-0.1.0.tar.gz                          # pyexcel-0.7.0.tar.gz
MODULES += pyexcel-io-0.6.6.tar.gz                   # pyexcel-0.7.0.tar.gz
MODULES += texttable-1.6.7.tar.gz                    # pyexcel-0.7.0.tar.gz
MODULES += pyexcel-0.7.0.tar.gz
MODULES += defusedxml-0.7.1.tar.gz                   # odfpy-1.4.1.tar.gz
MODULES += odfpy-1.4.1.tar.gz                        # pyexcel-ods-0.6.0.tar.gz
MODULES += pyexcel-ods-0.6.0.tar.gz
MODULES += et_xmlfile-1.1.0.tar.gz                   # openpyxl-3.0.10.tar.gz
MODULES += openpyxl-3.0.10.tar.gz                    # pyexcel-xlsx-0.6.0.tar.gz
MODULES += pyexcel-xlsx-0.6.0.tar.gz

# for Ansible
MODULES += six-1.16.0.tar.gz                         # paramiko-2.12.0, pyvmomi
MODULES += paramiko-1.18.5.tar.gz
MODULES += PyYAML-6.0.tar.gz

# for snmp simulator and coshsh snmp inventory
MODULES += pysmi-0.3.4.tar.gz                        # pysnmp-4.4.12
MODULES += pycryptodomex-3.16.0.tar.gz               # pysnmp-4.4.12
MODULES += pyasn1-0.4.8.tar.gz                       # pysnmp-4.4.12
MODULES += pysnmp-4.4.12.tar.gz

# Exporter
MODULES += prometheus_client-0.15.0.tar.gz

# Plugins
MODULES += simplejson-3.18.0.tar.gz                  # ansible
MODULES += resolvelib-0.8.1.tar.gz                   # ansible
# for check_json_health
MODULES += decorator-4.4.0.tar.gz                    # jsonpath-ng-1.5.3
MODULES += jsonpath-ng-1.5.3.tar.gz
# for check_smb_copy
MODULES += pysmbc-1.0.23.tar.gz
# for check_vcenter
MODULES += pyvmomi-8.0.3.0.1.tar.gz                  # check_vsphere
# for check_redfish
MODULES += redfish-3.1.8.tar.gz
# for check_omd
MODULES += psutil-5.9.4.tar.gz

MODULES += gearman3-0.2.1.tar.gz
MODULES += nagiosplugin-1.3.3.tar.gz
# There is also an omdnotificationforwarder...whl (see $SWHEEL below)
# because "pip wheel ..." would require the hatch build system.
MODULES += omdnotificationforwarder-2.6.1.1-py3-none-any.whl
MODULES += omdeventhandler-1.1.0.1-py3-none-any.whl

# check_vsphere
MODULES += monplugin-0.6.2.tar.gz                    # check_vsphere
MODULES += checkvsphere-0.3.10.tar.gz

# pywbem?
#MODULES += nocaselist-1.0.6.tar.gz                   # pywbem-1.5.0
#MODULES += nocasedict-1.0.4.tar.gz                   # pywbem-1.5.0
#MODULES += yamlloader-1.2.2.tar.gz                   # pywbem-1.5.0
#MODULES += pywbem-1.5.0.tar.gz


build:
	mkdir -p wheels
	mkdir -p $(BUILDDEST)
	export PYTHONPATH=$(BUILDDEST):$$PYTHONPATH; \
	export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	export CFLAGS="-std=c99"; \
	set -e ; \
	for M in $(BASE); do \
		MBASE=$$(echo $$M | sed -E -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/-/\*/g') ; \
		WHEEL=$$(ls $(WHEELSDIR)/$${MBASE}-* 2>/dev/null | head -1) ; \
		[[ -n "$$WHEEL" ]] && [[ -f "$$WHEEL" ]] && continue ; \
		( \
			cd src && \
			( tar zxvf $$M || : ) && \
			cd ./$$MBASE/ && \
			python3 setup.py bdist_wheel; \
		); \
		mv  ./src/$$MBASE/dist/*.whl $(WHEELSDIR); \
		rm -rf ./src/$$MBASE/; \
		WHEEL=$$(ls $(WHEELSDIR)/$${MBASE}-* 2>/dev/null | head -1) ; \
		$(PIP) install --no-cache-dir --no-index --no-deps --find-links=$(WHEELSDIR) --target=$(BUILDDEST) --upgrade $$WHEEL ; \
	done; \
	for M in $(MODULES); do \
		MBASE=$$(echo $$M | sed -E -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/-(py2\.)*py3-.*whl//g' -e 's/-/\*/g') ; \
		WHEEL=$$(ls $(WHEELSDIR)/$${MBASE}-* 2>/dev/null | head -1) ; \
		SWHEEL=$$(ls src/$${MBASE}-* 2>/dev/null | head -1 | sed -e 's/^src.//g') ; \
		echo "** $$M **" ; \
		[[ -n "$$WHEEL" ]] && [[ -f "$$WHEEL" ]] && continue ; \
		if [[ $$M =~ .*pymssql.* ]]; then \
			if [ `uname -m` = 'armv7l' ]; then \
				export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1 \
			else \
				export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=0 ; \
			fi; \
			LINK_KRB5=NO \
			CFLAGS="-I $(FREETDS)/include -L $(FREETDS)/lib" \
			$(PIP) wheel --no-cache-dir --wheel-dir=$(WHEELSDIR) --find-links=$(WHEELSDIR) ./src/$$M ; \
		elif [[ $$M =~ .*mysql_connector_python.* ]]; then \
			if [[ "$$(printf '%s\n' "3.8" "$(PYTHON_V)" | sort -V | head -n 1)" != "3.8" ]]; then \
				echo mysql_connector_python requires a python newer than 3.8 ; \
				continue ; \
			else \
				$(PIP) wheel --no-cache-dir --no-index --no-deps --wheel-dir=$(WHEELSDIR) --find-links=$(WHEELSDIR) ./src/$$M ; \
			fi ; \
		elif [[ $$M =~ .*tomli.* ]]; then \
			( \
				cd src && \
				( tar zxvf $$M || : ) && \
				cd ./tomli-*/ && \
				python3 -c 'from setuptools import setup; setup(name="tomli", packages=["tomli"], package_data={"": ["*"]}, version="1.2.3")' bdist_wheel; \
			); \
			mv  ./src/tomli-*/dist/*.whl $(WHEELSDIR); \
			rm -rf ./src/tomli-*/; \
		elif [[ -n "$$SWHEEL" ]]; then \
			cp src/$$SWHEEL $(WHEELSDIR) ; \
		else \
			$(PIP) wheel --no-cache-dir --no-index --no-deps --wheel-dir=$(WHEELSDIR) --find-links=$(WHEELSDIR) ./src/$$M ; \
		fi ; \
		WHEEL=$$(ls $(WHEELSDIR)/$${MBASE}-* 2>/dev/null | head -1) ; \
		$(PIP) install --no-cache-dir --no-index --no-deps --find-links=$(WHEELSDIR) --target=$(BUILDDEST) --upgrade $$WHEEL ; \
	done

install:
	mkdir -p $(LOCALPYTHONDIR)
	rsync -a $(BUILDDEST)/. $(LOCALPYTHONDIR)/.
	mkdir -p $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/
	mv $(LOCALPYTHONDIR)/bin/check_vsphere $(DESTDIR)$(OMD_ROOT)/lib/monitoring-plugins/check_vsphere

skel:

clean:
	rm -rf dest
	rm -rf wheels

upstream:
	set -e ; cd src && \
	export WHEELSDIR=$$(realpath ../wheels) ; \
	for M in $(MODULES); do \
	    MODULE=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	    VERSION=$$(echo $$MODULE | sed "s/^.*-\([0-9.]*\)$$/\1/") ; \
	    MODULE=$$(echo $$MODULE | sed "s/^\(.*\)-\([0-9.]*\)$$/\1/") ; \
	    $(PIP) download --find-links=$${WHEELSDIR} --no-binary :all: --progress-bar off --no-deps -d . $${MODULE}==$${VERSION} ; \
	done
