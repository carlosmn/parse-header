/* Some comment */
/** And this is documentation! */
typedef uint64_t git_off_t;

/** More documentation */
enum something { SOME_ID = 4, OTHER_ID = 3 << 3 };

enum something_else {
	SOME_ID = 4,
	OTHER_ID = 3 << 3,
};

/** Typedef of an enum  */
typedef enum boring { BLAH } interesting_t;

/* This probably wouldn't be in a header, but it helps for the struct */
int my_var;
