#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include "channel.h"

int main(int argc, char **argv) {
  int configfd_h2f = open("/sys/module/friend_loader/call/h2f", O_RDWR);
  int configfd_f2h = open("/sys/module/friend_loader/call/f2h", O_RDWR);
  if(configfd_h2f < 0 || configfd_f2h < 0) {
    perror("Open call failed");
    return -1;
  }

  char *h2f = static_cast<char *>(mmap(nullptr, PAGE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, configfd_h2f, 0));
  char *f2h = static_cast<char *>(mmap(nullptr, PAGE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, configfd_f2h, 0));
  if (h2f == MAP_FAILED || f2h == MAP_FAILED) {
    perror("mmap operation failed");
    return -1;
  }

  set_type(h2f, 1);

  while(get_type(h2f) == 0) {
    asm volatile("":::"memory");
  }

  while(get_type(f2h) == 1) {
    asm volatile("":::"memory");
  }

  printf("test: OK\n");
  
  close(configfd_h2f);
  close(configfd_f2h);
  return 0;
}
