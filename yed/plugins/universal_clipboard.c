#include<stdio.h>
#include<stdint.h>
#include<stdlib.h>
#include<yed/plugin.h>

void copy_to_universal_clipboard(int argc, char **argv);

static const char b64chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
//code modified from stack overflow post to get the b4 bit encoded verison of a char array
char *b64_encode(const unsigned char *in, size_t len)
{
    char   *out;
    size_t  elen;
    size_t  i;
    size_t  j;
    size_t  v;

    if (in == NULL || len == 0)
        return NULL;

    elen = len;
    if (len % 3 != 0)
        elen += 3 - (len % 3);
    elen /= 3;
    elen *= 4;
    out  = malloc(elen+1);
    out[elen] = '\0';

    for (i=0, j=0; i<len; i+=3, j+=4) {
        v = in[i];
        v = i+1 < len ? v << 8 | in[i+1] : v << 8;
        v = i+2 < len ? v << 8 | in[i+2] : v << 8;

        out[j]   = b64chars[(v >> 18) & 0x3F];
        out[j+1] = b64chars[(v >> 12) & 0x3F];
        if (i+1 < len) {
            out[j+2] = b64chars[(v >> 6) & 0x3F];
        } else {
            out[j+2] = '=';
        }
        if (i+2 < len) {
            out[j+3] = b64chars[v & 0x3F];
        } else {
            out[j+3] = '=';
        }
    }

    return out;
}

//function given by Brandon Kammerdiener to return the char array for the selected text.
char *get_sel_text(yed_buffer *buffer) {
    char      nl;
    array_t   chars;
    int       r1;
    int       c1;
    int       r2;
    int       c2;
    int       r;
    yed_line *line;
    int       cstart;
    int       cend;
    int       i;
    int       n;
    char     *data;

    nl    = '\n';
    chars = array_make(char);

    yed_range_sorted_points(&buffer->selection, &r1, &c1, &r2, &c2);

    if (buffer->selection.kind == RANGE_LINE) {
        for (r = r1; r <= r2; r += 1) {
            line = yed_buff_get_line(buffer, r);
            if (line == NULL) { break; } /* should not happen */

            data = (char*)array_data(line->chars);
            array_push_n(chars, data, array_len(line->chars));
            array_push(chars, nl);
        }
    } else {
        for (r = r1; r <= r2; r += 1) {
            line = yed_buff_get_line(buffer, r);
            if (line == NULL) { break; } /* should not happen */

            if (line->visual_width > 0) {
                cstart = r == r1 ? c1 : 1;
                cend   = r == r2 ? c2 : line->visual_width + 1;

                i    = yed_line_col_to_idx(line, cstart);
                n    = yed_line_col_to_idx(line, cend) - i;
                data = array_item(line->chars, i);

                array_push_n(chars, data, n);
            }

            if (r < r2) {
                array_push(chars, nl);
            }
        }
    }

    array_zero_term(chars);

    return (char*)array_data(chars);
}

int yed_plugin_boot(yed_plugin *self){
    YED_PLUG_VERSION_CHECK();
    yed_plugin_set_command(self, "copy-to-universal-clipboard", copy_to_universal_clipboard);
    return 0;
}


void copy_to_universal_clipboard(int argc, char **argv){
    char * selection;
    char * base64;
    char * out_buffer;
    yed_buffer *buffer = ys->active_frame!=NULL?ys->active_frame->buffer:NULL;
    if(buffer !=NULL && buffer->has_selection){
        selection = get_sel_text(buffer);
        if(selection != NULL && strcmp(selection,"")!=0){
            base64 = b64_encode(selection,strlen(selection));
            out_buffer = malloc(strlen(base64)+20);
            snprintf(out_buffer,strlen(base64)+20,"\033]52;c;%s\a",base64);
            append_to_output_buff(out_buffer);
            free(out_buffer);
            free(selection);
            free(base64);
        }
    }
}
