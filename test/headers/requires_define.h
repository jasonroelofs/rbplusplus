/**
 * Test file that's for ensuring that extra CXXFLAGS are
 * properly sent to GCCXML for when the preprocessor is 
 * looking for other defines
 */

#ifndef MUST_BE_DEFINED
  #error "You're not defining the key that must be defined!"
#endif
