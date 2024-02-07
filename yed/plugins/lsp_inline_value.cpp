#include <string>
#include <iostream>
#include <sstream>
#include <map>
#include <vector>
#include <memory>

using namespace std;

#include "json.hpp"
using json = nlohmann::json;

extern "C" {
#include <yed/plugin.h>
}

#define DEFAULT_THRESHOLD  1500
#define REQUEST_TIMEOUT    4000

static yed_plugin         *Self;
//static unsigned long long  cursor_idle_start_ms;
//static unsigned long long  cursor_is_idle;
static int                 requested;
//static unsigned long long  request_time;


static string uri_for_buffer(yed_buffer *buffer) {
    string uri = "";

    if (!(buffer->flags & BUFF_SPECIAL)
    &&  buffer->kind == BUFF_KIND_FILE) {
        if (buffer->path == NULL) {
            uri += "untitled:";
            uri += buffer->name;
        } else {
            uri += "file://";
            uri += buffer->path;
        }
    }

    return uri;
}

struct Position {
    size_t line;
    size_t character;

    Position(size_t line, size_t character) : line(line), character(character) {}
};


static Position position_in_frame(yed_frame *frame) {
    yed_line *line;

    if (frame == NULL || frame->buffer == NULL) {
        return Position(-1, -1);
    }

    line = yed_buff_get_line(frame->buffer, frame->cursor_line);
    if (line == NULL) {
        return Position(-1, -1);
    }

    return Position(frame->cursor_line - 1, yed_line_col_to_idx(line, frame->cursor_col));
}

static Position position_in_frame_end_of_line(yed_frame *frame) {
    yed_line *line;

    if (frame == NULL || frame->buffer == NULL) {
        return Position(-1, -1);
    }

    line = yed_buff_get_line(frame->buffer, frame->cursor_line);
    if (line == NULL) {
        return Position(-1, -1);
    }

    return Position(frame->cursor_line - 1, yed_line_col_to_idx(line, line->visual_width==0?0:line->visual_width-1));
}

static map<string, string> ft_map = {
    { "abap",            "ABAP"             },
    { "bat",             "Windows Bat"      },
    { "bibtex",          "BibTeX"           },
    { "clojure",         "Clojure"          },
    { "coffeescript",    "Coffeescript"     },
    { "c",               "C"                },
    { "cpp",             "C++"              },
    { "csharp",          "C#"               },
    { "Diff",            "diff"             },
    { "dart",            "Dart"             },
    { "dockerfile",      "Dockerfile"       },
    { "elixir",          "Elixir"           },
    { "erlang",          "Erlang"           },
    { "fsharp",          "F#"               },
    { "git-commit",      "Git"              },
    { "go",              "Go"               },
    { "groovy",          "Groovy"           },
    { "handlebars",      "Handlebars"       },
    { "html",            "HTML"             },
    { "ini",             "Ini"              },
    { "java",            "Java"             },
    { "javascript",      "JavaScript"       },
    { "javascriptreact", "JavaScript React" },
    { "json",            "JSON"             },
    { "latex",           "LaTeX"            },
    { "less",            "Less"             },
    { "lua",             "Lua"              },
    { "makefile",        "Make"             },
    { "markdown",        "Markdown"         },
    { "objective-c",     "Objective-C"      },
    { "objective-cpp",   "Objective-C++"    },
    { "perl",            "Perl"             },
    { "perl6",           "Perl 6"           },
    { "php",             "PHP"              },
    { "powershell",      "Powershell"       },
    { "jade",            "Pug"              },
    { "python",          "Python"           },
    { "r",               "R"                },
    { "razor",           "Razor (cshtml)"   },
    { "ruby",            "Ruby"             },
    { "rust",            "Rust"             },
    { "sass",            "SCSS"             },
    { "scala",           "Scala"            },
    { "shaderlab",       "ShaderLab"        },
    { "shellscript",     "Shell"            },
    { "sql",             "SQL"              },
    { "swift",           "Swift"            },
    { "typescript",      "TypeScript"       },
    { "typescriptreact", "TypeScript React" },
    { "tex",             "TeX"              },
    { "vb",              "Visual Basic"     },
    { "xml",             "XML"              },
    { "xsl",             "XSL"              },
    { "yaml",            "YAML"             },
};


static void request(yed_frame *frame) {
    requested = 1;

    //request_time = measure_time_now_ms();

    if (frame == NULL
    ||  frame->buffer == NULL
    ||  frame->buffer->kind != BUFF_KIND_FILE
    ||  frame->buffer->flags & BUFF_SPECIAL) {

        return;
    }

    string   uri = uri_for_buffer(frame->buffer);
    Position pos = position_in_frame_end_of_line(frame);

    json params = {
        { "textDocument", {
            { "uri", uri },
        }},
        { "range",{
            {"start",{
                { "line",      pos.line      },
                { "character", 0 },
            }},
            {"end",{
                { "line",      pos.line      },
                { "character", pos.character },
            }},
        }},
    };


    yed_event event;
    string text = params.dump();

    LOG_FN_ENTER();
    yed_log("%s\n",text.c_str());
    LOG_EXIT();

    event.kind                       = EVENT_PLUGIN_MESSAGE;
    event.plugin_message.message_id  = "lsp-request:textDocument/inlayHint";
    event.plugin_message.plugin_id   = "lsp_inline_value";
    event.plugin_message.string_data = text.c_str();
    event.ft                         = frame->buffer->ft;

    yed_trigger_event(&event);
}


const char* trim_characters = " \t\n:";


static void pmsg(yed_event *event) {
    if (strcmp(event->plugin_message.plugin_id, "lsp") != 0
    ||  strcmp(event->plugin_message.message_id, "textDocument/inlayHint") != 0) {
        return;
    }


    event->cancel = 1;

    //if (!requested) { return; }

    try{
        const auto j = json::parse(event->plugin_message.string_data);


        const auto &results = j.at("result");

        for (auto &result : results){
            try{
                ssize_t start;
                ssize_t end;
                string value;
                double type = result.at("kind").get<double>();
                if (static_cast<int>(type) != 1){
                    continue;
                }

                LOG_FN_ENTER();
                    yed_log("%s\n",result.dump(2).c_str());
                LOG_EXIT();

                auto label = result.at("label");

                if (label.is_array()){

                    for (auto part : label){
                        LOG_FN_ENTER();
                            yed_log("part %s\n",part.dump(2).c_str());
                        LOG_EXIT();
                        try{
                            value += part.at("value").get<string>();
                        }catch(...){}
                    }
                }else if(label.is_string()){
                    value = label.get<string>();
                }else{
                    continue;
                }

                for(end = value.length()-1;end>=0 && strchr(trim_characters,value[end]);end -= 1){}
                for(start = 0;start<=end && strchr(trim_characters,value[start]);start += 1){}


                if(end < 0 ){
                    yed_set_var("lsp-inline-type","error");
                }
                yed_set_var("lsp-inline-type",value.substr(start,end-start+1).c_str());


                return;
            }catch(...){}
        }


    }catch(...){}

    yed_set_var("lsp-inline-type","default");

}

static void move(yed_event *event) {
    request(ys->active_frame);
}

static void bmod(yed_event *event) {
    if( ys->active_frame == NULL ||
        ys->active_frame->buffer == NULL ||
        ys->active_frame->buffer != event->buffer){
            return;
    }
    request(ys->active_frame);
}



static void unload(yed_plugin *self) { }

extern "C"
int yed_plugin_boot(yed_plugin *self) {
    YED_PLUG_VERSION_CHECK();

    Self = self;

    map<void(*)(yed_event*), vector<yed_event_kind_t> > event_handlers = {
        { pmsg,     { EVENT_PLUGIN_MESSAGE    } },
        { move,     { EVENT_CURSOR_POST_MOVE  } },
        { bmod,     { EVENT_BUFFER_POST_MOD   } },
    };

    map<const char*, const char*> vars          = { { "lsp-info-popup-idle-threshold-ms", XSTR(DEFAULT_THRESHOLD) } };
    map<const char*, void(*)(int, char**)> cmds = {  };

    for (auto &pair : event_handlers) {
        for (auto evt : pair.second) {
            yed_event_handler h;
            h.kind = evt;
            h.fn   = pair.first;
            yed_plugin_add_event_handler(self, h);
        }
    }

    for (auto &pair : vars) {
        if (!yed_get_var(pair.first)) { yed_set_var(pair.first, pair.second); }
    }

    for (auto &pair : cmds) {
        yed_plugin_set_command(self, pair.first, pair.second);
    }

    //cursor_idle_start_ms = measure_time_now_ms();

    /* Fake cursor move so that it works on startup/reload. */
    yed_move_cursor_within_active_frame(0, 0);

    yed_plugin_set_unload_fn(self, unload);

    return 0;
}
