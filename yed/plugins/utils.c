#include <yed/plugin.h>

/*commands*/
static void write_all(int argc, char **argv);
/*end_commands*/

//set the commands in this block so that command creation is uniform
void create_commands(yed_plugin *self){
    yed_plugin_set_command(self,"write-all",write_all);
}

int yed_plugin_boot(yed_plugin *self){
    YED_PLUG_VERSION_CHECK();
    create_commands(self);
    return 0;
}






/*Start implementations*/
static void write_all(int argc, char **argv){
    yed_buffer *buffer;
    tree_it( yed_buffer_name_t, yed_buffer_ptr_t ) buffer_iterator;

    tree_traverse( ys->buffers, buffer_iterator )
    {
        buffer = tree_it_val( buffer_iterator );

        if ( !( buffer->flags & BUFF_SPECIAL ) && (buffer->flags & BUFF_MODIFIED))
        {
            yed_write_buff_to_file(buffer,buffer->path);
        }
    }

}
/*End Implementations*/
