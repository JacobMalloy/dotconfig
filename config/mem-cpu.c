#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>

#define SLEEP_TIME 10000

struct memory{
    uint64_t total,free;
};

struct cpu{
    uint64_t idle,total;
};

struct data{
    union{
        uint64_t idle,free;
    };
    uint64_t total;
};

#if __linux__

struct cpu_internal{
  uint64_t user,nice,system,idle,iowait,irq,softirq;
};

struct memory get_mem(){
    struct memory returnValue;
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
    fscanf(cpuFd,"cpu  %lu %lu %lu %lu %lu %lu %lu",&returnValue.user,&returnValue.nice,&returnValue.system,&returnValue.idle,&returnValue.idle,&returnValue.iowait,&returnValue.irq,&returnValue.softirq);
    fclose(fd);
    return returnValue;
}

struct cpu get_cpu(){
    struct cpu_internal cpu_new,cpu_old,cpu_diff;
    struct cpu returnValue;
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

#endif

int main(int argc, char* argv[]){
    struct memory currentMemory;
    struct cpu cpu_old;
    struct cpu cpu_new;
    uint64_t total;
    double percentUsed;
    FILE *fd = fopen("/proc/stat","r");
    if(fd==NULL){
        fprintf(stderr,"Failed to open meminfo\n");
        return -1;
    }
    fscanf(cpuFd,"cpu  %lu %lu %lu %lu %lu %lu %lu",&cpu_old.user,&cpu_old.nice,&cpu_old.system,&cpu_old.idle,&cpu_old.idle,&cpu_old.iowait,&cpu_old.irq,&cpu_old.softirq);
    printf("Total:%lu - Free:%lu\nPercent used %lf\n",currentMemory.total,currentMemory.free,percentUsed);
    printf("Total:%lu - Free:%lu\nPercent used %lf\n",total,cpu_new.idle,percentUsed);
    return 0;
}
