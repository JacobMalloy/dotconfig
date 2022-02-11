#include<yed/plugin.h>

void enter_replace_mode(int argc,char **argv);
void exit_replace_mode(int argc,char **argv);
void replace_insert_command(int argc,char **argv);

static int replace_mode=0;
static yed_command default_insert;

int yed_plugin_boot(yed_plugin *self){
    YED_PLUG_VERSION_CHECK();

    yed_plugin_set_command(self, "enter-replace-mode", enter_replace_mode);
    yed_plugin_set_command(self, "exit-replace-mode", exit_replace_mode);


    default_insert = yed_get_default_command("insert");
    yed_set_command("insert",replace_insert_command);
    return 0;
}


void enter_replace_mode(int argc,char **argv){
    replace_mode=1;
}

void exit_replace_mode(int argc,char **argv){
    replace_mode=0;
}

void replace_insert_command(int argc,char **argv){
    yed_frame *frame;
    yed_line *line;
    int key;
    if(argc != 1 ){
        yed_cerr("Incorrect number of arguments passed to insert\n");
        return;
    }
    key = atoi(argv[0]);
    if(replace_mode && key!=ENTER){
        if (!ys->active_frame) {
            yed_cerr("no active frame");
            return;
        }

        frame = ys->active_frame;

        if (!frame->buffer) {
            yed_cerr("active frame has no buffer");
            return;
        }
        line = yed_buff_get_line(frame->buffer,frame->cursor_line);
        if(frame->cursor_col < line->visual_width+1) {YEXE("delete-forward");}
    }
    default_insert(argc,argv);
}
