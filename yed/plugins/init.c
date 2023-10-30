#include <yed/plugin.h>

void jacobmalloy_quit(int n_args, char **args);
void kammerdienerb_find_cursor_word(int n_args, char **args);
void jacobmalloy_special_buffer_prepare_focus_custom(int n_args, char **args);
void jacobmalloy_frame_commands(int argc, char **argv);
void jacobmalloy_frame_command_handler(yed_event *event);
void jacobmalloy_frame_next(int n_args,char **args);

void jacobmalloy_handle_buffer_focus(yed_event * event);
void jacobmalloy_handle_frame_activate(yed_event * event);

int go_menu_stay;
static yed_plugin *global_self;
static yed_frame *save_frame;
static int in_go_menu;

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
    yed_plugin_set_command(self, "frame-next", jacobmalloy_frame_next);
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

    yed_plugin_set_command(self, "special-buffer-prepare-focus-custom", jacobmalloy_special_buffer_prepare_focus_custom);

    if (file_exists_in_PATH("rg")) {
        yed_log("init.c: found an rg executable");
        YEXE("set", "grep-prg",      "rg --vimgrep '%' | sort");
        YEXE("set", "find-file-prg", "rg --files | rg -i '(^[^/]*%)|(/[^/]*%[^/]*$)' | sort");
    } else if (file_exists_in_PATH("fzf")) {
        yed_log("init.c: found a fzf executable");
        YEXE("set", "find-file-prg", "fzf --filter='%'");
    }

#if 0
    if (getenv("DISPLAY") && file_exists_in_PATH("notify-send")) {
        yed_log("init.c: using desktop notifications for builder");
        YEXE("set", "builder-notify-command", "notify-send -i utilities-terminal yed %");
    }
#endif

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

    yed_plugin_set_command(self, "q",  jacobmalloy_quit);
    yed_plugin_set_command(self, "Q",  jacobmalloy_quit);
    yed_log("\ninit.c: added overrides for 'q'/'Q' and 'wq'/'Wq' commands");

    yed_event_handler h;
    h.kind = EVENT_KEY_PRESSED;
    h.fn = jacobmalloy_frame_command_handler;
    yed_plugin_add_event_handler(global_self,h);
    h.kind = EVENT_BUFFER_PRE_FOCUS;
    h.fn = jacobmalloy_handle_buffer_focus;
    yed_plugin_add_event_handler(self,h);
    h.kind = EVENT_FRAME_PRE_ACTIVATE;
    h.fn = jacobmalloy_handle_frame_activate;
    yed_plugin_add_event_handler(self,h);

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


void jacobmalloy_frame_next(int n_args,char **args){
    yed_frame *cur_frame, *frame, **frame_it;
    int        take_next;

    if (n_args != 0) {
        yed_cerr("expected 0 arguments, but got %d", n_args);
        return;
    }

    if (!ys->active_frame) {
        yed_cerr("no active frame");
        return;
    }

    if (array_len(ys->frames) == 1) { return; }

    frame     = NULL;
    cur_frame = ys->active_frame;

    if (cur_frame == *(yed_frame**)array_last(ys->frames)) {
        frame = *(yed_frame**)array_item(ys->frames, 0);
    } else {
        take_next = 0;
        array_traverse(ys->frames, frame_it) {
            if (take_next) {
                frame = *frame_it;
                break;
            }

            if (*frame_it == cur_frame) {
                take_next = 1;
            }
        }
    }

    yed_activate_frame(frame);
}

void jacobmalloy_quit(int n_args, char **args) {
    yed_frame      *tmp_frame;
    int non_named_count;

    if(ys->active_frame==NULL){
        YEXE("quit");
        return;
    }

    non_named_count=0;
    array_traverse(ys->frames,tmp_frame){
        if(tmp_frame->name){
            non_named_count++;
        }
    }

    if(!ys->active_frame->name){
        if(non_named_count<=1){
            YEXE("quit");
            return;
        }else{
            YEXE("frame-delete");
            return;
        }
    }

    if(non_named_count==0){
        YEXE("quit");
        return;
    }

    YEXE("frame-delete");

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



void jacobmalloy_special_buffer_prepare_focus_custom(int n_args, char **args) {
}



void jacobmalloy_handle_buffer_focus(yed_event * event){
    return;
    static int in_buffer_focus;

    if (in_buffer_focus) { return; }

    in_buffer_focus = 1;

    yed_log("focus\n");
    //yed_log("%s\n",save_frame->buffer->name);
    if(strcmp(event->buffer->name,"*go-menu")==0){
        yed_log("go-menu\n");
        in_go_menu=1;
    }else{
        if (save_frame != NULL) {
            yed_log("prepare focus");
            yed_log("in_go menu");
            yed_frame** tmp_frame;
            yed_log("here2");
            array_traverse(ys->frames,tmp_frame){
                if(*tmp_frame == save_frame){
                    yed_log("here\n");
                    yed_activate_frame(save_frame);
                    save_frame=NULL;
                    goto out;
                }
            }
            save_frame=NULL;
        }

        in_go_menu=0;
    }
out:;
    save_frame=NULL;
    in_buffer_focus = 0;
}


void jacobmalloy_handle_frame_activate(yed_event * event){
    return;
    if(in_go_menu){
        return;
    }
    yed_log("activate\n");
    save_frame=ys->active_frame;
}
