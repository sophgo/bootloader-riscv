CC = gcc
RM = rm -f
CFLAGS =
OBJS = pack.o
TARGET = pack

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	
pack.o: pack.c pack.h

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	$(RM) $(OBJS) $(TARGET)