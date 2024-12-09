#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include "ezxml/ezxml.h"
#include "ezxml/ezxml.c"
#include <time.h>

#define NAMESIZE 32
#define LOADERSIZE 20 
#define INVALID "invalid" 
#define FLASHSIZE 0x4000000

#ifdef SG2044R 
    #define PARTION{"efie","0x80000","0x1000",\
                    "fsbl.bin", "0x81000" ,"0x7010080000" ,\
		    "fw_dynamic.bin", "0x15d000", "0x82200000", \
		    "ap_Image" ,"0x2f0000" ,"0x82400000", \
		    "ap_rootfs.cpio", "0x2a00000" ,"0xa0000000", \
		    "sg2044r_xmrig" ,"0x34b4000" ,"0x0"}
    #define PARTNUM 6
    #define DTB_OFFSET 0x25b1000
    #define DTB_LOADER "0x90000000"
    #define OUTPUT "sg2044r-layout.xml"
    #define NAME "SG2044R"
    #define RELEASENOTE "sg2044r_release_note.md"
#endif

#ifdef MANGO
    #define PARTION {"fip.bin","0x00030000",\
                    "efie","0x600000","0x1000",\
                    "zsbl.bin","0x2a00000","0x40000000",\
                    "fw_dynamic.bin","0x670000","0x00000000",\
                    "riscv64_Image","0x6c0000","0x02000000",\
                    "initrd.img","0x2b00000","0x30000000",\
                    "SG2042.fd","0x2000000","0x2000000"}
    #define PARTNUM 7
    #define DTB_OFFSET 0x601000
    #define DTB_LOADER "0x20000000"
    #define OUTPUT "sg2042-layout.xml"
    #define NAME "SG2042"
    #define RELEASENOTE "sg2042_release_note.md"
#endif

#ifdef SG2044
    #define PARTION {"efie","0x80000","0x1000",\
                    "zsbl.bin","0x2f0000","0x40000000",\
                    "fsbl.bin","0x81000","0x7010080000",\
                    "fw_dynamic.bin","0x15d000","0x80000000",\
                    "SG2044.fd","0x600000","0x80200000"}
    #define PARTNUM 5
    #define DTB_OFFSET 0x500000
    #define DTB_LOADER "0x88000000" 
    #define OUTPUT "sg2044-layout.xml"
    #define NAME "SG2044"  
    #define RELEASENOTE "sg2044_release_note.md"
#endif

typedef struct p_info{
    char p_name[NAMESIZE];
    uint32_t p_off;
    char p_ldr[LOADERSIZE];
    char p_size[LOADERSIZE];
}p_info; 

void get_dtb_info(struct p_info *info, char *dtb_name, uint32_t dtb_off, char* dtb_ldr){
    strcpy(info->p_name,dtb_name);
    info->p_off=dtb_off;
    strcpy(info->p_ldr,dtb_ldr);
}

int get_part_info(struct p_info *info, int p_num, char *part[]){
    int i,j,ret;
    struct stat file_stat;
    char p_stat[LOADERSIZE];
    for(i=0,j=0;i<p_num;i++){
        if(part[j]=="fip.bin"){
            strcpy((info+i)->p_name,part[j++]);
            (info+i)->p_off=strtoul(part[j++],NULL,16);
            strcpy((info+i)->p_ldr,INVALID);
            ret=stat((info+i)->p_name,&file_stat);
            if (ret || !file_stat.st_size) {
                printf("failed to get the file %s size !\n",(info+i)->p_name);
                return -1;
            }
            sprintf(p_stat,"0x%lX",file_stat.st_size);
            strcpy((info+i)->p_size,p_stat);
            i++;
        }
        if(part[j]=="efie"){
            strcpy((info+i)->p_name,part[j++]);
            (info+i)->p_off=strtoul(part[j++],NULL,16); 
            strcpy((info+i)->p_ldr,INVALID);
            strcpy((info+i)->p_size,part[j++]);
            i++;        
        }
        strcpy((info+i)->p_name,part[j++]);
        (info+i)->p_off=strtoul(part[j++],NULL,16); 
        strcpy((info+i)->p_ldr,part[j++]);
        stat((info+i)->p_name,&file_stat);
        sprintf(p_stat,"0x%lX",file_stat.st_size);   
        strcpy((info+i)->p_size,p_stat);    
    }
    return 0;
}

void parse_info(ezxml_t parent, struct p_info *info, char*sp_off){
    char *txt;
    if( !strcmp(info->p_name,"efie") ){
        txt="efie";
    }else{
        txt="component";
    }
    ezxml_t child=ezxml_add_child(parent,txt,0);
    ezxml_set_txt(ezxml_add_child(child,"name",0), info->p_name);
    sprintf(sp_off,"0x%X",info->p_off);
    ezxml_set_txt(ezxml_add_child(child,"offset",0), sp_off);
    if(strcmp(info->p_ldr,INVALID)){
        ezxml_set_txt(ezxml_add_child(child,"loader",0), info->p_ldr);
    }
    if(strcmp(info->p_size,INVALID)){
        ezxml_set_txt(ezxml_add_child(child,"size",0), info->p_size);
    }
}

