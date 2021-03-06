# Copyright (c) 2017 by Thomas A. Early N7TAE
# Copyright (c) 2019-2020 by Geoffrey Merck F4FXL - KC3FRA

# if you change these locations, make sure paths en with /
BINDIR=/usr/local/bin/
CFGDIR=/usr/local/etc/sgs-xl/
DATADIR=/usr/local/sgs-xl/data/

# choose this if you want debugging help
#CPPFLAGS=-g -ggdb -W -Wall -std=c++17 -DCFG_DIR=\"$(CFGDIR)\" -DDATA_DIR=\"$(DATADIR)\"
# or, you can choose this for a much smaller executable without debugging help
CPPFLAGS= -W -Wall -O3 -std=c++17 -DCFG_DIR=\"$(CFGDIR)\" -DDATA_DIR=\"$(DATADIR)\"

SRCS = $(wildcard *.cpp)
OBJS = $(SRCS:.cpp=.o)
DEPS = $(SRCS:.cpp=.d)

sgs-xl :  GitVersion.h $(OBJS)
	g++ $(CPPFLAGS) -o sgs-xl $(OBJS) -lconfig++ -lssl -lcrypto -pthread

%.o : %.cpp
	g++ $(CPPFLAGS) -MMD -MD -c $< -o $@

sgs-xl.crt sgs-xl.key :
	openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/CN=Smart Group Server XL" -keyout sgs-xl.key  -out sgs-xl.crt

.PHONY: clean
clean:
	$(RM) GitVersion.h $(OBJS) $(DEPS) sgs-xl sgs-xl.crt sgs-xl.key

-include $(DEPS)

# install, uninstall and removehostfiles need root priviledges
.PHONY: newhostfiles
newhostfiles :
	mkdir -p $(CFGDIR)
	mkdir -p $(DATADIR)
	wget -O $(DATADIR)/DExtra_Hosts.txt http://www.pistar.uk/downloads/DExtra_Hosts.txt
	wget -O $(DATADIR)/DCS_Hosts.txt http://www.pistar.uk/downloads/DCS_Hosts.txt

.PHONY: install
install : newhostfiles sgs-xl.key sgs-xl.crt sgs-xl
	mkdir -p $(CFGDIR)
	mkdir -p $(DATADIR)
	cp -rf data/* $(DATADIR)
	cp -f sgs-xl.cfg $(CFGDIR)
	cp -f sgs-xl.crt $(DATADIR)
	cp -f sgs-xl.key $(DATADIR)
	cp -f sgs-xl $(BINDIR)
	cp -f sgs-xl.service /lib/systemd/system
	sed -i "s|REPLACEME|$(BINDIR)sgs-xl $(CFGDIR)sgs-xl.cfg|g" /lib/systemd/system/sgs-xl.service
	systemctl enable sgs-xl.service
	systemctl daemon-reload
	systemctl start sgs-xl.service

.PHONY: uninstall
uninstall :
	systemctl stop sgs-xl.service
	systemctl disable sgs-xl.service
	rm -f /lib/systemd/system/sgs-xl.service
	systemctl daemon-reload
	rm -f $(BINDIR)/sgs-xl
	rm -rf $(CFGDIR)
	rm -rf $(DATADIR)

.PHONY: removehostfiles
removehostfiles :
	rm -f $(DATADIR)/DExtra_Hosts.txt
	rm -f $(DATADIR)/DCS_Hosts.txt

GitVersion.h: force
ifneq ("$(wildcard .git/index)","")
	echo "const char *gitversion = \"$(shell git rev-parse HEAD)\";" > $@
else
	echo "const char *gitversion = \"0000000000000000000000000000000000000000\";" > $@
endif

.PHONY: force
force:
