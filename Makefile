BUILD			?= dev

NAME		:= ft_ping
TEST_NAME	:= ft_ping_test

SRC_DIR		:= src
TEST_DIR	:= test
INC_DIR		:= inc
OBJ_DIR		:= obj/$(BUILD)

# normal source and object files
SRC			:=
vpath %.c $(SRC_DIR)
SRC			+= main.c

OBJ			:= $(SRC:%.c=%.o)
OBJ			:= $(addprefix $(OBJ_DIR)/, $(OBJ))
DEP			:= $(OBJ:%.o=%.d)

# test source and object files
TEST_SRC	:= $(filter-out main.c,$(SRC))
vpath %.c $(TEST_DIR)
TEST_SRC	+= test.c

OBJ_TEST	:= $(TEST_SRC:%.c=%.o)
OBJ_TEST	:= $(addprefix $(OBJ_DIR)/, $(OBJ_TEST))
DEP_TEST	:= $(OBJ_TEST:%.o=%.d)

CC			:= clang
CFLAGS		:=
CFLAGS		+= -std=c23

CPPFLAGS	:=
CPPFLAGS	+= -D_POSIX_C_SOURCE=200809L
CPPFLAGS	+= -MMD
CPPFLAGS	+= -MP
CPPFLAGS	+= $(addprefix -I, $(INC_DIR))

CMOCKA_LIBS	:=
CMOCKA_LIBS	+= -lcmocka

LDFLAGS		:=

RM			:= rm -f
RMDIR		:= rm -rf

CLANG_FORMAT	:= clang-format
CFMT_SPECS		:= '*.c' '*.h'

DIR_DUP			= mkdir -p $(@D)

# build options

STRICT_CFLAGS	:=
STRICT_CFLAGS	+= -Wall
STRICT_CFLAGS	+= -Wextra
STRICT_CFLAGS	+= -Werror
STRICT_CFLAGS	+= -Wpedantic
STRICT_CFLAGS	+= -Wconversion
STRICT_CFLAGS	+= -Wfloat-equal # == or != between floating-point operands
STRICT_CFLAGS	+= -Wdouble-promotion # float silently promoted to double
STRICT_CFLAGS	+= -Wcast-qual # casting away const/volatile
STRICT_CFLAGS	+= -Wcast-qual # casting away const/volatile
STRICT_CFLAGS	+= -Wcast-function-type # function-pointer cast where signiture differs in a dangerous way
STRICT_CFLAGS	+= -Wbad-function-cast # casting return to an unrelated type
STRICT_CFLAGS	+= -Wunsequenced # expression with unsequenced side effects
STRICT_CFLAGS	+= -Wshadow
STRICT_CFLAGS	+= -Werror=unknown-warning-option # makes mistyped name hard error instead of no-op
STRICT_CFLAGS	+= -Wimplicit-fallthrough
STRICT_CFLAGS	+= -Wswitch-default
STRICT_CFLAGS	+= -Wswitch-enum
STRICT_CFLAGS	+= -Wundef	# evaluating undefined macro in #if/#elif
STRICT_CFLAGS	+= -Wmissing-variable-declarations # globals without extern declaration -> should be static
STRICT_CFLAGS	+= -Wmissing-prototypes # global function defined without prototype earlier
STRICT_CFLAGS	+= -Wstrict-prototypes # function declarations without prototypes
STRICT_CFLAGS	+= -Wold-style-definition # K&R-style definitions
STRICT_CFLAGS	+= -Wnested-externs # extern declarations inside function bodies (they still have file scope)
STRICT_CFLAGS	+= -Wredundant-decls
STRICT_CFLAGS	+= -Wvla # rejects variable length arrays
STRICT_CFLAGS	+= -Wcomma # any use of comma operator
STRICT_CFLAGS	+= -Wexpansion-to-defined # macro that expands to defined(...) used in directive -> UB
STRICT_CFLAGS	+= -Wextra-semi-stmt # stray ; that forms empty statement after control construct
STRICT_CFLAGS	+= -Wused-but-marked-unused # something marked __attribute__((unsused)), that IS used
STRICT_CFLAGS	+= -Wnonnull # passing a __attribute__((nonnull)) pointer against NULL
STRICT_CFLAGS	+= -Warray-bounds # need -01+ (gcc's -Warray-bounds=2) is more complete
STRICT_CFLAGS	+= -Warray-parameter # need -01+ (gcc's -Warray-bounds=2) is more complete
STRICT_CFLAGS	+= -Wsuspicious-memaccess # awkward memset() usage
STRICT_CFLAGS	+= -Wnontrivial-memaccess # awkward memset()/memcpy() usage
STRICT_CFLAGS	+= -Wsizeof-array-decay # use sizeof on to-pointer-decayed array
STRICT_CFLAGS	+= -Walloca # any alloca (unbounded stack groth)
STRICT_CFLAGS	+= -Wunreachable-code-aggressive # dead code

