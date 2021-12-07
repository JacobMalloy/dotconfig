#include <yed/plugin.h>

void kammerdienerb_quit(int n_args, char **args);
void kammerdienerb_write_quit(int n_args, char **args);
void kammerdienerb_find_cursor_word(int n_args, char **args);
void jacobmalloy_frame_commands(int argc, char **argv);
void jacobmalloy_frame_command_handler(yed_event *event);
void jacobmalloy_ypm_update_quit(int argc, char **argv);
void jacobmalloy_ypm_update_quit_pump(yed_event *event);

int go_menu_stay;
static yed_plugin *global_self;

#define ARGS_SCRATCH_BUFF "*scratch", (BUFF_SPECIAL)

yed_buffer *get_or_make_buffer(char *name, int flags) {
    yed_buffer *buff;
LOG_FN_ENTER();

    if ((buff = yed_get_buffer(name)) == NULL) {
        buff = yed_create_buffer(name);
        yed_log("\ninit.c: created %s buffer", name);
    }
    buff->flags |= flags;

LOG_EXIT();
    return buff;
}

int yed_plugin_boot(yed_plugin *self) {
    char              *term;
    char              *env_style;
    char              *path;

    global_self=self;

    YED_PLUG_VERSION_CHECK();

    LOG_FN_ENTER();

    yed_log("init.c");
    yed_log("\n# ********************************************************");
    yed_log("\n# **      This is Jacob Malloy's yed configuration      **");
    yed_log("\n# ********************************************************");


    get_or_make_buffer(ARGS_SCRATCH_BUFF);

    yed_plugin_set_command(self, "jacobmalloy-frame-commands", jacobmalloy_frame_commands);
    yed_plugin_set_command(self, "jacobmalloy-ypm-update-quit", jacobmalloy_ypm_update_quit);
    yed_plugin_set_command(self, "kammerdienerb-find-cursor-word", kammerdienerb_find_cursor_word);


    /*
     * Set things that need to be dynamic,
     * but allow yedrc to override.
     */
    if (!yed_term_says_it_supports_truecolor()) {
        yed_cerr("init.c: WARNING: terminal does not report that it supports truecolor\n"
                 "using truecolor anyways");
    }

    YEXE("set", "truecolor", "yes");

    YEXE("plugin-load", "ypm");

    if (file_exists_in_PATH("rg")) {
        yed_log("init.c: found an rg executable");
        YEXE("set", "grep-prg",      "rg --vimgrep '%' | sort");
        YEXE("set", "find-file-prg", "rg --files | rg -i '(^[^/]*%)|(/[^/]*%[^/]*$)' | sort");
    } else if (file_exists_in_PATH("fzf")) {
        yed_log("init.c: found a fzf executable");
        YEXE("set", "find-file-prg", "fzf --filter='%'");
    }

    if (getenv("DISPLAY") && file_exists_in_PATH("notify-send")) {
        yed_log("init.c: using desktop notifications for builder");
        YEXE("set", "builder-notify-command", "notify-send -i utilities-terminal yed %");
    }

    /* Load my yedrc file. */
    path = get_config_item_path("yedrc");
    YEXE("yedrc-load", path);
    free(path);

    /* Load style via environment var if set. */
    if ((term = getenv("TERM"))
    &&  strcmp(term, "linux") == 0) {
        yed_log("init.c: TERM = linux -- activating vt style\n");
        YEXE("style", "vt");
    } else if ((env_style = getenv("YED_STYLE"))) {
        yed_log("init.c: envirnoment variable YED_STYLE = %s -- activating\n", env_style);
        YEXE("style", env_style);
    }

    yed_plugin_set_command(self, "q",  kammerdienerb_quit);
    yed_plugin_set_command(self, "Q",  kammerdienerb_quit);
    yed_plugin_set_command(self, "wq", kammerdienerb_write_quit);
    yed_plugin_set_command(self, "Wq", kammerdienerb_write_quit);
    yed_log("\ninit.c: added overrides for 'q'/'Q' and 'wq'/'Wq' commands");

    yed_event_handler h;
    h.kind = EVENT_KEY_PRESSED;
    h.fn = jacobmalloy_frame_command_handler;
    yed_plugin_add_event_handler(global_self,h);

    LOG_EXIT();

    return 0;
}

static int do_it =0;

void jacobmalloy_frame_commands(int argc, char **argv){
    do_it=1;
    #if 0
    yed_event_handler h;
    h.kind = EVENT_KEY_PRESSED;
    h.fn = jacobmalloy_frame_command_handler;
    yed_plugin_add_event_handler(global_self,h);
    #endif
}

void jacobmalloy_frame_command_handler(yed_event *event){
    if(!do_it)
        return;
    switch(event->key){
        case 'd':
            YEXE("frame-delete");
            break;
        case '|':
            YEXE("frame-vsplit");
            break;
        case '-':
            YEXE("frame-hsplit");
            break;
    }
    event->cancel=1;
    do_it=0;
}

void jacobmalloy_ypm_update_quit(int argc, char **argv){
    yed_event_handler h;
    h.kind = EVENT_POST_PUMP;
    h.fn = jacobmalloy_ypm_update_quit_pump;
    yed_plugin_add_event_handler(global_self,h);
    YEXE("ypm-update");
}

void jacobmalloy_ypm_update_quit_pump(yed_event *event){
    if(!yed_var_is_truthy("ypm-is-updating")){
        YEXE("quit");
    }
}

void kammerdienerb_quit(int n_args, char **args) {
    yed_frame      *frame;
    int             n_frames;
    yed_frame_tree *tree;

    /* 1 or 0 frames, just quit. */
    n_frames = array_len(ys->frames);
    if ((frame = ys->active_frame) == NULL
    ||  n_frames == 1) {
        YEXE("quit");
        return;
    }

    /* If we aren't in a 2-frame split situation, just delete the frame. */
    tree = frame->tree;
    if (n_frames != 2
    ||  tree->parent == NULL) {
        YEXE("frame-delete");
        return;
    }

    /*
     * Okay, it's a split.
     * If this frame is the left child, quit.
     * Otherwise, delete the frame.
     */
    if (tree == tree->parent->child_trees[0]) {
        YEXE("quit");
    } else {
        YEXE("frame-delete");
    }
}

void kammerdienerb_write_quit(int n_args, char **args) {
    YEXE("w");
    YEXE("q");
}

void kammerdienerb_find_cursor_word(int n_args, char **args) {
    char *word;

    if (n_args != 0) {
        yed_cerr("expected 0 arguments, but got %d", n_args);
        return;
    }

    word = yed_word_under_cursor();

    if (word == NULL) {
        yed_cerr("cursor is not on a word");
        return;
    }

    YEXE("find-in-buffer", word);
    YEXE("find-prev-in-buffer");

    free(word);
}
