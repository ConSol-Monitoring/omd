include ../../Makefile.omd

NAME     = python-modules
SHELL    = /bin/bash
SLES12   = $(shell echo $(DISTRO_INFO) | grep -c 'SLES 12' )
FREETDS  = $(shell readlink -m ../freetds/tmpinstall$(OMD_ROOT))
HAS_CYTHON   = $(shell python3 has_cython.py)

DEPENDS  = freetds

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python

MODULES =
MODULES += wheel-0.38.4.tar.gz
MODULES += setuptools-65.6.3.tar.gz
MODULES += semantic_version-2.10.0.tar.gz            # setuptools-rust-1.5.2
MODULES += flit_core-3.8.0.tar.gz                    #  typing_extensions-4.4.0
MODULES += typing_extensions-4.4.0.tar.gz            # setuptools-rust-1.5.2
MODULES += setuptools-rust-1.5.2.tar.gz              # paramiko-2.12.0 deps
MODULES += setuptools-git-1.2.tar.gz                 # pymssql-2.2.7
MODULES += packaging-22.0.tar.gz                     # setuptools_scm-7.0.5
MODULES += tomli-2.0.1.tar.gz                        # setuptools_scm-7.0.5
MODULES += setuptools_scm-6.4.2.tar.gz               # pymssql-2.2.7(<7.0,>=5.0)
MODULES += Cython-0.29.32.tar.gz                     # pymssql-2.2.7
MODULES += ply-3.11.tar.gz                           # jsonpath-ng-1.5.3, pysmi-0.3.4, pywbem-1.5.0
MODULES += charset-normalizer-2.1.1.tar.gz           #  requests-2.28.1
MODULES += idna-3.4.tar.gz                           #  requests-2.28.1
MODULES += urllib3-1.26.13.tar.gz                    #  requests-2.28.1(<1.27,>=1.21.1)
MODULES += certifi-2022.12.7.tar.gz                  #  requests-2.28.1
MODULES += requests-2.28.1.tar.gz                    # pywbem-1.5.0, pyvmomi-7.0.3

# Coshsh
MODULES += MarkupSafe-2.1.1.tar.gz                   # Jinja2-3.1.2
MODULES += Jinja2-3.1.2.tar.gz

# Coshsh - datasources
MODULES += mysqlclient-2.1.1.tar.gz
MODULES += pymssql-2.2.7.tar.gz
MODULES += chardet-5.1.0.tar.gz                      # pyexcel-0.7.0.tar.gz
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
MODULES += pycparser-2.21.tar.gz                     #   cffi-1.15.1
MODULES += cffi-1.15.1.tar.gz                        #  bcrypt-3.2.2
MODULES += bcrypt-4.0.1.tar.gz                       # paramiko-2.12.0
MODULES += cryptography-3.4.8.tar.gz                 # paramiko-2.12.0
MODULES += PyNaCl-1.5.0.tar.gz                       # paramiko-2.12.0
MODULES += six-1.16.0.tar.gz                         # paramiko-2.12.0
MODULES += paramiko-2.12.0.tar.gz

# for snmp simulator and coshsh snmp inventory
MODULES += pysmi-0.3.4.tar.gz                        # pysnmp-4.4.12
MODULES += pycryptodomex-3.16.0.tar.gz               # pysnmp-4.4.12
MODULES += pyasn1-0.4.8.tar.gz                       # pysnmp-4.4.12
MODULES += pysnmp-4.4.12.tar.gz

# Exporter
MODULES += prometheus_client-0.15.0.tar.gz

# Plugins
MODULES += simplejson-3.18.0.tar.gz                  # ansible
MODULES += resolvelib-0.9.0.tar.gz                   # ansible
# for check_json_health
MODULES += decorator-4.4.0.tar.gz                    # jsonpath-ng-1.5.3
MODULES += six-1.16.0.tar.gz                         # jsonpath-ng-1.5.3
MODULES += jsonpath-ng-1.5.3.tar.gz
# for check_smb_copy
MODULES += pysmbc-1.0.23.tar.gz
# for check_vcenter
MODULES += pyvmomi-7.0.3.tar.gz
# for check_redfish
MODULES += redfish-3.1.8.tar.gz
# for check_omd
MODULES += psutil-5.9.4.tar.gz

MODULES += gearman3-0.2.1.tar.gz
MODULES += nagiosplugin-1.3.3.tar.gz

# pywbem?
#MODULES += nocaselist-1.0.6.tar.gz                   # pywbem-1.5.0
#MODULES += nocasedict-1.0.4.tar.gz                   # pywbem-1.5.0
#MODULES += PyYAML-6.0.tar.gz                         # pywbem-1.5.0
#MODULES += yamlloader-1.2.2.tar.gz                   # pywbem-1.5.0
#MODULES += pywbem-1.5.0.tar.gz


build:
	mkdir -p dest
	mkdir -p wheels
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	    export WHEELSDIR=$$(realpath ../wheels) ; \
	    export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export CRYPTOGRAPHY_DONT_BUILD_RUST=0 ; \
	    export PIP_IGNORE_INSTALLED=0 ; \
	    for M in $(MODULES); do \
		MBASE=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/-/\*/g') ; \
		WHEEL=$$(ls $${WHEELSDIR}/$${MBASE}-* 2>/dev/null | head -1) ; \
		[[ -n "$$WHEEL" ]] && [[ -f "$$WHEEL" ]] && continue ; \
		if [[ $$M =~ .*pymssql.* ]]; then \
		    if [ `uname -m` = 'armv7l' ]; then \
			export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1 \
		    else \
			export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=0 ; \
		    fi; \
		    LINK_KRB5=NO \
		    CFLAGS="-I $(FREETDS)/include -L $(FREETDS)/lib" \
		    pip wheel --no-index --no-cache-dir --wheel-dir=$$WHEELSDIR --find-links=$$WHEELSDIR ../src/$$M ; \
		elif [[ $$M =~ .*Jinja.* ]]; then \
		    MUSWHL=$$(ls $$WHEELSDIR/MarkupSafe* | tail -1) ; \
		    PYTHONPATH=$${PYTHONPATH}:$${MUSWHL} \
		    pip wheel --no-index --no-cache-dir --no-deps --wheel-dir=$$WHEELSDIR --find-links=$$WHEELSDIR ../src/$$M ; \
		else \
		    pip wheel --no-index --no-cache-dir --no-deps --wheel-dir=$$WHEELSDIR --find-links=$$WHEELSDIR ../src/$$M ; \
		fi ; \
	    done

install:
	mkdir -p $(LOCALPYTHONDIR)
	set -e ; cd dest && \
	    export WHEELSDIR=$$(realpath ../wheels) ; \
	    export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	    export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	    for M in $(MODULES); do \
		MBASE=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g' -e 's/-/\*/g') ; \
		WHEEL=$$(ls $${WHEELSDIR}/$${MBASE}-* | head -1) ; \
		pip install --no-index --no-cache-dir --no-deps --find-links=$${WHEELSDIR} --target=$(LOCALPYTHONDIR) --upgrade $$WHEEL ; \
	    done ; \
	    echo done
	
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
	    pip download --find-links=$${WHEELSDIR} --no-binary :all: --progress-bar off --no-deps -d . $${MODULE}==$${VERSION} ; \
	done


