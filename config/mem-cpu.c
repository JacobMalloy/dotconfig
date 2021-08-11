#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define SLEEP_TIME 10000
#define BAR_WIDTH 10

struct data{
    union{
        uint64_t idle,free;
    };
    uint64_t total;
};

double percentage(struct data d){
    return 100*(1-(1.0*d.idle/d.total));
}

void getMemRatio(char *c,struct data d){
    sprintf(c,"%.1lf/%.1fG",1.0*(d.total-d.free)/0x100000,1.0*d.total/0x100000);
}

void getCpuUsageBar(char *c,struct data d){
    char temp[25];
    strcpy(c,"[");
    uint32_t bars = (d.total-d.idle)*BAR_WIDTH/d.total;
    for(uint32_t i =0;i<BAR_WIDTH;i++){
        if (i<bars){
            strcat(c,"|");
        }else{
            strcat(c," ");
        }

    }
    snprintf(temp,25,"] %3.2lf%%",percentage(d));
    strcat(c,temp);
}


#if __linux__

struct cpu_internal{
  int64_t user,nice,system,idle,iowait,irq,softirq;
};

struct data get_mem(){
    struct data returnValue;
    FILE *fd = fopen("/proc/meminfo","r");
    if(NULL==fd){
        fprintf(stderr,"Failed to open /proc/meminfo\n");
        exit(-1);
    }
    fscanf(fd,"MemTotal: %lu kB\nMemFree: %lu kB",&returnValue.total,&returnValue.free);
    fclose(fd);
    return returnValue;
}

struct cpu_internal get_cpu_internal(){
    struct cpu_internal returnValue;
    FILE *fd = fopen("/proc/stat","r");
    if(NULL==fd){
        fprintf(stderr,"Failed to open /proc/stat\n");
        exit(-1);
    }
    fscanf(fd,"cpu  %lu %lu %lu %lu %lu %lu %lu",&returnValue.user,&returnValue.nice,&returnValue.system,&returnValue.idle,&returnValue.iowait,&returnValue.irq,&returnValue.softirq);
    fclose(fd);
    return returnValue;
}

struct data get_cpu(){
    struct cpu_internal cpu_new,cpu_old,cpu_diff;
    struct data returnValue;
    cpu_old = get_cpu_internal();
    usleep(SLEEP_TIME);
    cpu_new = get_cpu_internal();
    cpu_diff.user = cpu_new.user-cpu_old.user;
    cpu_diff.nice = cpu_new.nice-cpu_old.nice;
    cpu_diff.system = cpu_new.system-cpu_old.system;
    cpu_diff.idle = cpu_new.idle-cpu_old.idle;
    cpu_diff.iowait = cpu_new.iowait-cpu_old.iowait;
    cpu_diff.irq = cpu_new.irq-cpu_old.irq;
    cpu_diff.softirq = cpu_new.softirq-cpu_old.softirq;
    returnValue.total = cpu_diff.user+cpu_diff.nice+cpu_diff.system+cpu_diff.idle+cpu_diff.iowait+cpu_diff.irq+cpu_diff.softirq;
    returnValue.idle = cpu_diff.iowait+cpu_diff.idle;
    return returnValue;
}

void loadAvg(char * c){
    double values[3];
    getloadavg(values,3);
    sprintf(c,"%.2lf %.2lf %.2lf",values[0],values[1],values[2]);
}

#endif

int main(int argc, char* argv[]){
    char string[250];
    char barGraph[250];
    char load[250];
    struct data cpu,mem;
    cpu = get_cpu();
    mem = get_mem();
    loadAvg(load);
    getMemRatio(string,mem);
    getCpuUsageBar(barGraph,cpu);
    printf("%s %s %s",string,barGraph,load);
    return 0;
}
