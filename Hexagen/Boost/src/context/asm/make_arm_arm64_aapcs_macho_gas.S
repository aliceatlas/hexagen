// Stub file for universal binary

#if defined(__arm64__)
    #include "make_arm64_aapcs_macho_gas.S"
#elif defined(__arm__)
    #include "make_arm_aapcs_macho_gas.S"
#else
    // iPhone Simulator
    #include "make_i386_x86_64_sysv_macho_gas.S"
#endif
