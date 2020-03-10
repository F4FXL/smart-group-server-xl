# Copyright (c) 2017 by Thomas A. Early N7TAE

# if you change these locations, make sure the sgs-xl.service file is updated!
BINDIR=/usr/local/bin
CFGDIR=/usr/local/etc

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
newhostfiles :
	/usr/bin/wget http://www.pistar.uk/downloads/DExtra_Hosts.txt && sudo /bin/mv -f DExtra_Hosts.txt $(CFGDIR)
	/usr/bin/wget http://www.pistar.uk/downloads/DCS_Hosts.txt && sudo /bin/mv -f DCS_Hosts.txt $(CFGDIR)

install : sgs-xl
	/bin/cp -f sgs-xl.cfg $(CFGDIR)
	/bin/cp -f sgs-xl $(BINDIR)
	/bin/cp -f sgs-xl.service /lib/systemd/system
	systemctl enable sgs-xl.service
	systemctl daemon-reload
	systemctl start sgs-xl.service

uninstall :
	systemctl stop sgs-xl.service
	systemctl disable sgs-xl.service
	/bin/rm -f /lib/systemd/system/sgs-xl.service
	systemctl daemon-reload
	/bin/rm -f $(BINDIR)/sgs-xl
	/bin/rm -f $(CFGDIR)/sgs-xl.cfg

removehostfiles :
	/bin/rm -f $(CFGDIR)/DExtra_Hosts.txt
	/bin/rm -f $(CFGDIR)/DCS_Hosts.txt

GitVersion.h:
ifneq ("$(wildcard .git/index)","")
	echo "const char *gitversion = \"$(shell git rev-parse HEAD)\";" > $@
else
	echo "const char *gitversion = \"0000000000000000000000000000000000000000\";" > $@
endif
