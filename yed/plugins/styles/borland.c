#include <yed/plugin.h>

#define color_bg            (18)
#define color_bg_2          (17)
#define color_cursor_line   (17)
#define color_fg            (255)
#define color_status_bar_fg (18)
#define color_status_bar_bg (80)
#define color_search        (255)
#define color_search_cursor (172)
#define color_attent        (197)
#define color_assoc         (90)
#define color_comment       (244)
#define color_keyword       (83)
#define color_pp            (83)
#define color_fn            (184)
#define color_num           (81)

PACKABLE_STYLE(borland) {
    yed_style s;
    int       attr_kind;

    attr_kind = ATTR_256;

    memset(&s, 0, sizeof(s));

    s.active.flags        = attr_kind;
    s.active.fg           = color_fg;
    s.active.bg           = color_bg;

    s.inactive.flags      = attr_kind;
    s.inactive.fg         = color_fg;
    s.inactive.bg         = color_bg_2;

    s.active_border       = s.active;
    s.active_border.fg    = color_fg;

    s.inactive_border     = s.inactive;

    s.cursor_line.flags   = attr_kind;
    s.cursor_line.fg      = s.active.fg;
    s.cursor_line.bg      = color_cursor_line;

    s.selection           = s.cursor_line;

/*     s.selection.flags     = attr_kind; */
/*     s.selection.fg        = s.active.bg; */
/*     s.selection.bg        = s.active.fg; */

    s.search.flags        = attr_kind;
    s.search.fg           = color_bg;
    s.search.bg           = color_search;

    s.search_cursor.flags = attr_kind | ATTR_BOLD;
    s.search_cursor.fg    = color_bg;
    s.search_cursor.bg    = color_search_cursor;

    s.attention.flags     = attr_kind | ATTR_BOLD;
    s.attention.fg        = color_attent;

    s.associate.flags     = attr_kind;
    s.associate.bg        = color_assoc;

    s.command_line        = s.active;

    s.status_line.flags   = attr_kind | ATTR_BOLD;
    s.status_line.fg      = color_status_bar_fg;
    s.status_line.bg      = color_status_bar_bg;

    s.active_gutter       = s.active;
    s.inactive_gutter     = s.inactive;

    s.code_comment.flags  = attr_kind | ATTR_BOLD;
    s.code_comment.fg     = color_comment;

    s.code_keyword.flags  = attr_kind | ATTR_BOLD;
    s.code_keyword.fg     = color_keyword;

    s.code_control_flow       =
    s.code_typename           = s.code_keyword;

    s.code_preprocessor.flags = attr_kind | ATTR_BOLD;
    s.code_preprocessor.fg    = color_pp;

    s.code_fn_call.flags  = attr_kind;
    s.code_fn_call.fg     = color_fn;

    s.code_number.flags  = attr_kind;
    s.code_number.fg     = color_num;

    s.code_constant      = s.code_preprocessor;
    s.code_string        = s.code_number;
    s.code_character     = s.code_number;

    yed_plugin_set_style(self, "borland", &s);

    return 0;
}
