#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include "pack/ezxml/ezxml.h"
#include "pack/ezxml/ezxml.c"

#define BUFFERSIZE 16 

#define SG2042_DTB_OFFSET 0x601000
#define SG2042_DTB_LOADER "0x20000000"
#define SG2044_DTB_OFFSET 0x500000
#define SG2044_DTB_LOADER "0x88000000"

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
    char *ld_dtb;
    char sflash_offset[argc-1][BUFFERSIZE];
    uint64_t of_dtb;
    ezxml_t xml = ezxml_new("firmware");
    if (xml==NULL){
        printf("generate xml file failed!");
        return -1;
    }
   // generate xml file
    #ifdef SG2042
        of_dtb=SG2042_DTB_OFFSET;
        ld_dtb=SG2042_DTB_LOADER;
        ezxml_set_txt(ezxml_add_child(xml, "name", 0), "SG2042");
        ezxml_set_txt(ezxml_add_child(xml, "size", 0), "0x4000000");
        // add efie
        ezxml_set_element(xml,"efie",NULL,"0x600000",NULL,"4096");
        //add fip.bin
        ezxml_set_element(xml,"fip","fip.bin","0x00030000",NULL,NULL);
        //add zsbl.bin
        ezxml_set_component(xml,"zsbl.bin","0x2a00000","0x40000000");
        //add fw_dynamic.bin
        ezxml_set_component(xml,"fw_dynamic.bin","0x660000","0x00000000");
        //add riscv64_Image
        ezxml_set_component(xml,"riscv64_Image","0x6b0000","0x02000000");
        //add initrd.img
        ezxml_set_component(xml,"initrd.img","0x2b00000","0x30000000");
        out_put="sg2042-layout.xml";
    #elif defined(SG2044)
        of_dtb=SG2044_DTB_OFFSET;
        ld_dtb=SG2044_DTB_LOADER;
        ezxml_set_txt(ezxml_add_child(xml, "name", 0), "SG2044");
        ezxml_set_txt(ezxml_add_child(xml, "size", 0), "0x4000000");
        // add efie
        ezxml_set_element(xml,"efie",NULL,"0x80000",NULL,"4096");
        //add zsbl.bin
        ezxml_set_component(xml,"zsbl.bin","0x2f0000","0x40000000");
        //add fsbl.bin
        ezxml_set_component(xml,"fsbl.bin","0x81000","0x7010080000");
        //add fw_dynamic.bin
        ezxml_set_component(xml,"fw_dynamic.bin","0x15d000","0x80000000");
        //add SG2044.fd
        ezxml_set_component(xml,"SG2044.fd","0x600000","0x80200000");
        out_put="sg2044-layout.xml";
    #endif

    // add device-tree
    for (i=0;i<argc-1;i++){
        sprintf(sflash_offset[i], "0x%lX", of_dtb);
        file_name=argv[i+1];
        ret=stat(file_name,&file_stat);
        if (ret || !file_stat.st_size) {
            printf("can't get file %s size %ld\n", file_name,file_stat.st_size);
            return -1;
        }
        ezxml_set_component(xml,file_name,sflash_offset[i],ld_dtb);
        of_dtb += file_stat.st_size;
    }
    FILE *fp = fopen(out_put, "w");
    if (fp==NULL){
        ezxml_free(xml);
        printf("can't create and open %s !",out_put);
        return -1;
    }
    else if (fp) {
        // ret=fprintf(fp, "<?xml version=\"1.0\"?>\n");
        const char *raw_xml = ezxml_toxml(xml);
        char formatted_xml[8192];  
        format_xml(raw_xml, formatted_xml);
        fprintf(fp, "%s", formatted_xml);
        fclose(fp);
    }
    ezxml_free(xml);
    return 0;
}