void format_xml(const char *input, char *output){
    const char *ptr = input;
    char *out_ptr = output;
    int indent=0,marked=0;
    while(*ptr){
        if(*ptr=='>'){
            if(*(ptr+1)=='<'){
                if(*(ptr+2)=='/'){
                    *out_ptr++=*ptr++;
                    indent-=1;
                    marked=1;
                }
                else{
                    if(marked){
                        *out_ptr++=*ptr++;
                        marked=0;
                    }
                    else{
                        indent+=1;
                        *out_ptr++=*ptr++;
                    }
                }
                *out_ptr++='\n';
                memset(out_ptr,'\t',indent);
                out_ptr+=indent;
            }
            else{
                marked=1;
                *out_ptr++=*ptr++;
            }
        }else{
            *out_ptr++=*ptr++;
        }
    }
    *out_ptr = '\0';
}

int gen_xml(FILE *fp,ezxml_t parent, struct p_info *info, int p_num){
    int i,j,tar=0;
    uint32_t min_off,cur_off=0;
    char origin[p_num*LOADERSIZE];
    char* sp_off=origin;
    uint32_t all_off[p_num];
    uint64_t all_size[p_num];
    for(i=0;i<p_num;i++){
        min_off=FLASHSIZE;
        for(j=0;j<p_num;j++){
            if(info[j].p_off>cur_off && info[j].p_off<min_off){
                min_off=info[j].p_off;
                tar=j;
            }
        }
        cur_off=min_off;
        sp_off+=LOADERSIZE;
        all_off[i]=info[tar].p_off;
        all_size[i]=strtoul(info[tar].p_size,NULL,16);
        parse_info(parent,&info[tar],sp_off);
        printf("generate the %dth partion info name:%s offset:0x%X loader:%s size:%s\n",i,
                                            info[tar].p_name,info[tar].p_off,info[tar].p_ldr,info[tar].p_size);
    }
    const char *raw_xml = ezxml_toxml(parent);
    char formatted_xml[8192];  
    format_xml(raw_xml, formatted_xml);      
    fprintf(fp, "%s", formatted_xml);
 
    for(i=0;i<p_num-1;i++){
        if(all_off[i]+all_size[i]>all_off[i+1]){
            printf("failed for overlap: check the layer of the %dth file and the %dth file !\n",i,i+1);
            return -1;
        }
    }
    if(all_off[p_num-1]+all_size[p_num-1]>FLASHSIZE){
        printf("failed for overlap: the layer of the %dth file over the flash !\n",p_num-1);
        return -1;
    }
    return 0;
}

int get_version(char *file_name, char* version){
    FILE *file=fopen(file_name,"r");
    char buffer[64];
    if(file == NULL || fgetc(file) == EOF){
        strcpy(version,"1.0.0");
        printf("generate the default version: 1.0.0\n");
        return 0;
    }
    else{
        fseek(file,0,SEEK_END);
        long size=ftell(file);
        long pos;
        for (pos = size - 1; pos >= 0; pos--) {
            fseek(file, pos, SEEK_SET);
            if (pos == 0 || fgetc(file) == '\n') {
                break;
            }
        }
        if (fgets(buffer, sizeof(buffer), file) != NULL) {
            char *first_word = strtok(buffer, " ");
            strcpy(version,strtok(first_word,"_"));
            printf("generate the firmware version: %s\n",version);
        } 
    }
    return 0;
}

int main(int argc, char* argv[]) {
    int ret,i;
    char *part[]=PARTION;
    int p_num=PARTNUM;
    int dtb_num=argc-1;
    struct p_info info[dtb_num+p_num];
    uint32_t dtb_off=DTB_OFFSET;
    char* dtb_ldr=DTB_LOADER;
    struct stat dtb_stat;
    char *output=OUTPUT;
    char flash_size[LOADERSIZE];
    char version[LOADERSIZE];

    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);
    char date[LOADERSIZE];
    strftime(date, sizeof(date), "%Y%m%d", tm_info);

    for (i=0;i<dtb_num;i++){
        ret=stat(argv[i+1],&dtb_stat);
        if (ret || !dtb_stat.st_size) {
            printf("failed to get the file %s size !\n",argv[i+1]);
            return -1;
        }
        sprintf(info[i].p_size,"0x%lX",dtb_stat.st_size);
        get_dtb_info(&info[i],argv[i+1],dtb_off,dtb_ldr);
        dtb_off+=dtb_stat.st_size;
    }

    ret=get_part_info(&info[i],p_num,part);
    if(ret){
        printf("failed to pass the part information\n");
        return -1;
    }
    get_version(RELEASENOTE,version);

    FILE *fp = fopen(output, "w");
    if (fp==NULL){
        printf("failed to create and open %s !\n",output);
        return -1;
    }

    sprintf(flash_size,"0x%X",FLASHSIZE);
    ezxml_t xml = ezxml_new("firmware");
    if (xml==NULL){
        printf("failed to generate xml root element !\n");
        fclose(fp);
        return -1;
    }
    ezxml_set_txt(ezxml_add_child(xml,"name",0),NAME);
    ezxml_set_txt(ezxml_add_child(xml,"size",0),flash_size);
    ezxml_set_txt(ezxml_add_child(xml,"version",0),version);
    ezxml_set_txt(ezxml_add_child(xml,"date",0),date);

    ret=gen_xml(fp,xml,info,p_num+dtb_num);
    if (ret) {
        printf("failed to get legal xml file: please check out the layer !\n");
    }
    fclose(fp);
    ezxml_free(xml);

    return ret;
}
