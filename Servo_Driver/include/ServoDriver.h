//ServoDriver.h
#ifndef _SERVODRIVER_H_
#define _SERVODRIVER_H_
#ifdef __cplusplus
extern "C" {
#endif
    #if (defined(MATLAB_MEX_FILE) || defined(RSIM_PARAMETER_LOADING) ||  defined(RSIM_WITH_SL_SOLVER))
        /* This will be run in Rapid Accelerator Mode */
        #define ServoDriver_Init(a, b)       (0)
        #define ServoDriver_Step(a, b, c, d) (0)
        #define ServoDriver_Terminate()      (0)
    #else
        #include <stdint.h>
        void ServoDriver_Init(int32_t*, int32_t);
        void ServoDriver_Step(int32_t, int32_t, int32_t, int32_t);
        void ServoDriver_Terminate(void);
#endif
#ifdef __cplusplus
}
#endif
#endif 