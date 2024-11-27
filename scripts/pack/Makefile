TARGET = pack

CROSS_COMPILE =
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

C_SRC = $(wildcard *.c) $(wildcard ezxml/*.c)
S_SRC = $(wildcard *.s) $(wildcard *.S)
SRC = $(C_SRC) $(S_SRC)
OBJ = $(addsuffix .o, $(basename $(SRC)))
SU = $(addsuffix .su, $(basename $(SRC)))

OPT_CFLAGS = -g -O2

INCDIR = . 

CFLAGS = $(OPT_CFLAGS) -std=gnu11 -Wall -Werror\
	 $(foreach dir, $(INCDIR), -I$(dir))

ASFLAGS = $(OPT_CFLAGS) -x assembler-with-cpp \
          -Wa,--no-warn

LDFLAGS = $(OPT_CFLAGS) -static \
	  -Wl,-Map,$(TARGET).map -Wl,--gc-sections

ifeq ($(strip $(V)), 1)
	Q =
	E =
else
	Q = @
	E = 1>/dev/null 2>&1
endif

all: $(TARGET)

$(TARGET): $(TARGET).elf
	@echo '[OBJCOPY] $@'
	$(Q)cp $< $@

%.o: %.c
	@echo '[CC] $@'
	$(Q)$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.s
	@echo '[AS] $@'
	$(Q)$(AS) $(ASFLAGS) -c -o $@ $<

%.o: %.S
	@echo '[AS] $@'
	$(Q)$(AS) $(ASFLAGS) -c -o $@ $<

%.i: %.c
	@echo '[PP] $@'
	$(Q)$(CC) $(CFLAGS) -E -o $@ $<

$(TARGET).elf: $(OBJ)
	@echo '[LD] $@'
	$(Q)$(LD) $(OBJ) $(LDFLAGS) -o $@

%.dis: %.elf
	@echo '[OBJDUMP] $@'
	$(Q)$(OBJDUMP) -D $< > $@

.PHONY: clean distclean

clean:
	@echo '[CLEAN]'
	$(Q)-rm -rf $(OBJ)
	$(Q)-rm -rf $(SU)

distclean: clean
	@echo '[DISTCLEAN]'
	$(Q)-rm -rf $(TARGET).elf $(TARGET).dis $(TARGET).bin $(TARGET).map $(TARGET)
