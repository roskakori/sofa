// Basic C++ class to test the SmallEiffel C++ interface

#include <iostream.h>
#include "Bar.h"

char Bar::get_character () {
  return character_attribute;
}

double Bar::get_double () {
  return double_attribute;
}

void Bar::do_print (int i) {

  cout << i << "\n";
}

char Bar::do_print_and_return (int i) {

  cout << i << "\n";
  return 'Y';
}
