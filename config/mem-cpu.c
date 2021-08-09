#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

struct memory{
    uint64_t total,free;
};

struct cpu{
  uint64_t user,nice,system,idle,iowait,irq,softirq;
};

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
    fscanf(fd,"MemTotal: %lu kB\nMemFree: %lu kB",&currentMemory.total,&currentMemory.free);
    percentUsed = 1.0-(1.0*currentMemory.free/currentMemory.total);
    usleep(10000);
    fclose(cpuFd);
    cpuFd = fopen("/proc/stat","r");
    if(cpuFd==NULL){
        fprintf(stderr,"Failed to open /proc/stat\n");
        return -1;
    }
    fscanf(cpuFd,"cpu  %lu %lu %lu %lu %lu %lu %lu",&cpu_new.user,&cpu_new.nice,&cpu_new.system,&cpu_new.idle,&cpu_new.idle,&cpu_new.iowait,&cpu_new.irq,&cpu_new.softirq);
    total = cpu_new.user-cpu_old.user+cpu_new.nice-cpu_old.nice+cpu_new.system-cpu_old.system+cpu_new.idle-cpu_old.idle+cpu_new.iowait-cpu_old.iowait+cpu_new.irq-cpu_old.irq+cpu_new.softirq-cpu_old.softirq;
    printf("Total:%lu - Free:%lu\nPercent used %lf\n",currentMemory.total,currentMemory.free,percentUsed);
    percentUsed = 1.0-(1.0*(cpu_new.idle-cpu_old.idle)/total);
    printf("Total:%lu - Free:%lu\nPercent used %lf\n",total,cpu_new.idle,percentUsed);
    fclose(fd);
    fclose(cpuFd);
    return 0;
}
