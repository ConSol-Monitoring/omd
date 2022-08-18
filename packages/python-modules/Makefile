include ../../Makefile.omd

NAME     = python-modules
SHELL    = /bin/bash
SLES12   = $(shell echo $(DISTRO_INFO) | grep -c 'SLES 12' )
FREETDS  = $(shell readlink -m ../freetds/tmpinstall$(OMD_ROOT))
HAS_CYTHON   = $(shell python3 has_cython.py)

ifeq ($(shell command -v python2),)
  BUILD_DEP=
  INSTALL_DEP=
else
  BUILD_DEP=build_p2
  INSTALL_DEP=install_p2
endif

# This is where the python modules are going to be installed to
LOCALPYTHONDIR=$(DESTDIR)$(OMD_ROOT)/lib/python
LOCALPYTHONDIR2=$(DESTDIR)$(OMD_ROOT)/lib/python2

MODULES2 =
include modules2.mk
MODULES =
ifeq ($(SLES12),1)
MODULES += setuptools-24.2.0.tar.gz
else
MODULES += setuptools-46.1.3.zip
endif
MODULES += six-1.14.0.tar.gz
MODULES += funcsigs-1.0.2.tar.gz
MODULES += mock-3.0.5.tar.gz
MODULES += defusedxml-0.6.0.tar.gz
MODULES += simplejson-3.8.2.tar.gz
MODULES += texttable-0.8.7.tar.gz
MODULES += ordereddict-1.1.tar.gz
MODULES += weakrefset-1.0.0.tar.gz
MODULES += pyexcel-io-0.3.2.tar.gz
MODULES += pyexcel-0.4.3.tar.gz
MODULES += odfpy-1.3.4.tar.gz
MODULES += pyexcel-ods-0.3.0.tar.gz
MODULES += jdcal-1.3.tar.gz
MODULES += et_xmlfile-1.0.1.tar.gz
MODULES += openpyxl-2.4.2.tar.gz
MODULES += future-0.16.0.tar.gz
MODULES += xlwt-future-0.8.0.tar.gz
MODULES += xlrd-1.0.0.tar.gz
MODULES += xlwt-1.2.0.tar.gz
MODULES += pyexcel-xlsx-0.3.0.tar.gz
MODULES += pyexcel-xls-0.3.1.tar.gz
MODULES += MarkupSafe-0.23.tar.gz
MODULES += Jinja2-2.11.3.tar.gz
MODULES += wstools-py3-0.54.4.tar.gz
#MODULES += fpconst-0.7.2.tar.gz
MODULES += docutils-0.12.tar.gz
MODULES += SOAPpy-py3-0.52.25.tar.gz
MODULES += PyYAML-5.1.tar.gz
MODULES += ecdsa-0.13.tar.gz
MODULES += gearman3-0.2.0.tar.gz
MODULES += six-1.10.0.tar.gz
MODULES += orderedmultidict-0.7.5.tar.gz
MODULES += pycrypto-2.6.1.tar.gz
MODULES += paramiko-1.18.2.tar.gz
MODULES += pyasn1-0.4.8.tar.gz
MODULES += ply-3.11.tar.gz
MODULES += pysmi-0.3.4.tar.gz
ifeq ($(SLES12), 0)
MODULES += pywbem-0.17.2.tar.gz
MODULES += pysmbc-1.0.23.tar.gz
endif
MODULES += requests-2.10.0.tar.gz
MODULES += prometheus_client-0.11.0.tar.gz
MODULES += nagiosplugin-1.3.2.tar.gz
MODULES += pyvmomi-6.7.1.2018.12.tar.gz
MODULES += pycryptodomex-3.8.1.tar.gz
MODULES += pysnmp-4.4.12.tar.gz

# More datasources for coshsh
MODULES += mysqlclient-1.3.12.tar.gz
ifeq ($(HAS_CYTHON),1)
# SLES12 doesn't have cython
MODULES += pymssql-2.1.5.tar.gz
endif

# for check_json_health
MODULES += decorator-4.4.0.tar.gz
MODULES += jsonpath-ng-1.4.3.tar.gz

# DataScryer:
#MODULES += functools32-3.2.3-2.tar.gz
#MODULES += vcversioner-2.16.0.0.tar.gz
#MODULES += jsonschema-2.5.1.tar.gz

