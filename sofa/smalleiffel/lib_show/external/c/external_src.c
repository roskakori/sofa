/*
  Hand-written C code to be used with external_demo.e
*/

#include <stdio.h>

void integer2c(int i){
  printf("%d\n",i);
}

void character2c(char c){
  printf("'%c'\n",c);
}

void boolean2c(int b){
  printf("%d\n",b);
}

void real2c(float r){
  printf("%f\n",r);
}

void double2c(double d){
  printf("%f\n",d);
}

void string2c(char *s){
  printf("%s",s);
}

void any2c(void *a){
  if (a == NULL) {
    printf("NULL\n");
  }
  else {
    printf("not NULL\n");
  }
}

void current2c(void *a){
  any2c(a);
}

int integer2eiffel(void){
  return -6;
}

char character2eiffel(void){
  return '\n';
}


void write_integer_attribute(int*attribute){
  *attribute=2;
}
