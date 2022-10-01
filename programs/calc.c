#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdint.h>
#include <regex.h>


struct string{
    uint64_t size;
    uint64_t len;//len is always the index of the null terminator... so it is the length not including the null terminator
    char *data;
};

struct token{
    enum {num,open_paren,close_paren,equals,plus,minus,mul,div,tilde,and,or,xor,power,left_shift,right_shift} type;
    long long value;
    long double value_float;
};

struct global_data{

};

//setup the string with the passed in size
void initialize_string(struct string *my_string, uint64_t size){
    my_string->size=size;
    my_string->len=0;
    my_string->data=malloc(sizeof(char)*size);
    my_string->data[0]=0;
}

//append to the string expanding it if necessary
void string_append(struct string *my_string, char *str){
    uint64_t length = strlen(str);
    //expand the data section if necessary
    if(length+my_string->len+1>=my_string->size){
        my_string->size = (length+my_string->len+1)*2;
        my_string->data = realloc(my_string->data,sizeof(char)*my_string->size);
    }

    //copy the str into my_string
    memcpy(my_string->data+my_string->len,str,length+1);
    my_string->len=my_string->len+length;
}

void next_token(char *current_string,struct token *lookahead){

}


int main(int argc, char **argv){
    struct string my_string;
    char *string_loc;
    unsigned long character_count;
    initialize_string(&my_string,argc*10);
    for(int i =0;i<argc;i++){
        string_append(&my_string,argv[i]);
        string_append(&my_string," ");
    }
    string_loc = my_string.data;

    free(my_string.data);
}