build: $(BUILD_DEP)
	mkdir -p dest
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	    if [ `uname -m` = 'armv7l' ]; then \
		export PYMSSQL_DONT_BUILD_WITH_BUNDLED_FREETDS=1; \
	    else \
		export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1; \
	    fi; \
	    export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	    for M in $(MODULES); do \
	        if echo $$M | grep .tar.gz; then \
	            tar xzf ../src/$$M ; \
	        else \
	            unzip -o ../src/$$M ; \
	        fi; \
	        MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	        cd $$MDIR; \
	        echo PYTHONBUILD $$M ; \
			if [ `uname -m` = 'armv7l' ] && [[ "$$M" =~ .*pymssql.* ]]; then \
				sed -ri "/setuptools_git/d" setup.py; \
				sed -ri "s#include_dirs = \[\]#include_dirs = \['$(FREETDS)/include'\]#" setup.py; \
				sed -ri "s#library_dirs = \[\]#library_dirs = \['$(FREETDS)/lib'\]#" setup.py; \
					python3 setup.py build_ext -I $(FREETDS)/include -L $(FREETDS)/lib ; \
			else \
				sed -ri "/setuptools_git/d" setup.py; \
				if [[ $$M =~ .*pymssql.* ]] ; then \
					python3 setup.py build_ext --include-dirs=$(FREETDS)/include --library-dirs=$(FREETDS)/lib; \
				else \
					python3 setup.py build ; \
				fi ; \
			fi ; \
	        cd .. ; \
	    done
	
build_p2:
	mkdir -p dest2
	set -e ; cd dest2 && \
	    export PYTHONPATH=$(LOCALPYTHONDIR2); \
	    if [ `uname -m` = 'armv7l' ]; then \
		export PYMSSQL_DONT_BUILD_WITH_BUNDLED_FREETDS=1; \
	    else \
		export PYMSSQL_BUILD_WITH_BUNDLED_FREETDS=1; \
	    fi; \
	    export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	    for M in $(MODULES2); do \
	        if echo $$M | grep .tar.gz; then \
	            tar xzf ../src/$$M ; \
	        else \
	            unzip -o ../src/$$M ; \
	        fi; \
	        MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	        cd $$MDIR; \
	        echo PYTHON2BUILD $$M ; \
	        [[ "$$M" =~ .*pymssql.* ]] && ln -sf freetds0.95 freetds ; \
			if [ `uname -m` = 'armv7l' ] && [[ "$$M" =~ .*pymssql.* ]]; then \
				sed -ri "/setuptools_git/d" setup.py; \
				sed -ri "s#include_dirs = \[\]#include_dirs = \['$(FREETDS)/include'\]#" setup.py; \
				sed -ri "s#library_dirs = \[\]#library_dirs = \['$(FREETDS)/lib'\]#" setup.py; \
					python2 setup.py build_ext -I $(FREETDS)/include -L $(FREETDS)/lib ; \
			else \
				sed -ri "/setuptools_git/d" setup.py; \
					python2 setup.py build ; \
			fi ; \
	        cd .. ; \
	    done

install: $(INSTALL_DEP)
	mkdir -p $(LOCALPYTHONDIR)
	set -e ; cd dest && \
	    export PYTHONPATH=$$PYTHONPATH:$(LOCALPYTHONDIR); \
	    export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	    for M in $(MODULES); do \
	        MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	        cd $$MDIR ; \
	        echo PYTHONINSTALL $$M ; \
	        python3 setup.py install --home=$(DESTDIR)$(OMD_ROOT) \
	            --prefix='' \
	            --install-platlib=$(LOCALPYTHONDIR) \
	            --install-purelib=$(LOCALPYTHONDIR) ; \
	        cd .. ; \
	    done
	
install_p2:
	mkdir -p $(LOCALPYTHONDIR2)
	set -e ; cd dest2 && \
	    export PYTHONPATH=$(LOCALPYTHONDIR2); \
	    export http_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export https_proxy=http://external_dependencies_must_be_included_in_omd; \
	    export ftp_proxy=http://external_dependencies_must_be_included_in_omd; \
	    for M in $(MODULES2); do \
	        MDIR=$$(echo $$M | sed -e 's/.tar.gz//g' -e 's/.zip//g') ; \
	        cd $$MDIR ; \
	        echo PYTHON2INSTALL $$M ; \
	        python2 setup.py install --home=$(DESTDIR)$(OMD_ROOT) \
	            --prefix='' \
	            --install-scripts=$(DESTDIR)$(OMD_ROOT)/bin/py2 \
	            --install-headers=$(DESTDIR)$(OMD_ROOT)/include/python2 \
	            --install-data=$(DESTDIR)$(OMD_ROOT)/share/python2 \
	            --install-platlib=$(LOCALPYTHONDIR2) \
	            --install-purelib=$(LOCALPYTHONDIR2) ; \
	        cd .. ; \
	    done


skel:

clean:
	rm -rf dest
	rm -rf dest2
