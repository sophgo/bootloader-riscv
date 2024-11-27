#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include "pack/ezxml/ezxml.h"
#include "pack/ezxml/ezxml.c"

#define DTB_OFFSET_START 0x601000
#define BUFFERSIZE 16 


void format_xml(const char *input,char *output){
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

int ezxml_set_element(ezxml_t parent,char *child,char *name,char *offset,char *loader,char* size){
    ezxml_t component=ezxml_add_child(parent,child,0);
    if (component==NULL){
        ezxml_free(parent);
        return -1;
    }
    if(name){
        ezxml_set_txt(ezxml_add_child(component, "name", 0), name);
        ezxml_set_txt(ezxml_add_child(component, "file", 0), name);
    }
    if(offset){
        ezxml_set_txt(ezxml_add_child(component,"offset" , 0), offset);
    }
    if(loader){
        ezxml_set_txt(ezxml_add_child(component,"loader" , 0), loader); 
    }
    if(size){
        ezxml_set_txt(ezxml_add_child(component,"size" , 0), size); 
    }
    return 0;
}

void ezxml_set_component(ezxml_t parent,char *comp_name,char *comp_offset,char *comp_loader){
    ezxml_set_element(parent,"component",comp_name,comp_offset,comp_loader,NULL);
}



int main(int argc, char* argv[]) {

    struct stat file_stat;
    int ret,i;
    char* file_name,*out_put;
    char sflash_offset[argc-1][BUFFERSIZE];
    uint64_t flash_offset=DTB_OFFSET_START;

    // generate xml file
    ezxml_t xml = ezxml_new("firmware");
    if (xml==NULL){
        printf("generate xml file failed!");
        return -1;
    }
    #ifdef SG2042
        ezxml_set_txt(ezxml_add_child(xml, "name", 0), "SG2042");
    #elif defined(SG2044)
        ezxml_set_txt(ezxml_add_child(xml, "name", 0), "SG2042");
    #endif
    ezxml_set_txt(ezxml_add_child(xml, "size", 0), "0x4000000");

    // add efie
    ezxml_set_element(xml,"efie",NULL,"00x600000",NULL,"4096");

    //add zsbl.bin
    ezxml_set_component(xml,"zsbl.bin","0x2a00000","0x40000000");

    //add fw_dynamic.bin
    ezxml_set_component(xml,"fw_dynamic.bin","0x660000","0x00000000");

    // add  device-tree
    for (i=0;i<argc-1;i++){
        sprintf(sflash_offset[i], "0x%lX", flash_offset);
        file_name=argv[i+1];
        ret=stat(file_name,&file_stat);
        if (ret || !file_stat.st_size) {
            printf("can't get file %s size %ld\n", file_name,file_stat.st_size);
            return -1;
        }
        ezxml_set_component(xml,file_name,sflash_offset[i],"0x20000000");
        flash_offset += file_stat.st_size;
    }

    #ifdef SG2042
        //add riscv64_Image
        ezxml_set_component(xml,"riscv64_Image","0x6b0000","0x02000000");
        //add initrd.img
        ezxml_set_component(xml,"initrd.img","0x2b00000","0x30000000");
        //add fip.bin
        ezxml_set_element(xml,"fip","fip.bin","00x600000",NULL,NULL);
        out_put="sg2042-layout.xml";
    #elif defined(SG2044)
        //add SG2044.fd
        ezxml_set_component(xml,"SG2044.fd","0x6b0000","0x02000000");
        //add fsbl.bin
        ezxml_set_element(xml,"fsbl","fsbl.bin","00x600000",NULL,NULL);
        out_put="sg2044-layout.xml";
    #endif

    // 将生成的XML写入文件
    FILE *fp = fopen(out_put, "w");
    if (fp==NULL){
        ezxml_free(xml);
        printf("can't create and open sg2042-layout.xml !");
        return -1;
    }
    else if (fp) {
        // 写入XML声明
        // ret=fprintf(fp, "<?xml version=\"1.0\"?>\n");
        const char *raw_xml = ezxml_toxml(xml);
        char formatted_xml[8192];  
        format_xml(raw_xml, formatted_xml);
        fprintf(fp, "%s", formatted_xml);
        fclose(fp);
    }
    // 释放XML内存
    ezxml_free(xml);
    return 0;
}