DEV_CFLAGS		:= # must be included aftert STRICT_CFLAGS
DEV_CFLAGS		+= -Wno-unused-parameter
DEV_CFLAGS		+= -Wno-unused-function

DEBUG_CFLAGS	:=
DEBUG_CFLAGS	+= -g3

SAN_FS			:=
SAN_FS			+= -fsanitize=address
SAN_FS			+= -fsanitize=undefined
SAN_FS			+= -fsanitize=local-bounds
SAN_FS			+= -fsanitize=pointer-compare
SAN_FS			+= -fsanitize=pointer-subtract
# SAN_FS			+= -fsanitize=float-cast-overflow
# SAN_FS			+= -fsanitize=float-divide-by-zero

SAN_CFLAGS		:=
SAN_CFLAGS		+= $(SAN_FS)
SAN_CFLAGS		+= -fsanitize-address-use-after-scope
SAN_CFLAGS		+= -fno-sanitize=function
SAN_CFLAGS		+= -fno-sanitize-recover=all
SAN_CFLAGS		+= -fno-sanitize-merge
SAN_CFLAGS		+= -fno-omit-frame-pointer
SAN_CFLAGS		+= -fno-optimize-sibling-calls
SAN_CFLAGS		+= -fstrict-flex-arrays=3
SAN_CFLAGS		+= -mno-omit-leaf-frame-pointer
SAN_CFLAGS		+= -fno-common

SAN_CPPFLAGS	:=
SAN_CPPFLAGS	+= -U_FORTIFY_SOURCE

SAN_LDFLAGS		:=
SAN_LDFLAGS		+= $(SAN_FS)

ifeq ($(BUILD), prod)
	CFLAGS		+= $(STRICT_CFLAGS)
	CFLAGS		+= -ftrivial-auto-var-init=zero # just for safety
	CFLAGS		+= -fstack-protector-strong
	CFLAGS		+= -Wstack-protector
	CPPFLAGS	+= -D_FORTIFY_SOURCE=3
	CFLAGS		+= -O2
	LDFLAGS		+= -fuse-ld=lld
else ifeq ($(BUILD), strict)
	CFLAGS		+= $(STRICT_CFLAGS)
	CFLAGS		+= -O2	# some problems are only produced during optimization
else ifeq ($(BUILD), test)
	CFLAGS		+= $(DEBUG_CFLAGS)
	CPPFLAGS	+= $(SAN_CPPFLAGS)
	CFLAGS		+= $(SAN_CFLAGS)
	LDFLAGS		+= $(SAN_LDFLAGS)
	CFLAGS		+= -O1
else ifeq ($(BUILD), dev)
	CFLAGS		+= $(STRICT_CFLAGS)
	CFLAGS		+= $(DEV_CFLAGS)
	CFLAGS		+= $(DEBUG_CFLAGS)
	CFLAGS		+= -O0
else
$(error Invalid BUILD='$(BUILD)' (expected 'dev', 'test', 'strict' or 'prod',))
endif

# runtime options
UBSAN_OPTS	:= halt_on_error=1:print_stacktrace=1
ASAN_OPTS	:= halt_on_error=1:strict_string_checks=1:detect_stack_use_after_return=1:detect_leaks=1:strict_string_checks=1

# rules

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

test:
	$(MAKE) BUILD=test $(TEST_NAME)
	ASAN_OPTIONS="$(ASAN_OPTS)" \
	UBSAN_OPTIONS="$(UBSAN_OPTS)" \
	./$(TEST_NAME)

$(TEST_NAME): $(OBJ_TEST)
	$(CC) $(LDFLAGS) -o $@ $^ $(CMOCKA_LIBS)

$(OBJ_DIR)/%.o: %.c
	$(DIR_DUP)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

-include $(DEP)
-include $(DEP_TEST)

format-check:
	git ls-files -z $(CFMT_SPECS) | xargs -0 -r $(CLANG_FORMAT) -n --Werror

format:
	git ls-files -z $(CFMT_SPECS) | xargs -0 -r $(CLANG_FORMAT) -i

clean:
	$(RM) $(DEP) $(OBJ)
	$(RMDIR) $(OBJ_DIR)

fclean: clean
	$(RM) $(NAME)
	$(RM) $(TEST_NAME)

re: fclean all

.PHONY: all clean fclean re format-check format test
