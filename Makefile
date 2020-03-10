# Copyright (c) 2017 by Thomas A. Early N7TAE

# if you change these locations, make sure the sgs-xl.service file is updated!
BINDIR=/usr/sbin
CFGDIR=/etc/sgs-xl

# choose this if you want debugging help
#CPPFLAGS=-g -ggdb -W -Wall -std=c++11 -DCFG_DIR=\"$(CFGDIR)\"
# or, you can choose this for a much smaller executable without debugging help
CPPFLAGS=-W -Wall -std=c++11 -DCFG_DIR=\"$(CFGDIR)\"

SRCS = $(wildcard *.cpp)
OBJS = $(SRCS:.cpp=.o)
DEPS = $(SRCS:.cpp=.d)

sgs-xl :  GitVersion.h $(OBJS)
	g++ $(CPPFLAGS) -o sgs-xl $(OBJS) -lconfig++ -pthread

%.o : %.cpp
	g++ $(CPPFLAGS) -MMD -MD -c $< -o $@

.PHONY: clean
clean:
	$(RM) GitVersion.h $(OBJS) $(DEPS) sgs-xl

-include $(DEPS)

# install, uninstall and removehostfiles need root priviledges
.PHONY: newhostfiles
newhostfiles :
	mkdir -p $(CFGDIR)
	wget -O $(CFGDIR)/DExtra_Hosts.txt http://www.pistar.uk/downloads/DExtra_Hosts.txt
	wget -O $(CFGDIR)/DCS_Hosts.txt http://www.pistar.uk/downloads/DCS_Hosts.txt

.PHONY: install
install : newhostfiles sgs-xl
	mkdir -p $(CFGDIR)
	cp -f sgs-xl.cfg $(CFGDIR)
	cp -f sgs-xl $(BINDIR)
	cp -f sgs-xl.service /lib/systemd/system
	sed -i "s|REPLACEME|/usr/sbin/sgs-xl /etc/sgs-xl/sgs-xl.cfg|g" /lib/systemd/system/sgs-xl.service
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

.PHONY: removehostfiles
removehostfiles :
	rm -f $(CFGDIR)/DExtra_Hosts.txt
	rm -f $(CFGDIR)/DCS_Hosts.txt

.PHONY: GitVersion.h
GitVersion.h: force
ifneq ("$(wildcard .git/index)","")
	echo "const char *gitversion = \"$(shell git rev-parse HEAD)\";" > $@
else
	echo "const char *gitversion = \"0000000000000000000000000000000000000000\";" > $@
endif

.PHONY: force
force: