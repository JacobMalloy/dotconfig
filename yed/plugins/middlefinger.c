#include<stdio.h>
#include<yed/plugin.h>


void middle_finger(int argc,char ** argv);
#if 0
static char * ascii_middle_finger=" \
                     ██    \n\
                    █ ░█     \n\
                    █   █      \n\
                    █   █\n\
                    █   █\n\
                    █   █\n\
                    █   █▓\n\
                    █   ▓█\n\
                    █   ░█\n\
                    █   ░█\n\
                    █░░░ █\n\
             ▓███  ██▓▓███\n\
             ██  ▓██▓    ██\n\
             █▓    █▓     ▓█\n\
             █▓     █      ░█\n\
████████     █▓     █        █\n\
██████████▓███░      █  █▓    █\n\
██░░░░░░██           █░███    █▓\n\
▓████████             █▓██    ██\n\
█████████░                    ▓█\n\
▓████████░                    ░█\n\
▓████████░                    ▓█\n\
▓████████░                    █▓\n\
▓████████░                    █\n\
▓████████░                   ██\n\
▓█████░██░                  █\n\
▓█████  ████████████████████\n\
█████████\n\
";
#endif
#if 0
static char* ascii_middle_finger="\
                      /´¯/)\n\
                    ,/¯  /\n\
                   /    /\n\
             /´¯/'   '/´¯¯`·¸\n\
          /'/   /    /       /¨¯\\\n\
        ('(   ´   ´     ¯~/'   ')\n\
         \\                 '     /\n\
          ''   \\           _ ·´\n\
            \\              (\n\
              \\             \\   \n\
";
#endif


static char * ascii_middle_finger="\
           ▄████▄                           ▄████▄           \n\
          ▄██████▄                         ▄██████▄          \n\
          █      █                         █      █          \n\
          █      █                         █      █          \n\
          █      █                         █      █          \n\
          █ ▄▄▄▄ █                         █ ▄▄▄▄ █          \n\
          █      █                         █      █          \n\
          █      █                         █      █          \n\
          █      █                         █      █          \n\
          █      █                         █      █          \n\
      ▄▄▄▄█ ▄▄▄▄ █                         █ ▄▄▄▄ █▄▄▄▄      \n\
   ▄██▀ █▀█      ███████▄           ▄███████      █▀█ ▀██▄   \n\
  ▄██▀ █  █      █     █████▄   ▄█████     █      █  █ ▀██▄  \n\
 ▄██  █   █      █     █    █   █    █     █      █   █  ██▄ \n\
▄██  █    █      █     █    █   █    █     █      █    █  ██▄\n\
██  █     █      █     █    █   █    █     █      █     █  ██\n\
▀██ █     █      █     █    █   █    █     █      █     █ ██▀\n\
 ▀███     █      █     █    █   █    █     █      █     ███▀ \n\
  ▀██     █      █     █    █   █    █     █      █     ██▀  \n\
   ██                       █   █                       ██   \n\
   ▀█                    ▄███   ███▄                    █▀   \n\
    ██▄                ▄███▀     ▀███▄                ▄██    \n\
    ▀████████████████████▀         ▀████████████████████▀    \n\
      ▀████████████████▀             ▀████████████████▀      \n\
        ▀███████████▀                   ▀███████████▀        \n\
";
int yed_plugin_boot(yed_plugin *self){

    YED_PLUG_VERSION_CHECK();

    yed_plugin_set_command(self, "fuck-you", middle_finger);



    return 0;
}

yed_buffer *get_or_make_buff(void) {
    yed_buffer *buff;

    buff = yed_get_buffer("*fuck-you");

    if (buff == NULL) {
        buff = yed_create_buffer("*fuck-you");
        buff->flags |= BUFF_RD_ONLY | BUFF_SPECIAL;
    }

    return buff;
}

void middle_finger(int argc, char **argv){

    get_or_make_buff()->flags &= ~BUFF_RD_ONLY;
    yed_buff_clear_no_undo(get_or_make_buff());

    yed_buff_insert_string_no_undo(get_or_make_buff(),ascii_middle_finger,1,1);


    get_or_make_buff()->flags |= BUFF_RD_ONLY;

    YEXE("special-buffer-prepare-focus", "*fuck-you");
    yed_frame_set_buff(ys->active_frame, get_or_make_buff());

}
