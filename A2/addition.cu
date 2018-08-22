#include<stdio.h>
#include<iostream>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

int main(int argc, char **argv) {
  FILE *fptr;
  int ch=1;

  int inputLength;

  /* parse the input arguments */
  //@@ Insert code here

  // Import host input data
  //@@ Read data from the raw files here
  //@@ Insert code here

  char *filename = "input0.raw";

    fptr = fopen(filename, "r");
      if (fptr == NULL)
      {
          perror("Cannot open file input0\n");
          exit(0);
      }
      int i=0;
      fscanf(fptr,"%d",&inputLength);
	printf("Input Length=%d",inputLength);

  float *hostInput1 = (float *)malloc(sizeof(float)*inputLength);
  float *hostInput2 = (float *)malloc(sizeof(float)*inputLength);
  float *hostOutput;
      while (i!=inputLength)
      {
        fscanf(fptr, "%f" ,&ch);
          *(hostInput1+i)=ch;
//	if(i==0)
//		printf("hostinput[0]=%f ",*(hostInput1+i));
          ++i;
      }

      fclose(fptr);
      char filename2[11] = "input1.raw";

        fptr = fopen(filename2, "r");
          if (fptr == NULL)
          {
              perror("Cannot open file input1\n");
              exit(0);
          }
          i=0;
          ch=1;
	  fscanf(fptr,"%f",&ch);
          while (i!=inputLength)
          {
            fscanf(fptr, "%f" ,&ch);
             *(hostInput2+i)=ch;
              ++i;
          }
          fclose(fptr);

  // Declare and allocate host output
  //@@ Insert code here
  hostOutput = (float *)malloc(sizeof(float)*inputLength);

  // Declare and allocate thrust device input and output vectors
  //@@ Insert code here
  thrust::device_vector<float> x(inputLength);
  thrust::device_vector<float> y(inputLength);
  thrust::device_vector<float> z(inputLength);
  // Copy to device
  //@@ Insert code here
  thrust::copy	(hostInput1,hostInput1+inputLength,x.begin());
  thrust::copy	(hostInput2,hostInput2+inputLength,y.begin());

  // Execute vector addition
  //@@ Insert Code here
  thrust::transform(x.begin(), x.end(),
 y.begin(),
z.begin(),
thrust::plus<float>());

  /////////////////////////////////////////////////////////

  // Copy data back to host
  //@@ Insert code here
  thrust::copy(z.begin(),z.end(),hostOutput);
  //Check if output is correct

  char filename3[11] = "output.raw";

    fptr = fopen(filename3, "r");
      if (fptr == NULL)
      {
          printf("Cannot open file output\n");
          exit(0);
      }
      i=0;
      ch=1;
	fscanf(fptr,"%d",&ch);
	float f;
      while (i!=inputLength)
      {
        fscanf(fptr, "%f" ,&f);
	if(i<10)
	printf("\n%f\n",f);
         //if(f!=*(hostOutput+i))
         //printf("Wrong Answer i=%d\nhostOp[i]=%d\nch=%d\n",i,*(hostOutput+i),f);
          ++i;
      }
      fclose(fptr);

  free(hostInput1);
  free(hostInput2);
  free(hostOutput);
  return 0;
}

