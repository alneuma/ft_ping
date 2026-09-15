// #include "ft_ping.h"
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

enum opts { VERBOSE = (1U << 1) };

struct options {
	uint8_t flags;
	char *arg;
};

/**
 * print_usage()
 *
 * prints usage message
 */
static void print_usage(FILE *out, const char *prog_name)
{
	(void)fprintf(out, "Usage: %s [-v] [-?]\n", prog_name);
}

/**
 * parse_options()
 *
 * uses POSIX, so first non-option argument is considered to be the end of
 * options
 */
static int parse_options(struct options *opts, int argc, char *argv[])
{
	const char opt_str[] = "+v";
	int opt;
	opterr = 0;

	while ((opt = getopt(argc, argv, opt_str)) != -1) {
		switch (opt) {
		case 'v':
			opts->flags |= VERBOSE;
			break;
		default:
			return optopt;
		}
	}
	opts->arg = argv[optind];
	return 0;
}

int main(int argc, char *argv[])
{
	struct options opts;
	int ret;

	ret = parse_options(&opts, argc, argv);
	if (ret && ret != '?') {
		(void)fprintf(stderr, "unrecognized option %c\n", ret);
		print_usage(stderr, argv[0]);
		return 2;
	} else if (ret) {
		print_usage(stderr, argv[0]);
		return 2;
	} else if (!opts.arg) {
		(void)fprintf(stderr,
			      "%s: usage error: Destination address required\n",
			      argv[0]);
		return 2;
	}
	(void)printf("address: %s\nv=%d\n", opts.arg, !!(opts.flags & VERBOSE));
	return 0;
}
