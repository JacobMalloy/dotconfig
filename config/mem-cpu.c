#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#if __APPLE__

#include <mach/vm_statistics.h>
#include <mach/mach_types.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>

#endif

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
    //fprintf(stderr,"%lu - %lu\n",d.free,d.total);
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

void loadAvg(char * c){
    double values[3];
    getloadavg(values,3);
    sprintf(c,"%.2lf %.2lf %.2lf",values[0],values[1],values[2]);
}


#if __linux__

struct cpu_internal{
  int64_t user,nice,system,idle,iowait,irq,softirq;
};

struct data get_mem(){
    struct data returnValue;
    size_t trash;
    FILE *fd = fopen("/proc/meminfo","r");
    fseek(fd,0,SEEK_SET);
    if(NULL==fd){
        fprintf(stderr,"Failed to open /proc/meminfo\n");
        exit(-1);
    }
    if(fscanf(fd,"MemTotal: %llu kB \n MemFree: %llu kB",&returnValue.total,&returnValue.free)!=2){
        fprintf(stderr,"Read the incorrect amount from /proc/meminfo");
        exit(-1);
    }
    fclose(fd);
    return returnValue;
}

struct cpu_internal get_cpu_internal(){
    struct cpu_internal returnValue;
    FILE *fd = fopen("/proc/stat","r");
    fseek(fd,0,SEEK_SET);
    if(NULL==fd){
        fprintf(stderr,"Failed to open /proc/stat\n");
        exit(-1);
    }
    if(fscanf(fd,"cpu  %llu %llu %llu %llu %llu %llu %llu",&returnValue.user,&returnValue.nice,&returnValue.system,&returnValue.idle,&returnValue.iowait,&returnValue.irq,&returnValue.softirq)!=7){
        fprintf(stderr,"failed to read 7 from /proc/stat\n");
        exit(-1);
    }
    fclose(fd);
    return returnValue;
}

void print_cpu(struct cpu_internal *t){
    //fprintf(stderr,"%ld %ld %ld %ld %ld %ld %ld\n",t->user,t->nice,t->system,t->idle,t->iowait,t->irq,t->softirq);
}

struct data get_cpu(char *filename){
    struct cpu_internal cpu_new,cpu_old,cpu_diff;
    struct data returnValue;
    FILE *fd;
    fd = fopen(filename,"rb");
    if(fd==NULL){
        memset(&cpu_old,0,sizeof(cpu_old));
    }else{
        if(fread(&cpu_old,sizeof(cpu_old),1,fd)!=1){
            fprintf(stderr,"failed to open %s\n",filename);
            exit(-1);
        }
        fclose(fd);
    }
    cpu_new = get_cpu_internal();
    cpu_diff.user = cpu_new.user-cpu_old.user;
    cpu_diff.nice = cpu_new.nice-cpu_old.nice;
    cpu_diff.system = cpu_new.system-cpu_old.system;
    cpu_diff.idle = cpu_new.idle-cpu_old.idle;
    cpu_diff.iowait = cpu_new.iowait-cpu_old.iowait;
    cpu_diff.irq = cpu_new.irq-cpu_old.irq;
    cpu_diff.softirq = cpu_new.softirq-cpu_old.softirq;
    print_cpu(&cpu_old);
    print_cpu(&cpu_new);
    print_cpu(&cpu_diff);
    returnValue.total = cpu_diff.user+cpu_diff.nice+cpu_diff.system+cpu_diff.idle+cpu_diff.iowait+cpu_diff.irq+cpu_diff.softirq;
    returnValue.idle = cpu_diff.iowait+cpu_diff.idle;
    fd=fopen(filename,"wb+");
    if(fd==NULL){
        fprintf(stderr,"failed to open %s for writing\n",filename);
        exit(-1);
    }
    if(fwrite(&cpu_new,sizeof(cpu_new),1,fd)!=1){
        fprintf(stderr,"failed to write to %s",filename);
        exit(-1);
    }
    fclose(fd);
    return returnValue;
}


#elif __APPLE__

struct data get_mem(){
    vm_size_t page_size;
    mach_port_t mach_port;
    mach_msg_type_number_t count;
    vm_statistics64_data_t vm_stats;
    struct data return_value;
    memset(&return_value,0,sizeof(struct data));

    mach_port = mach_host_self();

    count = sizeof(vm_stats) / sizeof(natural_t);
    if (KERN_SUCCESS == host_page_size(mach_port, &page_size) &&
        KERN_SUCCESS == host_statistics64(mach_port, HOST_VM_INFO,
                                        (host_info64_t)&vm_stats, &count))
    {
        return_value.free = (int64_t)vm_stats.free_count * (int64_t)page_size/1024;

        return_value.total = ((int64_t)vm_stats.active_count +
                              (int64_t)vm_stats.inactive_count +
                              (int64_t)vm_stats.wire_count + (int64_t)vm_stats.free_count) * (int64_t)page_size/1024;
    }
    return return_value;
}


struct data get_cpu(char * filename){
    struct data return_value;
    memset(&return_value,0,sizeof(struct data));
    return return_value;
}

#else //end of __linux__
struct data get_cpu(char * filename){
    fprintf(stderr,"This platform is not supported\n");
    exit(-1);
}

struct data get_mem(){
    fprintf(stderr,"This platform is not supported\n");
    exit(-1);
}

#endif //all other platforms


int main(int argc, char* argv[]){
    char string[250];
    char barGraph[250];
    char load[250];
    char filename[250];
    struct data cpu,mem;

    if(argc!=2){
        fprintf(stderr,"please enter an argument for the filename");
        exit(-1);
    }

    if(snprintf(filename,250,"/tmp/tmux-perf-%s.txt",argv[1])==-1){
        fprintf(stderr,"Name value given too long");
        exit(-1);
    }

    cpu = get_cpu(filename);
    mem = get_mem();
    loadAvg(load);
    getMemRatio(string,mem);
    getCpuUsageBar(barGraph,cpu);
    printf("%s %s %s",string,barGraph,load);
    return 0;
}
