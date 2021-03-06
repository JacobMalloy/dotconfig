#include<yed/plugin.h>

static void tab_set_pre_insert_handler(yed_event *event);


int yed_plugin_boot(yed_plugin *self){
    yed_event_handler pre_insert_handler;

    YED_PLUG_VERSION_CHECK();

    pre_insert_handler.fn = tab_set_pre_insert_handler;
    pre_insert_handler.kind = EVENT_BUFFER_PRE_INSERT;

    yed_plugin_add_event_handler(self, pre_insert_handler);



    return 0;
}

void tab_set_pre_insert_handler(yed_event *event){
    int insert_count;
    char * insert_string;
    int tab_width;
    if(event->key=='\t'){
        if(event->buffer != NULL && event->frame != NULL){
            tab_width = yed_get_tab_width();
            insert_count = tab_width-((event->col-1)%tab_width);
            insert_string = malloc(insert_count+1);
            insert_string[insert_count]='\0';
            memset(insert_string,' ',insert_count);
            yed_buff_insert_string(event->buffer,insert_string,event->row,event->col);
            yed_set_cursor_within_frame(event->frame, event->row, event->col + insert_count);
            free(insert_string);
        }
        event->cancel = 1;
    }
}
