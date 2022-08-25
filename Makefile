TARGET := camera-streamer
SRC := $(wildcard **/*.c **/*/*.c **/*.cc **/*/*.cc)
HEADERS := $(wildcard **/*.h **/*/*.h **/*.hh **/*/*.hh)
HTML := $(wildcard html/*.js html/*.html)
PY := $(wildcard **/*/*.py **/*.py)

CFLAGS := -Werror -Wall -g -I$(CURDIR) -D_GNU_SOURCE
LDLIBS := -lpthread -lstdc++

ifneq (x,x$(shell which ccache))
CCACHE ?= ccache
endif

USE_FFMPEG ?= $(shell pkg-config libavutil libavformat libavcodec && echo 1)
USE_LIBCAMERA ?= $(shell pkg-config libcamera && echo 1)
USE_RTSP ?= $(shell pkg-config live555 && echo 1)
USE_PYTHON ?= $(shell pkg-config python3-embed && echo 1)

ifeq (1,$(DEBUG))
CFLAGS += -g
endif

ifeq (1,$(USE_FFMPEG))
CFLAGS += -DUSE_FFMPEG
LDLIBS += -lavcodec -lavformat -lavutil
endif

ifeq (1,$(USE_LIBCAMERA))
CFLAGS += -DUSE_LIBCAMERA $(shell pkg-config --cflags libcamera)
LDLIBS += $(shell pkg-config --libs libcamera)
endif

ifeq (1,$(USE_RTSP))
CFLAGS += -DUSE_RTSP $(shell pkg-config --cflags live555)
LDLIBS += $(shell pkg-config --libs live555)
endif

ifeq (1,$(USE_PYTHON))
CFLAGS += -DUSE_PYTHON $(shell pkg-config --cflags python3-embed) -Wno-error=deprecated-declarations
LDLIBS += $(shell pkg-config --libs python3-embed)
endif

HTML_SRC = $(addsuffix .c,$(HTML))
PY_SRC = $(addsuffix .c,$(PY))
OBJS = $(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(SRC) $(HTML_SRC) $(PY_SRC)))

.SUFFIXES:

all: $(TARGET)

%: cmd/% $(OBJS)
	$(CCACHE) $(CXX) $(CFLAGS) -o $@ $(filter-out cmd/%, $^) $(filter $</%, $^) $(LDLIBS)

install: $(TARGET)
	install $(TARGET) /usr/local/bin/

clean:
	rm -f .depend $(OBJS) $(OBJS:.o=.d) $(HTML_SRC) $(TARGET)

headers:
	find -name '*.h' | xargs -n1 $(CCACHE) $(CC) $(CFLAGS) -std=gnu17 -Wno-error -c -o /dev/null
	find -name '*.hh' | xargs -n1 $(CCACHE) $(CXX) $(CFLAGS) -std=c++17 -Wno-error -c -o /dev/null

-include $(OBJS:.o=.d)

%.o: %.c
	$(CCACHE) $(CC) -std=gnu17 -MMD $(CFLAGS) -c -o $@ $<

%.o: %.cc
	$(CCACHE) $(CXX) -std=c++17 -MMD $(CFLAGS) -c -o $@ $<

html/%.c: html/%
	xxd -i $< > $@.tmp
	mv $@.tmp $@

%.py.c: %.py
	xxd -i $< > $@.tmp
	mv $@.tmp $@
